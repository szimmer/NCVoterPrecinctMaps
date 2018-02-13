library(tidyverse)
library(sf)
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

checkRaceCode <- VoteRecords %>% group_by(RaceEth, race_code, ethnic_code) %>%
  summarise(n=n()) %>% print(n=50)

table(VoteRecords$party_cd, useNA = "ifany")
PartySummary <- VoteRecords %>%
  summarise(
    Democrat=sum(party_cd=="DEM"),
    Libertarian=sum(party_cd=="LIB"),
    Republican=sum(party_cd=="REP"),
    Unaffiliated=sum(party_cd=="UNA")
  ) %>% 
  gather(Democrat, Libertarian, Republican, Unaffiliated, key="level", value="Number") %>%
  mutate(Percent=Number/sum(Number)*100,
         variable="Party") %>%
  gather(Number, Percent, key="stat", value="value") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

table(VoteRecords$gender_code, useNA = "ifany")
GenderSummary <- VoteRecords %>%
  summarise(
    Female=sum(gender_code=="F"),
    Male=sum(gender_code=="M"),
    Undesignated=sum(gender_code=="U"|is.na(gender_code))
  ) %>% 
  gather(Female, Male, Undesignated, key="level", value="Number") %>%
  mutate(Percent=Number/sum(Number)*100,
         variable="Gender") %>%
  gather(Number, Percent, key="stat", value="value") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

summary(VoteRecords$birth_age)

AgeSummary <- VoteRecords %>%
  summarise(
    Mean=mean(birth_age),
    Median=median(birth_age),
    Min=min(birth_age),
    Max=max(birth_age)
  ) %>% 
  gather(Mean, Median, Min, Max, key="stat", value="value") %>%
  mutate(variable="Age", level="NA") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

RaceEthSummary <- VoteRecords %>%
  summarise(
    White=sum(RaceEth=="White"),
    Black=sum(RaceEth=="Black"),
    Other=sum(RaceEth=="Other"),
    Unknown=sum(RaceEth=="Unknown"),
    Hispanic=sum(RaceEth=="Hispanic")
  ) %>% 
  gather(White, Black, Other, Unknown, Hispanic, key="level", value="Number") %>%
  mutate(Percent=Number/sum(Number)*100,
         variable="Race/Ethnicity") %>%
  gather(Number, Percent, key="stat", value="value") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

PopSummary <- VoteRecords %>% 
  summarise(value=n()) %>%
  mutate(variable="Registered Voters",
         stat="Number",
         level="NA")

PrecinctSummaryData <- bind_rows(
  AgeSummary,
  GenderSummary,
  PartySummary,
  RaceEthSummary,
  PopSummary
)

NCPrecinct <- st_read(dsn="SBE_PRECINCTS_20170519",layer="Precincts2") %>%
  mutate(precinct_abbrv=as.character(PREC_ID)) %>%
  rename(county_id=COUNTY_ID)

MapBys <- NCPrecinct %>% select(county_id, precinct_abbrv) %>% mutate(OnMap=1)
DataBys <- PrecinctSummaryData %>% select(county_id, precinct_abbrv, precinct_desc) %>% mutate(OnData=1)

trymerge <- full_join(MapBys, DataBys,
                      by=c("county_id", "precinct_abbrv"))

(probmerge <- trymerge %>% filter(is.na(OnMap)|is.na(OnData)) %>%
  arrange(county_id, precinct_abbrv))

MapData <- inner_join(NCPrecinct, PrecinctSummaryData, 
                      by=c("county_id", "precinct_abbrv"))

saveRDS(MapData, "app/VoterDataWithMap.rds")
