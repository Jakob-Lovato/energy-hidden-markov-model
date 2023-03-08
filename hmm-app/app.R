#HMM App
library(HMM)
library(markovchain)
library(magrittr)
library(dplyr)
library(ggplot2)
library(reshape2)
library(shiny)

### Helper functions and data loading

data <- read.csv("weather_energy_HMM.csv", header = TRUE)

data <- data %>% mutate_if(is.factor, as.character)

createA <- function(data, city, states){
  city_data <- data %>% filter(city_name == city) %>% select(states)
  A <- createSequenceMatrix(city_data, toRowProbs = TRUE)
  return(A)
}

createB <- function(data, city, states){
  city_data <- data %>% filter(city_name == city) %>% select(states, energy_decile)
  B <- table(city_data[,1], city_data[,2])
  B <- B / rowSums(B)
  return(B)
}


### Create app

ui <- fluidPage(
  title = "Energy Hidden Markov Model",
  
  titlePanel(h1("Energy Hidden Markov Model")),
  
  sidebarLayout(
    
    sidebarPanel(
      
      selectInput(inputId = "city",
                  label = "Select City",
                  choices = c("Barcelona", "Bilbao", "Madrid", "Valencia", "Seville")),
      
      selectInput(inputId = "weather",
                  label = "Select Weather Feature",
                  choices = list("Temperature" = "temp_decile",
                                 "Humidity" = "humidity_decile")),
      
      numericInput(inputId = "numDays",
                   label = "Select Number of Days",
                   value = 20,
                   min = 1,
                   max = 100),
      
      tags$a(
        href="https://github.com/Jakob-Lovato/energy-hidden-markov-model", 
        tags$img(src="github_logo.png",
                 height = "30"),
        tags$text("View project on Github")
      )
      
    ),
    
    mainPanel(
      
      p("A Hidden Markov Model is a statistical model in which the underlying system is assumed
        to be a Markov Chain. This underlying system is assumed to be unobservable, and the states
        of the model influence some observable states. Using the Viterbi Algorithm, a prediction 
        can be made as to the most probably sequence of hidden states based on the sequence of
        observable states."),
      
      p("Data was collected from 5 cities in Spain from 2015 through 2018, keeping track of
        weather conditions in each city and the total load on the energy grid in Spain. Using
        a Hidden Markov Model, this app shows the true path of a (randomly picked) sequence of time
        and predicts the weather patterns based on the total load on the Spanish energy grid using
        the Viterbi algorithm. Comparing true and predicted weather features can show how well each
        weather feature is best predicted by the total load on the Spanish energy grid. Note: the values
        of the weather features (temperature, humidity) have been discretised into 10 segments. Hence,
        actual temperature/humidity percentage is not shown, as the purpose of this tool is to predict
        and display general trends in the weather, as opposed to exact values."),
      
      p("Instructions: In the panel to the left, select the city you would like to see the predicted
        weather sequence for, then select the weather feature you would like to predict, and finally
        the number of days you would like to have predicted. A plot will be produced showing the true
        sequence of weather in blue, and the predicted sequence for the same dates in orange."),
      
      plotOutput(outputId = "plot")
      
    )
  )
)


# Server Logic
server <- function(input, output){
  
  lowerTime <- reactiveVal()
  upperTime <- reactiveVal()
  
  output$plot <- renderPlot({
    city <- input$city
    weather <- input$weather
    numDays <- input$numDays
    A <- createA(data, city, weather)
    B <- createB(data, city, weather)
    city_data <- data %>% filter(city_name == city) %>% select(weather, energy_decile)
    hmm <- initHMM(States = as.character(sort(unique(city_data[,1]))),
                   Symbols = as.character(sort(unique(city_data[,2]))),
                   transProbs = A,
                   emissionProbs = B)
    #if(weather == "weather_main"){weather <- as.factor(weather)}
    lowerTime <- round(runif(1, min = 1, max = nrow(city_data) - (numDays * 24)))
    upperTime <- lowerTime + (numDays * 24)
    pred_path <- viterbi(hmm, as.character(city_data[lowerTime:upperTime, 2]))
    true_path <- as.character(city_data[lowerTime:upperTime, 1])
    
    
    
    # ggplot(as.data.frame(cbind(1:length(pred_path), Weather = as.numeric(as.factor(pred_path)), labels = pred_path)), aes(x = V1, y = 100, fill = factor(Weather), height = 100)) +
    #   geom_tile() +
    #   geom_tile(as.data.frame(cbind(1:length(true_path), Weather = as.numeric(as.factor(true_path)), labels = true_path)), mapping = aes(x = V1, y = -100, fill = factor(Weather)), height = 100) +
    #   coord_fixed(ratio = 1) +
    #   scale_fill_viridis_d(option = "rocket", direction = -1) +
    #   #scale_fill_discrete(type = "viridis",
    #   #                      labels = unique(true_path)) +
    #   labs(title = "Top: Predicted Path \nBottom: True Path") +
    #   theme(panel.background = element_blank(),
    #         axis.title = element_blank(),
    #         axis.text = element_blank(),
    #         axis.ticks = element_blank(),
    #         axis.line = element_blank(),
    #         panel.grid.major = element_blank(),
    #         panel.grid.minor = element_blank(),
    #         plot.background = element_rect(fill = "transparent"),
    #         legend.position = "bottom"
    
    ggplot(as.data.frame(cbind(1:length(pred_path), Weather = as.numeric(as.factor(pred_path)))), aes(x = V1, y = Weather, color = "Blue")) +
      geom_line(size = 1.1) +
      geom_line(as.data.frame(cbind(1:length(true_path), Weather = as.numeric(as.factor(true_path)))), mapping = aes(x = V1, y = Weather, color = "Green"), size = .75) +
      #coord_fixed(ratio = 1) +
      #scale_fill_viridis_d(option = "rocket", direction = -1) +
      #scale_fill_discrete(type = "viridis",
      #                      labels = unique(true_path)) +
      labs(title = "Orange: Predicted Path \nBlue: True Path") +
      theme(panel.background = element_blank(),
            axis.title = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            #axis.line = element_blank(),
            #panel.grid.major = element_blank(),
            #panel.grid.minor = element_blank(),
            plot.background = element_rect(fill = "transparent"),
            legend.position = "none"
    
    )
    
  })
  
}

# Run App
shinyApp(ui, server)