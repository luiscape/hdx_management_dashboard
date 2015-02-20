## Script to manage the creation of models for
## measuring and predicting HDX's audience.

library(ggplot2)
library(GGally)


onSw <- function(p = NULL, d = "tool/", a = FALSE) {
  if (a) return(paste0(d,p))
  else return(p)
}

source(onSw("model/code/clean.R"))

# Reading data.
readData <- function() {
  # Download + clean + load
  cat("--------------------------------------\n")
  activity <- activityData("https://ds-ec2.scraperwiki.com/7c6jufm/bwbcvvxuynjbrx2/cgi-bin/csv/ckan_activity_data.csv")
  dataset <- datasetData("https://ds-ec2.scraperwiki.com/7c6jufm/bwbcvvxuynjbrx2/cgi-bin/csv/ckan_dataset_data.csv")
  mailchimp <- mailchimpData("https://ds-ec2.scraperwiki.com/7c6jufm/bwbcvvxuynjbrx2/cgi-bin/csv/mailchimp_campaign_data.csv")
  twitter <- twitterData("https://ds-ec2.scraperwiki.com/7c6jufm/bwbcvvxuynjbrx2/cgi-bin/csv/twitter_friends_data.csv")
  cat("--------------------------------------\n")
  
  x <- merge(activity, dataset)
  y <- merge(x, twitter, all.x = TRUE, na="")
  #y <- merge(x, mailchimp, all.x = TRUE, all.y = FALSE)
  #y$"MailChimp Campaign" <- ifelse(is.na(y$"MailChimp Campaign"), FALSE, y$"MailChimp Campaign")
  
  # Returning
  cat("All data sources loaded and transformed.\n")
  cat("--------------------------------------\n")
  return(y)
}

data <- readData()
write.csv(data,"model/data/data_transformed.csv", row.names = F)

###
# Loading data from GDocd

data <- read.csv("model/data/data.csv")




####
## plotting ##
####
ggplot(data) + 
  geom_boxplot(aes(Week))


ggpairs(data[,c(6:10,12,14:16)]) +
  theme(text = element_text(size=12))

attach(data)
fit <- lm(Unique.Visitors ~ Number.of.Shares)
summary(fit) ; fit

fit2 <- lm(Unique.Visitors ~ Number.of.New.Users)
summary(fit2) ; fit2

fit3 <- lm(Unique.Visitors ~ Number.of.New.Datasets)
summary(fit3) ; fit3

fit4 <- lm(Unique.Visitors ~ Unique.Shares)
summary(fit4) ; fit4

