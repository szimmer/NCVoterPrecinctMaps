library(tidyverse)
library(sf)
library(naniar)
VoteRecords <- readRDS("ActiveVoters.rds")

checkRaceCode <- VoteRecords %>% ungroup() %>% 
  count(RaceEth, race_code, ethnic_code) %>%
  print(n=50)

VoteRecords %>% ungroup() %>% count(party_cd)
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
  # gather(Number, Percent, key="stat", value="value") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

VoteRecords %>% ungroup() %>% count(gender_code)
GenderSummary <- VoteRecords %>%
  summarise(
    Female=sum(gender_code=="F"),
    Male=sum(gender_code=="M"),
    Undesignated=sum(gender_code=="U"|is.na(gender_code))
  ) %>% 
  gather(Female, Male, Undesignated, key="level", value="Number") %>%
  mutate(Percent=Number/sum(Number)*100,
         variable="Gender") %>%
  # gather(Number, Percent, key="stat", value="value") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

VoteRecords %>% ungroup() %>% select(birth_age) %>% arrange(desc(birth_age)) %>%
  print()

AgeSummary <- VoteRecords %>%
  mutate(birth_age=ifelse(birth_age <= 121, birth_age, NA)) %>%
  summarise(
    Mean=mean(birth_age),
    Median=median(birth_age),
    Min=min(birth_age),
    Max=max(birth_age)
  ) %>% 
  # gather(Mean, Median, Min, Max, key="stat", value="value") %>%
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
  # gather(Number, Percent, key="stat", value="value") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

PopSummary <- VoteRecords %>% 
  summarise(value=n()) %>%
  # mutate(variable="Registered Voters",
  #        stat="Number",
  #        level="NA")
  mutate(Number=value, level="NA", variable="Registered Voters") %>%
  select(-value)

GenderImpSummary <- read_rds("GenderImpSummary.rds")

PrecinctSummaryData <- bind_rows(
  AgeSummary,
  GenderSummary,
  PartySummary,
  RaceEthSummary,
  PopSummary,
  GenderImpSummary
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
saveRDS(filter(MapData, county_id==32), "app/VoterDataWithMapDurham.rds")
