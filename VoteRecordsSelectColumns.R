library(tidyverse)

VoteRaw <- read_tsv("ncvoter_Statewide.txt") 

VoteRecords <- VoteRaw %>% 
  mutate(RaceEth=case_when(
    ethnic_code=="HL" ~ "Hispanic",
    race_code=="W" ~ "White",
    race_code=="B" ~ "Black",
    race_code %in% c("I", "O","A","M") ~ "Other",
    TRUE ~ "Unknown"
  )) %>% 
  select(county_id, status_cd:absent_ind, race_code:birth_state,
         registr_dt:municipality_desc, confidential_ind, birth_year,
         RaceEth) %>% 
  arrange(desc(confidential_ind)) %>% 
  filter(status_cd=="A",!is.na(precinct_desc)) %>%
  group_by(county_id, precinct_desc, precinct_abbrv) 

names(VoteRecords)

VoteRecordsSlim <- VoteRecords %>% 
  select(county_id, race_code:birth_age, precinct_abbrv:municipality_abbrv,
         birth_year, RaceEth)

names(VoteRecordsSlim)

saveRDS(VoteRecordsSlim, "ActiveVoters.rds")
# write_csv(VoteRecordsSlim, "ActiveVoters.csv") - 
# this creates a much larger file and is a flat file which 
# means more manipulation when reading back in
