This package scrapes data from fitbit.com  

Usage:  

devtools::install_github("corynissen/fitbitScraper")  
library("fitbitScraper")
cookie <- login(email="corynissen@gmail.com", password="mypassword")  
df <- get_15_min_data(cookie, what="steps", date="2015-01-21")  

library("ggplot2")  
ggplot(df) + geom_point(aes(x=time, y=data))
