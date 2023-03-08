# energy-hidden-markov-model
Using a hidden markov model to predict weather trends based on energy consumption in Spain

Deployed as an interactive web app using R Shiny: https://jakoblovato.shinyapps.io/hidden-markov-model/

Data from: https://www.kaggle.com/datasets/nicholasjhana/energy-consumption-generation-prices-and-weather?select=weather_features.csv

A Hidden Markov Model is a statistical model in which the underlying system is assumed to be a Markov Chain. This underlying system is assumed to be unobservable, and the states of the model influence some observable states. Using the Viterbi Algorithm, a prediction can be made as to the most probably sequence of hidden states based on the sequence of observable states.

Data was collected from 5 cities in Spain from 2015 through 2018, keeping track of weather conditions in each city and the total load on the energy grid in Spain. Using a Hidden Markov Model, this app shows the true path of a (randomly picked) sequence of time and predicts the weather patterns based on the total load on the Spanish energy grid using the Viterbi algorithm. Comparing true and predicted weather features can show how well each weather feature is best predicted by the total load on the Spanish energy grid. Note: the values of the weather features (temperature, humidity) have been discretised into 10 segments. Hence, actual temperature/humidity percentage is not shown, as the purpose of this tool is to predict and display general trends in the weather, as opposed to exact values.

Different cities and weather features can be chosen to use the energy demand as a predictive feature to produce the most likely sequence of weather during that corresponding time.

For example, in this screenshot, temperature was selected as the feature to predict in Barcelona over a period of 40 days. The blue path shows the true path of temperature change during this period, and the orange path shows the predicted temperature path based on the energy demand during that time. We can see that in general, spikes and dips in the weather were predicted moderately accurately.

<img width="1013" alt="Screenshot 2023-03-08 at 12 21 32 PM" src="https://user-images.githubusercontent.com/106411094/223841339-96c20aa2-88a0-410b-b031-654398d359bd.png">

In the following screenshot, humidity was selected as the feature to predict in Bilbao over a period of 20 days. We see the temperature fluctuates much more drastically, and is harder to predict using the energy demand (though some trends in the regular dips and spikes somewhat match up). It appears that humidity is less accurately predicted.

<img width="1007" alt="image" src="https://user-images.githubusercontent.com/106411094/223841851-b6918497-097c-4b60-9914-c71d42f66ef2.png">

Clearly, a Hidden Markov Model using energy demand is likely not the best tool to retroactively predict weather patterns. However this is meant to be more of a fun interactive tool to compare which city/weather feature combination may produce the most accurate paths.

TODO: Add date-range selector instead of randomly picking date-range based on selected number of days.
