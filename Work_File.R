---
  title: "bellabeat Case Study"
author: "Tushar"
date: "`r Sys.Date()`"
output:
  html_document: default
pdf_document: default
word_document: default
---
  #######################################################
## Installed and loaded common packages and libraries ##
#######################################################

```{r}
options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages('tidyverse')
library(tidyverse)
```

######################################################################
## Loaded CSV files from the dataset ##
### Created a dataframe named 'daily_activity', 'sleep_day' and read in as the CSV files from the dataset.##
######################################################################

```{r}
daily_activity <- read.csv("C:/Users/s/Desktop/Case Study/Portfolio Projects/bellabeat/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
```
```{r}
sleep_day <- read.csv("C:/Users/s/Desktop/Case Study/Portfolio Projects/bellabeat/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
```

#########################
## Explored a few key tables ##
#########################

```{r}
head(daily_activity)
```

```{r}
colnames(daily_activity)
```
```{r}
head(sleep_day)
```


```{r}
colnames(sleep_day)
```
#### Insights: Both datasets have Id which can be used to merge the datasets.

#####################################
## Summary statistics ##
#####################################

### Number of unique participants are there in each dataframe? 

```{r}
n_distinct(daily_activity$Id)
n_distinct(sleep_day$Id)
```

### Number of observations are there in each dataframe?

```{r}
nrow(daily_activity)
nrow(sleep_day)
```
### Summary statistics about each data frame

### For the daily_activity dataframe:
```{r}
daily_activity %>% 
  select(TotalSteps, TotalDistance, SedentaryMinutes) %>% 
  summary()
```
### Insights from daily_activity data frame: 
#### 1. Half of the users walk fewer than ~7,400 steps per day — below the commonly recommended 10,000 steps.
#### 2. Distance traveled is closely correlated with steps. The average user travels ~5.5 km/day.
#### 3. Users are sedentary for most of the day. This highlights a health concern — long sedentary periods ~1,057 minutes (~17.6 hours)

### For the sleep_day data frame:
```{r}
sleep_day %>%  
  select(TotalSleepRecords,
         TotalMinutesAsleep,
         TotalTimeInBed) %>%
  summary()
```
### Insights from sleep_day data frame:
#### 1. Most users have only one sleep session per day, but a few may nap or track segmented sleep (up to 3 sessions).
#### 2. Most users get around 419.5 minutes (~7 hours) of sleep, which aligns with health guidelines (but some sleep less than 1 hour — possible outliers).
#### 3. There’s a gap between time in bed and actual sleep, suggesting some time spent awake (e.g., ~30–40 min).

##########################
## Plotting a few explorations ##
##########################

### Relationship between steps taken in a day and sedentary minutes? 

```{r fig.width=8, fig.height=4.9}
ggplot(data=daily_activity, aes(x=TotalSteps, y=SedentaryMinutes)) + 
  geom_point(colour = 'red') +
  geom_smooth(method = 'loess', formula = y~x, color='black') +
  labs(title = "Daily Activity: Steps Taken In A Day Vs Sedentary Length  ",
       caption ="Data Collected from https://www.kaggle.com/arashnic/fitbit") +
  annotate("text", x=7000, y=120, hjust=0,size=3.2,
           label =paste0("1. Users with high steps tend to be less sedentary\n2. Most users spend over 13 hours/day sedentary\n3. Some outliers show high steps and high sedentary minutes\ne.g. gamers, cab drivers,office workers taking One long walk and sitting all day"))
```

### Insights:
#### 1. Inverse Trend: More steps generally mean fewer sedentary minutes, especially up to ~12,000 steps.
#### 2. Sedentary Lifestyle: Most users remain inactive for over 13 hours/day.
#### 3. Outliers: Some users show high steps and high sedentary time—likely due to long walks followed by prolonged sitting (e.g., gamers, drivers, office workers).


### Relationship between minutes asleep and time in bed?

```{r fig.width=8, fig.height=4.9}
ggplot(data = sleep_day, aes(x = TotalMinutesAsleep, y = TotalTimeInBed)) + 
  geom_point(color = "blue", alpha = 0.5, size =2) +
  geom_smooth(method = 'loess', formula = y ~ x, color = "black") +
  labs(
    title = "Sleep Day: Minutes Asleep Vs Time In Bed",
    caption = "Data Collected from https://www.kaggle.com/arashnic/fitbit"
  ) +
  annotate(
    "text", x = 270, y = 120, hjust = 0, size = 3.2,
    label = paste(
      "1. Consistent sleep patterns across most users",
      "2. High sleep efficiency observed (esp. 300–600 minutes)",
      "3. Outliers — possibly due to restlessness, insomnia or tracking gaps", sep = "\n"
    )
  )
```

### Insights:
#### 1. Strong Positive Correlation - More time in bed generally results in more sleep.
#### 2. High Sleep Efficiency - Most users sleep efficiently, especially in the 300–600 minute range.
#### 3. Visible Outliers - Some users spend a long time in bed but sleep less — possibly due to restlessness, insomnia, or device tracking gaps.





## Merging these two datasets together ##

```{r}
combined_data <- merge(sleep_day, daily_activity, by="Id", all = TRUE)
```

### How many participants are in the combined data set and what attributes can be explored ?
```{r}
n_distinct(combined_data$Id)
colnames(combined_data)
```
###  Do the participants who sleep more take more steps or fewer steps per day? Is there a relationship at all?

```{r}
library(dplyr)
clean_combined_data <- combined_data %>%
  filter(
    !is.na(TotalMinutesAsleep),
    !is.na(TotalTimeInBed),
    is.finite(TotalMinutesAsleep),
    is.finite(TotalTimeInBed)
  )
```

```{r fig.width=8, fig.height=4.9}
ggplot(data = clean_combined_data, aes(x = TotalMinutesAsleep, y = TotalDistance)) +
  geom_point(color = "deepskyblue", alpha = 0.4) +
  geom_smooth(method = "loess", color = "black", formula = y~x) +
  labs(title = "Total Minutes Asleep Vs Total Distance",
       caption = "Data Collected from https://www.kaggle.com/arashnic/fitbit") +
  annotate("text", x = 10, y = 25, hjust = 0, label = 
             "1. No Strong Correlation\n2. Most Users Sleep Between 300–500 Minutes")
```


### Insights:
#### 1. Low Sleep, High Distance - A few users covered long distances (10–20 km) with very little sleep (< 200 minutes). Could indicate highly active users with irregular sleep — e.g., shift workers or athletes.
#### 2.High Sleep, Low Distance - Some users slept over 600 minutes (10+ hours) but covered very little distance, suggesting sedentary behavior or rest days.
#### 3.Scattered Points Outside Core Cluster - These indicate inconsistent activity-sleep patterns that deviate from the typical 300–500 minute sleep + moderate activity range. 











































