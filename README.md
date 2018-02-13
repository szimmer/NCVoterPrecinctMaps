# NCVoterPrecinctMaps
Mapping public electoral rolls in North Carolina

# The data
The data comes from the NC board of elections. ncvoter_Statewide.zip was most recently downloaded on February 11, 2018 at http://dl.ncsbe.gov/index.html?prefix=data/ 

The shape file for precinct maps also comes from the NC board of elections. SBE_PRECINCTS_20170519.zip was most recently downloaded on February 11, 2018 at http://dl.ncsbe.gov/index.html?prefix=PrecinctMaps/ 

# Data processing
Data processing is done in the SummarizeVoterDataByPrecinct.R file. Only individuals with an active voter registration are included. Records with missing precincts are also omitted. 

The Race/Ethnicity variable was created as Hispanic if ethnic_code indicated Hispanic regardless of race. The number of Hispanic individuals was far less than expected due to missing in that figure.

The data summarized at the precinct level is merged onto precinct maps to create a sf file.

# Shiny App
Currently, the Shiny app is only plotting data for Durham County - selfishly becuase that's where I live but also because the state file is very large and it is being developed on a smaller set of data first. The Shiny app is deployed at https://stephanie-zimmer.shinyapps.io/NCVoterMaps/ 