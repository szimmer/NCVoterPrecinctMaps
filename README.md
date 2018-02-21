# NCVoterPrecinctMaps
Mapping public electoral rolls in North Carolina

# The data
The data comes from the NC board of elections. ncvoter_Statewide.zip was most recently downloaded on February 11, 2018 at http://dl.ncsbe.gov/index.html?prefix=data/ 

The shape file for precinct maps also comes from the NC board of elections. SBE_PRECINCTS_20170519.zip was most recently downloaded on February 11, 2018 at http://dl.ncsbe.gov/index.html?prefix=PrecinctMaps/ 

# Data processing
Data processing is done in the SummarizeVoterDataByPrecinct.R file. Only individuals with an active voter registration are included. Records with missing precincts are also omitted. 

The Race/Ethnicity variable was created as Hispanic if ethnic_code indicated Hispanic regardless of race. The number of Hispanic individuals was far less than expected due to missing in that figure.

The data summarized at the precinct level is merged onto precinct maps to create a sf file.

There is now a version of gender which is imputed using name. First, a donor for gender is chosen if there are at least 5 records with the same name in the same year with known gender, next a donor is looked for the same name in any year as long as donor pool is at least 5, finally the distribution of gender for the year is used to simulate a gender.

# Shiny App
Currently, the Shiny app is only plotting data for Durham County - selfishly becuase that's where I live but also because the state file is very large and it is being developed on a smaller set of data first. The Shiny app is deployed at https://stephanie-zimmer.shinyapps.io/NCVoterPrecinctMaps/