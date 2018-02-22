library(tidyverse)
library(sf)

NCPrecinct <- st_read(dsn="SBE_PRECINCTS_20170519",layer="Precincts2") %>%
  mutate(precinct_abbrv=as.character(PREC_ID)) %>%
  rename(county_id=COUNTY_ID)

NCCounty <- NCPrecinct %>% group_by(COUNTY_NAM) %>%
  summarise(county_id=mean(county_id)) %>%
  mutate(COUNTY_NAM=str_to_title(COUNTY_NAM))

saveRDS(NCCounty, "app/NCCounty.rds")
