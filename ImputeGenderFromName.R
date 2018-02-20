library(tidyverse)
library(naniar)

NameData <- readRDS("VoterNames.rds")

NameDataSetup <- NameData %>% 
  ungroup() %>% mutate(ID=row_number()) %>%
  arrange(first_name, birth_year) %>%
  replace_with_na(replace=list(gender_code = "U")) %>% 
  group_by(birth_year) %>%
  mutate(PctFemaleYear=mean(gender_code=="F", na.rm=T)) %>%
  ungroup() %>% group_by(first_name) %>%
  mutate(PctFemaleName=mean(gender_code=="F", na.rm=T),
         NName=sum(!is.na(gender_code))) %>%
  ungroup() %>% group_by(first_name, birth_year) %>%
  mutate(PctFemaleNameYear=mean(gender_code=="F", na.rm=T),
         NNameYear=sum(!is.na(gender_code))) 
  

NameDataImp <-
  NameDataSetup %>% ungroup() %>%
  mutate(
    PctImpute=case_when(
      (!is.na(gender_code) & gender_code=="F")~1,
      (!is.na(gender_code) & gender_code=="M")~0,
      (NNameYear>=5)~PctFemaleNameYear,
      (NName >=5)~PctFemaleName,
      T ~PctFemaleYear
    ),
    CoinFlip=rbinom(n(), 1, PctImpute),
    gender_code_imp=if_else(CoinFlip==1, "F", "M")
  )

    
GenderByGeo <- NameDataImp %>%
  group_by(county_id, precinct_desc, precinct_abbrv) %>%
  summarize(
    PctFemaleRaw=mean(gender_code=="F", na.rm=T),
    PctFemaleImp=mean(gender_code_imp=="F"),
    PctDiff=abs(PctFemaleRaw-PctFemaleImp)
  )

ggplot(data=GenderByGeo, aes(x=PctFemaleRaw, y=PctFemaleImp)) +
  geom_point() + geom_abline(aes(intercept=0, slope=1), colour="red")

GenderImpSummary <- NameDataImp %>%
  filter(!is.na(precinct_abbrv)) %>%
  group_by(county_id, precinct_desc, precinct_abbrv) %>%
  summarise(
    Female=sum(gender_code_imp=="F"),
    Male=sum(gender_code_imp=="M")
  ) %>% 
  gather(Female, Male, key="level", value="Number") %>%
  mutate(Percent=Number/sum(Number)*100,
         variable="Gender (Imputed)") %>%
  arrange(county_id, precinct_desc, precinct_abbrv)

saveRDS(GenderImpSummary, "GenderImpSummary.rds")
