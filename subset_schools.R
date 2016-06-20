## Creating subsets of NI Road Traffic Collisions datasets to analyse collisions occuring near to schools
## This requires starting with the cleaned and combined casualties and collisions datasets
## See https://github.com/NICVA/road-traffic-collisions/blob/master/clean_combine_casualties.R for more

setwd("C:/Documents/schools-rtcs")
casualties <- read.csv("C:/Documents/road-traffic-collisions/casualties.csv")
collisions <- read.csv("C:/Documents/road-traffic-collisions/collisions.csv")

library(tidyr)
library(dplyr)
library(lubridate)

## First, reduce the RTC datasets to 2005-2014, and create comparable datasets for all RTC in this period (i.e. weekday only)
collisions <- subset(collisions,
                     a_year >= 2005,
                     select = 1:length(collisions)) %>%
              mutate(a_datetime = ymd_hm(paste(a_year, a_month, a_day, a_hour, a_min))) %>% ## we also create a proper
              mutate(a_week = as.numeric(week(a_datetime)))                                 ## timestamp yyyy-mm-dd hh:mm

casualties <- subset(casualties,
                     a_year >= 2005,
                     select = 1:length(casualties))

weekday_collisions <- subset(collisions, 
                             a_wkday != "SAT" & a_wkday != "SUN")

weekday_casualties <- subset(casualties,
                             a_ref %in% weekday_collisions$a_ref)

## Second, subset the casualty dataset for school pupils on a school journey
## to or from school, 2005-2014
school_travel_injuries <- subset(casualties, 
                                 c_school == "pupil school journey",
                                 select = 1:length(casualties))

school_travel_injuries <- subset(school_travel_injuries, 
                                 c_age == "Under 10" | c_age == "10-16" | c_age == "17-24", 
                                 select = 1:length(casualties))

school_travel_injuries %>% write.csv("school_travel_injuries_2005-14.csv", row.names=F)


## Create subsets for the COLLISIONS where pupils on 
## way to/from school were injured
school_travel_arefs <- as.vector(school_travel_injuries$a_ref) ## N.B. non-unique (i.e. multiple instances of same a_ref)

school_travel_collisions <- subset(collisions, a_ref %in% school_travel_arefs) 

school_travel_collisions <- merge(school_travel_collisions, table(school_travel_arefs), by.x = 'a_ref', by.y='school_travel_arefs', sort=FALSE, all=TRUE)

colnames(school_travel_collisions)[colnames(school_travel_collisions) == 'Freq'] <- 'num_pupils'

write.csv(school_travel_collisions, row.names=F, "school_travel_collisions_2005-14.csv")

## Take all weekday_collisions and add the number of pupils on school journey as a column (inc. 0)

weekday_collisions <- merge(weekday_collisions, 
                            table(school_travel_arefs), 
                            by.x = 'a_ref', 
                            by.y='school_travel_arefs', 
                            sort=FALSE, all=TRUE)

colnames(weekday_collisions)[colnames(weekday_collisions) == 'Freq'] <- 'num_pupils'

weekday_collisions$num_pupils[is.na(weekday_collisions$num_pupils)] <- 0

weekday_collisions <- arrange(weekday_collisions, a_datetime)   
write.csv(weekday_collisions, "all_wkday_collisions_05-14.csv", row.names=F) ## We will use this dataset in spatial analysis to find those collisions occuring within 100m of a school

## Vectors of reference keys for defining subsets
schinj_fatalref <- as.vector(school_travel_injuries$a_ref[which(school_travel_injuries$c_sever == "fatal")],)
schinj_seriousref <- as.vector(school_travel_injuries$a_ref[which(school_travel_injuries$c_sever == "serious")],)
schinj_slightref <- as.vector(school_travel_injuries$a_ref[which(school_travel_injuries$c_sever == "slight")],)
