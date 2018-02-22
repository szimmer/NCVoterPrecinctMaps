library(tidyverse)

VoteRaw <- read_tsv("ncvoter_Statewide.txt") 

VoteSlim <- VoteRaw %>% 
  select(race_code:birth_age,
         birth_year, name_prefx_cd:name_suffix_lbl ,
         county_id, precinct_desc, precinct_abbrv)

names(VoteSlim)

saveRDS(VoteSlim, "VoterNames.rds")
