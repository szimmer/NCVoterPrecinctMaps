#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
# to use the geom_sf, need to install this branch of ggplot2
library(devtools)
devtools::install_github("tidyverse/ggplot2", ref="sf")
library(tidyverse)
library(sf)
library(glue)

MapData <- readRDS("VoterDataWithMap.rds") %>% 
  filter(COUNTY_NAM=="DURHAM")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Durham Registered Voters by Precinct"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("variable",
                  "Variable:",
                  choices=c("Age", "Gender", "Party", "Race/Ethnicity", "Registered Voters")
      ),
      selectInput("stat",
                  "Statistic:",
                  choices=c("Mean", "Median", "Min", "Max")
      ),
      selectInput("level",
                  "Level:",
                  choices=c("NA")
      )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("mapOut")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  MapDataVariable <-reactive({
    MapData %>% filter(variable==input$variable)
  })
  
  MapDataStat <- reactive({
    MapDataVariable() %>% filter(
      stat==input$stat
    ) 
  })
  
  MapDataSelect <- reactive({
    MapDataStat() %>% filter(
      level %in% c(input$level)
    )
  })
  
  observeEvent(input$variable,{
    if (input$variable == "Age"){
      updateSelectInput(session, "level", choices = "NA")
      updateSelectInput(session, "stat",
                        choices = c("Mean", "Median", "Min", "Max"))
    } else if (input$variable=="Gender") {
      updateSelectInput(session, "stat", choices = c("Percent", "Number"))
      updateSelectInput(session, "level", 
                        choices = c("Female", "Male", "Undesignated"))
    } else if (input$variable=="Party") {
      updateSelectInput(session, "stat", choices = c("Percent", "Number"))
      updateSelectInput(session, "level", 
                        choices = c("Democrat", "Libertarian", "Republican", "Unaffiliated"))
    } else if (input$variable=="Race/Ethnicity"){
      updateSelectInput(session, "stat", choices = c("Percent", "Number"))
      updateSelectInput(session, "level", 
                        choices = c("White", "Black", "Hispanic", "Other", "Unknown"))
    } else if (input$variable=="Registered Voters"){
      updateSelectInput(session, "stat", choices = "Number")
      updateSelectInput(session, "level", choices = "NA")
      
    }
  })
  
  legendlabel <- reactive({
    if (input$level != "NA"){
      return(glue('{input$stat} {input$variable}:\n {input$level}' ))
    } else{
      return(glue('{input$stat} {input$variable}' ))
    }
    
  })
  
  output$mapOut <- renderPlot({
    ggplot(MapDataSelect(), aes(fill=value)) +
      geom_sf() +
      guides(fill=guide_legend(title=legendlabel()))
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

