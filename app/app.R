#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)



library(tidyverse)
library(sf)
library(glue)

MapData <- readRDS("VoterDataWithMap.rds") %>%
  mutate(COUNTY_NAM=str_to_title(COUNTY_NAM))

counties <- c("All", MapData %>% pull(COUNTY_NAM) %>% unique() %>% sort())
# counties <- MapData %>% pull(COUNTY_NAM) %>% unique() %>% sort()

CountyMapData <- readRDS("NCCounty.rds")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Registered Voters by Precinct"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("countySelect",
                  "County:",
                  choices=counties,
                  selected="Durham"
      ),
      selectInput("variable",
                  "Variable:",
                  choices=c("Age", "Gender", "Party", "Race/Ethnicity", "Registered Voters", "Gender (Imputed)")
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
  
  MapDataCounty <- reactive({
    if (input$countySelect != "All"){
      MapData %>% filter(COUNTY_NAM==input$countySelect)
    } else{
      MapData
    }
  })
  
  MapDataCountyBoundary <- reactive({
    if (input$countySelect != "All"){
      CountyMapData %>% filter(COUNTY_NAM==input$countySelect)
    } else{
      CountyMapData
    }
  })
  
  MapDataVariable <-reactive({
    MapDataCounty() %>% filter(variable==input$variable)
  })
  
  MapDataSelect <- reactive({
    MapDataVariable() %>% filter(
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
    } else if(input$variable=="Gender (Imputed)"){
      updateSelectInput(session, "stat", choices = c("Percent", "Number"))
      updateSelectInput(session, "level", 
                        choices = c("Female", "Male"))
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
    if (input$stat=="Percent" & input$variable!="Gender (Imputed)"){
      ggplot() +
        geom_sf(data=MapDataSelect(), aes_string(fill=input$stat), colour=NA) +
        guides(fill=guide_legend(title=legendlabel())) +
        scale_fill_gradient(low="white", high="darkblue", limits=c(0,100))+
        geom_sf(data=MapDataCountyBoundary(), fill=NA, colour="black")
      
    } else if (input$variable=="Age"){
      ggplot() +
        geom_sf(data=MapDataSelect(), aes_string(fill=input$stat), colour=NA) +
        guides(fill=guide_legend(title=legendlabel())) +
        scale_fill_gradient(low="white", high="darkblue", limits=c(18,120))+
        geom_sf(data=MapDataCountyBoundary(), fill=NA, colour="black")
    } else if (input$variable=="Gender (Imputed)" & input$stat=="Percent"){
      ggplot() +
        geom_sf(data=MapDataSelect(), aes_string(fill=input$stat), colour=NA) +
        guides(fill=guide_legend(title=legendlabel())) +
        scale_fill_gradient(low="white", high="darkblue", limits=c(25,75))+
        geom_sf(data=MapDataCountyBoundary(), fill=NA, colour="black")
    } else{
      ggplot() +
        geom_sf(data=MapDataSelect(), aes_string(fill=input$stat), colour=NA) +
        guides(fill=guide_legend(title=legendlabel())) +
        scale_fill_gradient(low="white", high="darkblue")+
        geom_sf(data=MapDataCountyBoundary(), fill=NA, colour="black")
    }
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

