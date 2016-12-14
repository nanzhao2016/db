library(ggplot2)
library(dplyr)
library(graphics)
library(MASS)
library(car)
library(Metrics) # rmsle
library(stats) # glm
library(mgcv)
library(vegan)
library(randomForest)
library(rfUtilities)
library(caret)
library(e1071)
set.seed(123)
setwd("~/NanZHAO/Formation_BigData/Memoires/tmp/db")

data1 = read.csv2("table_country_company_contract.csv")
group <- group_by(data1, country)
summary1 <- summarise(group, 
            sum_contract = n())

data2 = read.csv2("table_country_company_contract_name.csv")
group <- group_by(data2, country, contract_name)
summary2 <- summarise(group, 
                      stations = n())
ggplot(data2, aes(contract_name)) +
  geom_bar()+
  facet_wrap(~country, scale="free")

data3 = read.csv2("table_country_company_contract_name_bonus.csv") 

ggplot(data3, aes(contract_name, fill=bonus)) +
  geom_bar()+
  theme(axis.text.x = element_text(size=8, angle=45, vjust = 0.6),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        title = element_text(size=12, face = "bold"))+
  ggtitle("Bike sharing systems in different countries")+
facet_wrap(~country, scale="free")
ggsave("~/NanZHAO/Formation_BigData/Memoires/images/bikestation_countries.jpg", device = "jpg",  width = 20, height = 15, units = "cm", limitsize = FALSE)

ggplot(filter(data3, country %in% ("France")), aes(contract_name, fill=bonus)) +
  geom_bar() + 
  ylab("The number of bicycle staitions") +
  xlab("City names") +
  theme(axis.text.x = element_text(size=10, angle=45, vjust = 0.6),
        axis.title.x = element_text(size=12, face = "bold"),
        axis.title.y = element_text(size=12, face = "bold"),
        title = element_text(size=12, face = "bold"))+
  ggtitle("Bike sharing systems in France")
  ggsave("~/NanZHAO/Formation_BigData/Memoires/images/bikestation_france.jpg", device = "jpg",  width = 15, height = 10, units = "cm", limitsize = FALSE)
  
  data4 = read.csv2("table_country_company_contract_name_bonus_banking_status_bikestands.csv")
  
  sub = filter(data4, contract_name=="Paris")
  ggplot( filter(data4, contract_name=="Paris"), aes(bike_stands, fill=bonus)) +
    geom_histogram(binwidth = 1)
  
  ggplot( filter(data4), aes(bike_stands, fill=bonus)) +
    geom_histogram(binwidth = 1)
  
  ggplot(data4, aes(country, bike_stands))+
    geom_boxplot() 
  
  ggplot(filter(data4, country=="France"), aes(contract_name, bike_stands))+
    geom_boxplot(aes(fill=bonus)) 
  
  
  ggplot(filter(data4, country=="France"), aes(country))+
    geom_bar(aes(fill=contract_name)) 
  
  
library(shiny)
  
  ui <- fluidPage(
        sliderInput(inputId = "num",
                    label = "Choose a number",
                    value = 25, min=1, max=100),
        plotOutput(outputId = "hist")
                  )
  server <- function(input, output){
    output$hist <- renderPlot({
      title <- "Random normal values"
      hist(rnorm(input$num), main=title)
      })
  }
  shinyApp(ui=ui, server=server)
  
 ################################################################################################### 
  ui <- fluidPage(
    sidebarPanel(
      selectInput(inputId = "country", "Choose a country name",
                  choices = c("Australia",  "Belgium", "France",  "IRELAND", "JAPAN", "Lithuania",  "Luxembourg", 
                  "Norway", "Russia", "Slovenia", "Spain", "Sweden", "No difference")),
      submitButton("Update View")
    ),
    
    mainPanel(
      h4("Boxplot of number of bicycles in country  "),
      plotOutput(outputId = "boxplot")
    )
    
  )
  
  server <- function(input, output){
    
    datasetInput <- reactive({
      switch(input$country,
             "Australia" = filter(data4, country=="Australia"),  
             "Belgium" =  filter(data4, country=="Belgium"), 
             "France" = filter(data4, country=="France"),  
             "IRELAND" = filter(data4, country=="IRELAND"), 
             "JAPAN" = filter(data4, country=="JAPAN"), 
             "Lithuania" = filter(data4, country=="Lithuania"),  
             "Luxembourg"= filter(data4, country=="Luxembourg"), 
             "Norway" = filter(data4, country=="Norway"), 
             "Russia" = filter(data4, country=="Russia"), 
             "Slovenia" = filter(data4, country=="Slovenia"), 
             "Spain" = filter(data4, country=="Spain"), 
             "Sweden" = filter(data4, country=="Sweden"),
             "No difference" = data4
             )
    })
    
    output$boxplot <- renderPlot({
      
     
      dataset <- datasetInput()
      ggplot(dataset, aes(country, bike_stands))+
        geom_boxplot() +
        ylab("The number of bycicles in each staition") +
        xlab("Country names")+
        theme(axis.text.x = element_text(size=12),
              axis.text.y = element_text(size=12),
              axis.title.x = element_text(size=12, face = "bold"),
              axis.title.y = element_text(size=12, face = "bold"),
              title = element_text(size=12, face = "bold"))
    
      })
  }
  shinyApp(ui=ui, server=server)
  
  ################################################################################################### 
  ui <- fluidPage(
    sidebarPanel(
      selectInput(inputId = "country", "Choose a country name",
                  choices = c("Australia",  "Belgium", "France",  "IRELAND", "JAPAN", "Lithuania",  "Luxembourg", 
                              "Norway", "Russia", "Slovenia", "Spain", "Sweden")),
      submitButton("Update View")
    ),
    
    mainPanel(
      h4("Boxplot of number of bicycles in country"),
      plotOutput(outputId = "boxplot"),
      
      h4("Summary"),
      #verbatimTextOutput(outputId = "summary")
      tableOutput(outputId = "summary")
    )
    
  )
  
  server <- function(input, output){
    
    datasetInput <- reactive({
      switch(input$country,
             "Australia" = filter(data4, country=="Australia"),  
             "Belgium" =  filter(data4, country=="Belgium"), 
             "France" = filter(data4, country=="France"),  
             "IRELAND" = filter(data4, country=="IRELAND"), 
             "JAPAN" = filter(data4, country=="JAPAN"), 
             "Lithuania" = filter(data4, country=="Lithuania"),  
             "Luxembourg"= filter(data4, country=="Luxembourg"), 
             "Norway" = filter(data4, country=="Norway"), 
             "Russia" = filter(data4, country=="Russia"), 
             "Slovenia" = filter(data4, country=="Slovenia"), 
             "Spain" = filter(data4, country=="Spain"), 
             "Sweden" = filter(data4, country=="Sweden")
      )
    })
    
    output$boxplot <- renderPlot({
      dataset <- datasetInput()
      ggplot(dataset, aes(contract_name, bike_stands))+
        geom_boxplot(aes(fill=bonus)) +
        ylab("The number of bycicles in each staition") +
        xlab("Contract names")+
        theme(axis.text.x = element_text(size=12),
              axis.text.y = element_text(size=12),
              axis.title.x = element_text(size=12, face = "bold"),
              axis.title.y = element_text(size=12, face = "bold"),
              title = element_text(size=12, face = "bold"))
      
    })
    
    
    output$summary <- renderTable({
      
      dataset <- datasetInput()
      summarise(group_by(dataset, contract_name), number_of_stations=length(unique(name)))

    })
  }
  shinyApp(ui=ui, server=server)
  