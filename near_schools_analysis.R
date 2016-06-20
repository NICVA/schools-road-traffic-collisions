setwd("C:/Documents/schools-rtcs")

library(tidyr)
library(dplyr)
library(ggplot2)
library(lubridate)

near_school_wkday <- read.csv("C:/Documents/schools-rtcs/all_wkday_collision_05-14_within100m.csv")
## In QGIS, details of the nearest school has been added, for each collision which occured within 100m of a school.
## Note that there may be another school within the same 100m of each collision.
## This means that a single recorded collision may appear more than once in this dataset if it is within the
## 100m bounds of more than one school, and we need to control for double-counting where appropriate.

## Recall that for the 'school_travel_injuries' subset of the 'casualties' dataset we included casualties recorded
## as those of a pupil on travel to/from school, and excluded any recording of those that were aged over 24 as they
## were likely to be inaccurate recordings. Therefore, we use the school_travel_injuries subset where applicable.

## Number of collisions within 100m of a school, 2005-2014:
length(unique(near_school_wkday$a_ref))

## Number of collisions near schools which injured a school pupil on school journey:
length(unique(subset(near_school_wkday, num_pupils >= 1))$a_ref)

## Number of pupils on a school journey injured near schools:
sum(school_travel_injuries$a_ref %in% unique(near_school_wkday$a_ref))

  print("Breakdown of injury severity of collision near school (all casualties):", quote=FALSE)
subset(weekday_casualties, a_ref %in% unique(near_school_wkday$a_ref)) %>% 
  group_by(inj_severity = c_sever) %>% 
  summarize(number = length(inj_severity)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame

print("Breakdown of ages of people injured near schools (all casualties):", quote=FALSE)
subset(weekday_casualties, a_ref %in% unique(near_school_wkday$a_ref)) %>% 
  group_by(age = c_age) %>% 
  summarize(number = length(c_age)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame

  print("Breakdown of level of injury in collisions near schools which involved a school pupil on school journey:", quote=FALSE)
subset(school_travel_injuries, a_ref %in% unique(near_school_wkday$a_ref)) %>%
  group_by(c_sever) %>% 
  summarize(number = length(c_sever)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame

  print("Fatalities near schools, the schools and the speed limit:", quote=FALSE)
fatal_nr_school <- subset(casualties, c_sever == 'fatal' & a_ref %in% near_school_wkday$a_ref)
fatal_nr_school$school <- fatal_nr_school$speed_limit <- NA
fatal_nr_school <- within(fatal_nr_school, 
                          school <- near_school_wkday$nearest_school_within_100m[match(a_ref,near_school_wkday$a_ref)]) 
fatal_nr_school <- within(fatal_nr_school, 
                          speed_limit <- near_school_wkday$a_speed[match(a_ref,near_school_wkday$a_ref)])
print(fatal_nr_school)

  print("Serious injuries near schools, the schools and the speed limit:", quote=FALSE)
serious_nr_school <- subset(casualties, c_sever == 'serious' & a_ref %in% near_school_wkday$a_ref)
serious_nr_school$school <- serious_nr_school$speed_limit <- NA
serious_nr_school <- within(serious_nr_school, 
                          school <- near_school_wkday$nearest_school_within_100m[match(a_ref,near_school_wkday$a_ref)]) 
serious_nr_school <- within(serious_nr_school, 
                          speed_limit <- near_school_wkday$a_speed[match(a_ref,near_school_wkday$a_ref)])
print(serious_nr_school)

  print("Road speed limits for collisions near school with fatality:", quote=FALSE)
fatal_nr_school %>% 
  group_by(speed_limit) %>% 
  summarise(number = length(speed_limit)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame

  print("Road speed limits for collisions near school with serious injury:", quote=FALSE)
serious_nr_school %>% 
  group_by(speed_limit) %>% 
  summarise(number = length(speed_limit)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame

  print("Road speed limits for collisions near school with slight injury:", quote=FALSE)
slight_nr_school <- subset(casualties, c_sever == 'slight' & a_ref %in% near_school_wkday$a_ref)
slight_nr_school$school <- slight_nr_school$speed_limit <- NA
slight_nr_school <- within(slight_nr_school, 
                            school <- near_school_wkday$nearest_school_within_100m[match(a_ref,near_school_wkday$a_ref)]) 
slight_nr_school <- within(slight_nr_school, 
                            speed_limit <- near_school_wkday$a_speed[match(a_ref,near_school_wkday$a_ref)])
slight_nr_school %>% 
  group_by(speed_limit) %>% 
  summarise(number = length(speed_limit)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame

## Number/percent of near school collisions, by hour of the day (2005-2014)
## PLEASE NOTE! We have to exclude collisions from 2007-04-01 to 2007-12-31
## as the time was recorded incorrectly as 00:00 in each instance.
subset(collisions, a_ref %in% near_school_wkday$a_ref) %>% 
  subset(a_datetime < '2007-04-01 00:00:00' | a_datetime > '2007-12-31 23:59:59') %>%
  group_by(hour = a_hour) %>% 
  summarise(number = length(hour)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame

## Determine level of injury by speed limit
rbind(fatal_nr_school, serious_nr_school, slight_nr_school) %>%
  group_by(speed_limit, severity = c_sever) %>%
  summarise(number = length(speed_limit)) %>%
  spread(speed_limit, number) %>%
  replace(is.na(.), 0) %>%
  View

## Same as above, only percentage-wise
speed_severity <- rbind(fatal_nr_school, serious_nr_school, slight_nr_school) %>%
  group_by(severity = c_sever, speed_limit) %>%
  summarise(number = length(severity)) %>%
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  select(-c(number)) %>%
  spread(speed_limit, percent) %>%
  replace(is.na(.),0) %>%
  View

## Schools with collisions in a speed limit zone that was 60mph
subset(near_school_wkday, a_speed >= 50) %>%
  group_by(school = nearest_school_within_100m, stage = stage) %>% 
  summarise(number = length(a_ref)) %>% 
  print.data.frame

## Road user type in school pupil injuries near to schools
subset(casualties, a_ref %in% near_school_wkday$a_ref) %>% 
  subset(c_school == 'pupil school journey') %>%
  group_by(user = c_class) %>% 
  summarise(number = length(user)) %>% 
  mutate(percent = round(number/sum(number)*100, digits = 2)) %>%
  print.data.frame
