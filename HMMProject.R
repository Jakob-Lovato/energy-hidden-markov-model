#data from https://www.kaggle.com/datasets/nicholasjhana/energy-consumption-generation-prices-and-weather
# Fall 2022, Stat 793- Independent Study on Hidden Markov Models

library(HMM)
library(markovchain)
library(magrittr)
library(dplyr)

#import data
weather <- read.csv("/Users/jakoblovato/Desktop/Stat 793/Final Project/archive/weather_features.csv", header = TRUE)
energy <- read.csv("/Users/jakoblovato/Desktop/Stat 793/Final Project/archive/energy_dataset.csv", header = TRUE)

#select only relevant features, convert temp to farenheit, remove whitespace from city names
#total.load.actual is in megawatts
weather <- weather %>% 
  select(dt_iso, city_name, temp, humidity, weather_main) %>%
  rename(time = dt_iso) %>%
  mutate(temp = round((temp - 273.15) * 1.8) + 32) %>% #convert kelvin to farenheit and round
  mutate_if(is.factor, as.character) %>%
  mutate(city_name = trimws(city_name)) #remove whitespace from " Barcelona"

#there was one duplicate, remove it
weather <- weather[!duplicated(weather), ]

#select only total energy load, what we will use as the observable state in the HMM
energy <- energy %>% 
  select(time, total.load.actual)

#merge into single dataframe
data <- merge(weather, energy, by.x = "time") %>% na.omit()

#add new feature splitting total.energy.load into quantiles so there aren't thousands of observable states
range01 <- function(x){(x - min(x)) / (max(x) - min(x))}

data <- data %>% 
  mutate(energy_decile = round(range01(data$total.load.actual), 1) * 10) 

#add features for temp and humidity deciles to adress same problem of too many observable states
data <- data %>% 
  mutate(temp_decile = round(range01(data$temp), 1) * 10) %>%
  mutate(humidity_decile = round(range01(data$humidity), 1) * 10)


#save this new dataset to a file for safe-keeping
write.csv(data, file = "weather_energy_HMM.csv", row.names = FALSE, quote = FALSE, col.names = TRUE)


# Functions to create HMM and plot


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

A <- createA(data, "Barcelona", "temp_decile")
B <- createB(data, "Barcelona", "temp_decile")

hmm <- initHMM(States = as.character(sort(unique(barcelona$temp_decile))),
               Symbols = as.character(sort(unique(barcelona$energy_decile))),
               transProbs = A,
               emissionProbs = B)

pred_path <- viterbi(hmm, as.character(barcelona$energy_decile[1:1920]))
true_path <- barcelona$energy_decile[1:1920] %>% as.character

library(ggplot2)
library(reshape2)




ggplot(as.data.frame(cbind(1:length(pred_path), as.numeric(pred_path))), aes(x = V1, y = 100, fill = factor(V2), height = 100)) +
  geom_tile() +
  geom_tile(as.data.frame(cbind(1:length(true_path), as.numeric(true_path))), mapping = aes(x = V1, y = -100, fill = factor(V2)), height = 100) +
  coord_fixed(ratio = 1) +
  scale_fill_viridis_d(option = "rocket") +
  theme(panel.background = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "transparent"),
        legend.position = "none"
  )



A <- createA(data, "Barcelona", "weather_main")
B <- createB(data, "Barcelona", "weather_main")

barcelona <- data %>% filter(city_name == "Barcelona") %>% select(weather_main, energy_decile)

hmm <- initHMM(States = as.character(sort(unique(barcelona$weather_main))),
               Symbols = as.character(sort(unique(barcelona$energy_decile))),
               transProbs = A,
               emissionProbs = B)

pred_path <- viterbi(hmm, as.character(barcelona$energy_decile[1:1920]))
true_path <- barcelona$weather_main[1:1920] %>% as.character

ggplot(as.data.frame(cbind(1:length(pred_path), as.numeric(as.factor(pred_path)))), aes(x = V1, y = 100, fill = factor(V2), height = 100)) +
  geom_tile() +
  geom_tile(as.data.frame(cbind(1:length(true_path), as.numeric(as.factor(true_path)))), mapping = aes(x = V1, y = -100, fill = factor(V2)), height = 100) +
  coord_fixed(ratio = 1) +
  scale_fill_viridis_d(option = "rocket") +
  theme(panel.background = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "transparent"),
        legend.position = "none"
  )



