# schools-road-traffic-collisions
Analysis of RTCs close to school locations

These scripts rely on using the casualties.csv and collisions.csv file created by following the instructions in  [road-traffic-collisions](https://github.com/NICVA/road-traffic-collisions) repo, after downloading the data from the UK Data Archive (licensing conditions apply)

## subset_schools.R
Creates a number of subsets of the `casualties` and `collisions` dataframes to create comparable datasets for 2005-2014 on weekdays only, and subsets of collisions which involved pupils on a school journey (as well as a number of other subsets used in later analysis). The `weekday_collisions` dataframe includes a new variable `num_pupils` i.e. the number of school pupils injured on a journey to/from school.

## GIS element
The `weekday_collisions` dataframe created in the preceeding script was imported into QGIS and a points in polygon ([example](http://www.qgistutorials.com/en/docs/points_in_polygon.html)) analysis performed for those collisions within a 100m radius of school sites in Northern Ireland (for 2014-15: [data](http://data.nicva.org/dataset/school-locations)). This extracted every weekday collision 2005-14 that occured within 100m of a school site.

Two datasets were created:  
* `all_wkday_collision_05-14_within100m.csv` a subset of `weekday_collisions` where the collision occured within 100m of a school in Northern Ireland, with additional variables on the name and reference number of the _nearest_ school.
* `schools_collisions.csv` which is the schools sites dataset with an additional column containing the number of collisions within 100m

Unfortunately, we do not have the rights to reproduce the above datasets under the UK Data Archive standard access End User Licence. If/[when](https://www.opendatani.gov.uk/datarequest/6a76e55a-0f4c-456b-8ff6-20696500b82b) the data becomes openly licenced, we will do so.

## near_schools_analysis.R
Using `all_wkday_collision_05-14_within100m.csv` we are now able to undertake analysis of all collisions Mon-Fri that occured within 100m of a school site. This script carries out this analysis.
