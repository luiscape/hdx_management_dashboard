## Script to manage the creation of models for
## measuring and predicting HDX's audience.

library(ggplot2)
library(GGally)
library(caret)


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
readDataGdoc <- function(p) {
  # fetching data from Google Docs
  download.file("https://docs.google.com/spreadsheets/d/1WgalnP7XjdcfiCrSUO77i_DwWndYwRmrdV8126IC-Ts/export?format=csv",
                p, method="wget", quiet=TRUE)
  
  d <- read.csv(p)
  
  # simple cleaning procedures
  d <- d[,1:26]
  d$MailChimp.Campaign <- NULL
  d <- na.omit(d)
  
  # return
  return(d)
}

predictUniqueVisitors <- function(future_values = NULL, sd_multiplier = NULL) {
  
  # Adding future values to the right structure.
  if (is.null(future_values) & is.null(sd_multiplier)) stop("Provide future_values or sd_multiplier.")
  
  # Loading and subsetting data.
  d <- readDataGdoc("model/data/temp.csv")
  sub <- d[
    c("Unique.Visitors", 
      "Number.of.Datasets", 
      "Number.of.Registered.Users", 
      "Datasets.Deleted", 
      "Number.of.New.Registered.Users",
      "Number.of.New.Datasets",
      "Unique.Sessions",
      "Number.of.Downloads",
      "Number.of.Shares",
      "Unique.Downloads",
      "Unique.Shares",
      "User.Register",
      "Number.of.Organizations",
      "Datasets.Created",
      "Datasets.Edited",
      "Number.of.New.Organizations",
      "Total.Events",
      "Number.of.Previews",
      "Number.of.Dataset.Shares",
      "Total.Unique.Events",
      "Unique.Previews",
      "Unique.Dataset.Shares"
    )
    ]
  
  # Creating model
  # model <- lm(Unique.Visitors ~ ., data = sub)
  model2 <- lm(Unique.Visitors ~ Unique.Shares,  data = sub)
  
  # Predicting values based on input.
  if (!is.null(sd_multiplier)) {
    # Generating output.
    future_df <- data.frame(Unique.Shares = (sd_multiplier * sd(sub$Unique.Shares)) + mean(sub$Unique.Shares))
    predictions <- predict(model2, future_df)
    out <- data.frame(
      Unique.Visitors = round(predictions,0),
      Unique.Visitors_percent = round((predictions - mean(sub$Unique.Visitors)) / mean(sub$Unique.Visitors),2),
      Unique.Shares = round(future_df,0),
      Unique.Shares_percent = round((future_df$Unique.Shares - mean(sub$Unique.Shares)) / mean(sub$Unique.Shares),2)
      )
  }
  else {
    # Generating output.
    future_df <- data.frame(Unique.Shares = future_values)
    out <- data.frame(Unique.Visitors = round(predict(model2, future_df),0),
                      Unique.Shares = round(future_df,0))
  }
  

  return(out)
}


predictUniqueShares <- function(future_values = NULL, sd_multiplier = NULL) {
  
  # Adding future values to the right structure.
  if (is.null(future_values) & is.null(sd_multiplier)) stop("Provide future_values or sd_multiplier.")
  
  # Loading and subsetting data.
  d <- readDataGdoc("model/data/temp.csv")
  sub <- d[
    c( 
      "Number.of.Datasets", 
      "Number.of.Registered.Users", 
      "Datasets.Deleted", 
      "Number.of.New.Registered.Users",
      "Number.of.New.Datasets",
      "Unique.Sessions",
      "Number.of.Downloads",
      "Number.of.Shares",
      "Unique.Downloads",
      "Unique.Shares",
      "User.Register",
      "Number.of.Organizations",
      "Datasets.Created",
      "Datasets.Edited",
      "Number.of.New.Organizations",
      "Total.Events",
      "Number.of.Previews",
      "Number.of.Dataset.Shares",
      "Total.Unique.Events",
      "Unique.Previews",
      "Unique.Dataset.Shares"
    )
    ]
  
  # Creating model
  model2 <- lm(Unique.Shares ~ Datasets.Created, data = sub)
  
  # Predicting values based on input.
  if (!is.null(sd_multiplier)) {
    # Generating output.
    future_df <- data.frame(Datasets.Created = (sd_multiplier * sd(sub$Datasets.Created)) + mean(sub$Datasets.Created))
    predictions <- predict(model2, future_df)
    out <- data.frame(
      Unique.Shares = round(predictions,0),
      Unique.Shares_percent = round((predictions - mean(sub$Unique.Shares)) / mean(sub$Unique.Shares),2),
      Datasets.Created = round(future_df,0),
      Datasets.Created_percent = round((future_df$Datasets.Created - mean(sub$Datasets.Created)) / mean(sub$Datasets.Created),2)
    )
  }
  else {
    # Generating output.
    future_df <- data.frame(Unique.Shares = future_values)
    out <- data.frame(Unique.Visitors = round(predict(model2, future_df),0),
                      Unique.Shares = round(future_df,0))
  }
  
  
  return(out)
}



####
## plotting ##
####
# ggplot(data) + 
#   geom_boxplot(aes(Week))
# 
# 
# ggpairs(data[,c(6:10,12,14:16)]) +
#   theme(text = element_text(size=12))
# 
# attach(data)
# fit <- lm(Unique.Visitors ~ Number.of.Shares)
# summary(fit) ; fit
# 
# fit2 <- lm(Unique.Visitors ~ Number.of.New.Users)
# summary(fit2) ; fit2
# 
# fit3 <- lm(Unique.Visitors ~ Number.of.New.Datasets)
# summary(fit3) ; fit3
# 
# fit4 <- lm(Unique.Visitors ~ Unique.Shares)
# summary(fit4) ; fit4
# 
