## Script to load data from MailChimp using their API.
library(RCurl)
#library(rjson)
library(jsonlite)
source('mailchimp/code/write_tables.R')

# Authorization
source('mailchimp/code/auth.R')

### Lists of Subscribers ###
# building the query url
# query_url <- paste(base_url, method_url, api_url,'&id=6fd988326c', limit_url, sep = "")


### Campaigns ###
# Function for querying MailChimp.
queryMailChimp <- function(method = NULL, 
                           apiKey = NULL, 
                           responseLimit = 150) {
  
  # Simple help
  cat('---------------------------------------------\n')
  cat('The following methods work:\n')
  cat('lists/activity: gets the activity on lists\n')
  cat('campaign/list: gets the activity of campaigns\n')
  cat('---------------------------------------------\n')
  
  # Sanity checks
  if (is.null(apiKey)) stop('Please provide an API key.')
  if (is.null(method)) stop('You need to provide a method.')
  
  cat('-----------------------------\n')
  cat('Querying MailChimp ... \n')
  cat('-----------------------------\n')
  
  # Building the URL for querying.
  base_url = 'https://us2.api.mailchimp.com/2.0/'  # API base url
  method_url = paste(method, '?', sep="")  # type of method to be used
  api_url = paste('apikey=', apiKey, sep = "")  # API key
  limit_url = paste('&limit=', responseLimit, sep = "")  # number of results
  
  # Assembling URL
  query_url <- paste(base_url, method_url, api_url, limit_url, sep = "")
  
  # Making query and processing results.
  doc <- getURL(query_url)
  data <- fromJSON(doc)$data
  
  # Returning a MailChimp data.frame
  cat('-----------------------------\n')
  cat('Done! \n')
  cat('-----------------------------\n')
  return(data)
}

# Function to extract data from a 
# MailChimp data.frame
# TODO: add subscriber rate.
extractData <- function(df = NULL, verbose = F) {
  
  # Creating an empty data.frame
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
  
  # Iterating over the response
  output <- data.frame()
  for (i in 1:nrow(df)) {
    # Each method has a different data structure.
    # This section controls for which data structure
    # to be used.
    # if (method == '')
    if (is.null(df$summary[i][[1]]) | length(df$summary[i][[1]]) == 0) {
      if (verbose == T) cat('Entry with issues (', i,'). Skipping.\n')
      next
    }
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
      if (nrow(output) == 0) output <- it  # improve here. do first with data.
      else output <- rbind(output, it)
    }
  }
  
  # Returning data.frame
  return(output)
}

# selecting only the lists of interest
listData = queryMailChimp(method = 'lists/activity', apiKey = apiKey, responseLimit = 300)
hdxList = listData[listData$from_email == 'hdx@un.org', ]
hdxList = extractData(hdxList)

# selecting only the lists of interest
campaignData = queryMailChimp(method = 'campaigns/list', apiKey = apiKey, responseLimit = 300)
hdxCampaigns = campaignData[campaignData$from_email == 'hdx@un.org', ]
campaignDataProcessed = extractData(hdxCampaigns)


# storing output
write.csv(y, 'mailchimp/data/out.csv', row.names = F)

