This package scrapes data from fitbit.com  
It only works if you use email / password to login. Not sure about facebook or google login.  

Usage:  

```R
devtools::install_github("corynissen/fitbitScraper")  
library("fitbitScraper")

cookie <- login(email="corynissen@gmail.com", password="mypassword")  
# 15_min_data "what" options: "steps", "distance", "floors", "active-minutes", "calories-burned"   
df <- get_15_min_data(cookie, what="steps", date="2015-01-21")  
library("ggplot2")  
ggplot(df) + geom_bar(aes(x=time, y=data, fill=data), stat="identity") + 
             xlab("") +ylab("steps") + 
             theme(axis.ticks.x=element_blank(), 
                   panel.grid.major.x = element_blank(), 
                   panel.grid.minor.x = element_blank(), 
                   panel.grid.minor.y = element_blank(), 
                   panel.background=element_blank(), 
                   panel.grid.major.y=element_line(colour="gray", size=.1), 
                   legend.position="none") 

# daily_data "what" options: "steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake"   
df <- get_daily_data(cookie, what="steps", start_date="2015-01-13", end_date="2015-01-20")  
ggplot(df) + geom_point(aes(x=time, y=data))  
```

