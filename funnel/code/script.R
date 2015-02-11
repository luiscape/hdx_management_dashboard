library(dplyr)

## Activity Data
data <- read.csv("data/ckan_activity_data.csv")
data$date_week <- format(as.Date(data$date),"%Y-W%W")
data <- data[!duplicated(data),]

new <- data.frame(date = row.names(tapply(data$new, data$date_week, sum)),
                  new = tapply(data$new, data$date_week, sum))

deleted <- data.frame(date = row.names(tapply(data$deleted, data$date_week, sum)),
                      deleted = tapply(data$deleted, data$date_week, sum))

changed <- data.frame(date = row.names(tapply(data$changed, data$date_week, sum)),
                      changed = tapply(data$changed, data$date_week, sum))

x <- merge(new,deleted, by="date")
y <- merge(x, changed, by="date")

write.csv(y, "data/activity_data_transformed.csv", row.names = F)


## Dataset Data
data <- read.csv("data/ckan_dataset_data.csv")
data <- data[!duplicated(data), ]

data$date_week <- format(as.Date(data$date), "%Y-W%W")

x <- data %>%
  group_by(date_week) %>%
  filter(as.Date(date) == max(as.Date(date)))

write.csv(x, "data/dataset_data_transformed.csv", row.names = F)


## MailChimp
mc <- read.csv('mailchimp_campaign_data.csv')
mc$date_week <- format(as.Date(mc$send_time), "%Y-W%W")


## Twitter
# tw <- read.csv("twitter_friends_data.csv")
# tw$date_week <- format(as.Date(tw$date), "%Y-W%W")
# tw <- tw %>%
#   group_by(date_week) %>%
#   filter(as.Date(date) == max(as.Date(date)))



