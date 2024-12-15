library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
library(tidyverse)

options("readr.edition" = 1) 

employment_2022 <- readRDS("./dataset/Cleaned_Employment2022.rds")
employment_2017 <- readRDS("./dataset/Cleaned_Employment2017.rds")

CBSA_2022 <- unique(employment_2022$CBSA)
CBSA_2017 <- unique(employment_2017$CBSA)

colnames(employment_2017) <- toupper(colnames(employment_2017))
colnames(employment_2022) <- toupper(colnames(employment_2022))

CBSA <- sort(unique(c(CBSA_2022, CBSA_2017)))

race_mapping <- c(
  "White" = "WHT",
  "Black or African American" = "BLKT",
  "Hispanic" = "HISPT",
  "Asian" = "ASIANT",
  "American Indian or Alaska Native" = "AIANT",
  "Native Hawaiian or Other Pacific Islander" = "NHOPIT",
  "Two or More Races" = "TOMRT"
)

job_type_mapping <- list(
  "Senior Off and Managers" = c("WHT1", "BLKT1", "HISPT1", "ASIANT1", "AIANT1", "NHOPIT1", "TOMRT1"),
  "Professionals" = c("WHT2", "BLKT2", "HISPT2", "ASIANT2", "AIANT2", "NHOPIT2", "TOMRT2"),
  "Technicians" = c("WHT3", "BLKT3", "HISPT3", "ASIANT3", "AIANT3", "NHOPIT3", "TOMRT3"),
  "Sales Workers" = c("WHT4", "BLKT4", "HISPT4", "ASIANT4", "AIANT4", "NHOPIT4", "TOMRT4"),
  "Clericals" = c("WHT5", "BLKT5", "HISPT5", "ASIANT5", "AIANT5", "NHOPIT5", "TOMRT5"),
  "Craft" = c("WHT6", "BLKT6", "HISPT6", "ASIANT6", "AIANT6", "NHOPIT6", "TOMRT6"),
  "Operatives" = c("WHT7", "BLKT7", "HISPT7", "ASIANT7", "AIANT7", "NHOPIT7", "TOMRT7"),
  "Laborers" = c("WHT8", "BLKT8", "HISPT8", "ASIANT8", "AIANT8", "NHOPIT8", "TOMRT8"),
  "Services" = c("WHT9", "BLKT9", "HISPT9", "ASIANT9", "AIANT9", "NHOPIT9", "TOMRT9"),
  "Mid Off and Managers" = c("WHT1_2", "BLKT1_2", "HISPT1_2", "ASIANT1_2", "AIANT1_2", "NHOPIT1_2", "TOMRT1_2")
)

ui <- fluidPage(
  titlePanel("US Employment Data Trends (2017 vs 2022)"),
  sidebarLayout(
    sidebarPanel(
      selectInput("CBSA", "Select CBSA:", choices = CBSA),
      selectInput("race", "Select Race:", choices = names(race_mapping))
    ),
    mainPanel(
      fluidRow(
        column(6, plotOutput("employment_plot_2017")),
        column(6, plotOutput("employment_plot_2022"))
      )
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    validate(
      need(nrow(employment_2017) > 0, "2017 dataset failed to load."),
      need(nrow(employment_2022) > 0, "2022 dataset failed to load.")
    )
    
    selected_race_code <- race_mapping[input$race]
    
    selected_job_columns <- unlist(lapply(job_type_mapping, function(job) grep(selected_race_code, job, value = TRUE)))
    
    process_data <- function(dataset, year) {
      selected_data <- dataset %>%
        { if (input$CBSA != "") filter(., CBSA == input$CBSA) else . } %>%  
        select(all_of(selected_job_columns))  
      
      if (ncol(selected_data) == 0) {
        return(data.frame())  
      }
      
      selected_data %>%
        mutate(across(everything(), ~ as.numeric(as.character(.)))) %>%
        summarise(across(everything(), sum, na.rm = TRUE)) %>%
        pivot_longer(cols = everything(), names_to = "Job_Type", values_to = "Total_Employment") %>%
        mutate(
          Job_Type = sub("\\d+$", "", Job_Type),
          Year = year
        )
    }
    
    employment_data_2017 <- process_data(employment_2017, 2017)  
    employment_data_2022 <- process_data(employment_2022, 2022)
    
    combined_data <- bind_rows(employment_data_2017, employment_data_2022)
    
    validate(
      need(nrow(combined_data) > 0, "No data available for the selected CBSA or race.")
    )
    
    combined_data
  })
  
  output$employment_plot_2017 <- renderPlot({
    data <- filtered_data() %>%
      filter(Year == 2017)  
    
    plot_title <- paste("Employment in 2017 for", input$CBSA, "and", input$race)
    
    ggplot(data, aes(x = Job_Type, y = Total_Employment, fill = Job_Type)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(
        title = ifelse(input$CBSA != "", plot_title, paste("Employment in 2017 for", input$race)),
        x = "Job Type",
        y = "Total Employment"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  output$employment_plot_2022 <- renderPlot({
    data <- filtered_data() %>%
      filter(Year == 2022)  # Filter for 2022 data
    
    plot_title <- paste("Employment in 2022 for", input$CBSA, "and", input$race)
    
    ggplot(data, aes(x = Job_Type, y = Total_Employment, fill = Job_Type)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(
        title = ifelse(input$CBSA != "", plot_title, paste("Employment in 2022 for", input$race)),
        x = "Job Type",
        y = "Total Employment"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
}

shinyApp(ui = ui, server = server)