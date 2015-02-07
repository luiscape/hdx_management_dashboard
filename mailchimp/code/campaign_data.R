## Script to load data from MailChimp using their API.
# Progress: test-deploy.
library(RCurl)
library(jsonlite)

# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/mailchimp/') {
  if(d) return(paste0(l,p))
  else return(p)
}

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

###################
## Configuration ##
###################
PATH = onSw('data/organization_data.csv')
db_table_name = "mailchimp_campaign_data"
args <- commandArgs(T)
apikey = args[1]


###################
## Program Logic ##
###################
# Function for querying MailChimp.
queryMailChimp <- function(method = NULL, 
                           apiKey = NULL, 
                           responseLimit = 150) {
  
  if (is.null(apiKey) | is.na(apiKey)) stop("No API key provided.")

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
# TODO:
# - add subscriber rate.
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
      it <- data.frame(
        id = df$id[i],
        title = df$title[i],
        send_time = df$send_time[i],
        unsubscribers = df$summary[i][[1]]$unsubscribes,
        abuser_reports = df$summary[i][[1]]$abuse_reports,
        forwards = df$summary[i][[1]]$forwards,
        forwards_opens = df$summary[i][[1]]$forwards_opens,
        opens = df$summary[i][[1]]$opens,
        unique_opens = df$summary[i][[1]]$unique_opens,
        clicks = df$summary[i][[1]]$clicks,
        unique_clicks = df$summary[i][[1]]$unique_clicks,
        users_who_clicked = df$summary[i][[1]]$users_who_clicked
        )
      if (nrow(output) == 0) output <- it  # improve here. do first with data. (?)
      else output <- rbind(output, it)
    }
  }

  # Returning full data.frame.
  return(output)
}

# Selecting only campaigns sent by HDX.
collectCampaigns <- function(all = FALSE, key = NULL) {
  campaign_data = queryMailChimp(method = 'campaigns/list', apiKey = key, responseLimit = 300)
  # Subsetting only the campaigns by HDX.
  if (!all) hdx_campaigns = campaign_data[campaign_data$from_email == 'hdx@un.org', ]
  else hdx_campaigns = campaign_data
  campaign_data_processed = extractData(hdx_campaigns)
  return(campaign_data_processed)
}


############################################
############################################
########### ScraperWiki Logic ##############
############################################
############################################

# Scraper wrapper
runScraper <- function(csv = FALSE, p = NULL, table = NULL, k = NULL) {
  cat('-----------------------------\n')

  data <- collectCampaigns(key = k)

  # The function parseData returns a string if
  # there isn't new data. Check if the object is a data.frame
  # and then proceed to writting the data in the database.
  if (is.data.frame(data)) {
    writeTable(data, table, 'scraperwiki')
    m <- paste('\nData saved to database.', nrow(data), 'records added.\n')
    cat(m)
  }
  else print(data)
  # Save CSV locally.
  if (csv) {
    if (is.null(p)) stop("No path to write CSV provided.")
    write.csv(data, p, row.names = F)
  }
  cat('-----------------------------\n')
}

runScraper(table = db_table_name, k = apikey)

# Changing the status of SW.
# tryCatch(runScraper(table = db_table_name, k = apikey),
#          error = function(e) {
#            cat('Error detected ... sending notification.')
#            system('mail -s "MailChimp Statistics: campaign list failed." luiscape@gmail.com')
#            changeSwStatus(type = "error", message = "Scraper failed.")
#            { stop("!!") }
#          }
# )

# # If success:
# changeSwStatus(type = 'ok')
