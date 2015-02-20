# Script to clean statistics for HDX's
# funnel data.

# Dependencies
library(dplyr)

onSw <- function(p = NULL, d = "tool/", a = FALSE) {
  if (a) return(paste0(d,p))
  else return(p)
}


###################
## Configuration ##
###################

TABLE_NAME = ""

## Activity Data
activityData <- function(url = NULL, csv = TRUE) {
  
  # Downloading data.
  cat("Downloading CKAN activity data ... ")
  p = onSw("model/data/temp.csv")
  download.file(url, p, method="wget", quiet = TRUE)
  data <- read.csv(p)
  cat("done.\n")
  
  # Transforming weeks.
  cat("Processing data ... ")
  data$date_week <- format(as.Date(data$date),"%Y-W%V")
  data <- data[!duplicated(data$date),]
  
  # Grouping data by respective week.
  new <- data.frame(Week = row.names(tapply(data$new, data$date_week, sum)),
                    new = tapply(data$new, data$date_week, sum))
  
  deleted <- data.frame(Week = row.names(tapply(data$deleted, data$date_week, sum)),
                        deleted = tapply(data$deleted, data$date_week, sum))
  
  changed <- data.frame(Week = row.names(tapply(data$changed, data$date_week, sum)),
                        changed = tapply(data$changed, data$date_week, sum))
  
  # Merging
  new_merged <- merge(new, deleted, by="Week")
  output <- merge(new_merged, changed, by="Week")
  names(output) <- c("Week", "Datasets Created", "Datasets Deleted", "Datasets Changed")
  
  # Creating output
  if (csv) write.csv(output, onSw("model/data/activity_data_transformed.csv"), row.names = F)
  
  cat("done.\n")
  return(output)
}

## Dataset Data
datasetData <- function(url = NULL, csv = TRUE) {
  
  # Downloading data.
  cat("Downloading CKAN Dataset data ... ")
  p = onSw("model/data/temp.csv")
  download.file(url, p, method="wget", quiet = TRUE)
  data <- read.csv(p)
  cat("done.\n")
  
  # Cleaning duplicates
  cat("Processing data ... ")
  data <- data[!duplicated(data), ]
  
  # Creating weeks
  data$date_week <- format(as.Date(data$date), "%Y-W%V")
  data <- data[!duplicated(data$date_week), ]
  
  # Selecting the latest observation in the week.
  data <- data %>%
    group_by(date_week) %>%
    filter(as.Date(date) == max(as.Date(date)))
  
  data$date <- NULL
  names(data) <- c("Number of Datasets", "Number of Organizations", "Number of Registered Users", "Week")
  
  if (csv) write.csv(data, onSw("model/data/dataset_data_transformed.csv"), row.names = F)
  
  cat("done.\n")
  return(data)
}


## MailChimp
mailchimpData <- function(url = NULL, csv = TRUE) {
  # Downloading data.
  cat("Downloading MailChimp data ... ")
  p = onSw("model/data/temp.csv")
  download.file(url, p, method="wget", quiet = TRUE)
  data <- read.csv(p)
  cat("done.\n")
  
  cat("Processing data ... ")
  data$date_week <- format(as.Date(data$send_time), "%Y-W%V")
  data$mailchimp_campaign <- TRUE
  keep = c("date_week", "mailchimp_campaign")
  data <- data[keep]
  names(data) <- c("Week", "MailChimp Campaign")
  
  if (csv) write.csv(data, onSw("model/data/mailchimp_data_transformed.csv"), row.names = F)
    
  cat("done.\n")
  return(data)
}


## Twitter
twitterData <- function(url = NULL, csv = TRUE) {
  # Downloading
  cat("Downloading Twitter data ... ")
  p = onSw("model/data/temp.csv")
  download.file(url, p, method="wget", quiet = TRUE)
  data <- read.csv(p)
  cat("done.\n")
  
  # Filtering
  cat("Processing data ... ")
  data$date_week <- format(as.Date(data$date), "%Y-W%W")
  data <- data %>%
    group_by(date_week) %>%
    filter(as.Date(date) == max(as.Date(date)))
  
  data$favorites <- NULL
  data$date <- NULL
  names(data) <- c("Number of Tweets","Number of Followers", "Number Following", "Week")
  
  if(csv) write.csv(data, onSw("model/data/twitter_data_transformed.csv"), row.names = F)
  
  cat("done.\n")  
  return(data)
}

runScraper <- function() {
  
}





