## Script to load data from MailChimp using their API.
library(RCurl)
#library(rjson)
library(jsonlite)
source('mailchimp/code/write_tables.R')

# loading auth data
source('mailchimp/code/auth.R')

# building the query url
base_url = 'https://us2.api.mailchimp.com/2.0/campaigns/list?'
api_url = paste('apikey=', api_key, sep = "")
limit_url = paste('&limit=', 150, sep = "")
query_url <- paste(base_url, api_url, limit_url, sep = "")

# querying the url
doc <- getURL(test_url)
data <- fromJSON(doc)$data

# selecting only the lists of interest
hdx_campaigns <- data[data$from_email == 'hdx@un.org', ]

# extracting data
extractData <- function(df = NULL) {
  for (i in 1:nrow(df)) {
    it <- data.frame(id = NA,
                     title = NA,
                     send_time = NA,
                     unsubscribes = NA, 
                     abuse_reports = NA, 
                     forwards = NA, 
                     forwards_opens = NA,
                     opens = NA,
                     unique_opens = NA,
                     clicks = NA,
                     unique_clicks = NA,
                     users_who_clicked = NA)
    if (is.null(df$summary[i][[1]]) | length(df$summary[i][[1]]) == 0) next
    else {
      it$id <- df$id[i]
      it$title <- df$title[i]
      it$send_time <- df$send_time[i]
      it$unsubscribes <- df$summary[i][[1]]$unsubscribes
      it$abuse_reports <- df$summary[i][[1]]$abuse_reports
      it$forwards <- df$summary[i][[1]]$forwards
      it$forwards_opens <- df$summary[i][[1]]$forwards_opens
      it$opens <- df$summary[i][[1]]$opens
      it$unique_opens <- df$summary[i][[1]]$unique_opens
      it$clicks <- df$summary[i][[1]]$clicks
      it$unique_clicks <- df$summary[i][[1]]$unique_clicks
      it$users_who_clicked <- df$summary[i][[1]]$users_who_clicked
      if (i == 3) out <- it  # improve here. do first with data.
      else out <- rbind(out, it)
    }
  }
  return(out)
}

x <- extractData(hdx_campaigns)

# storing output
write.csv(x, 'mailchimp/data/out.csv', row.names = F)
