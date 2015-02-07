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
db_table_name = "mailchimp_list_data"
args <- commandArgs(T)
apikey = args[1]


###################
## Program Logic ##
###################

### Campaigns ###
# Function for querying MailChimp.
queryMailChimp <- function(method = 'lists/activity', 
                           apiKey = NULL, 
                           responseLimit = 150) {
  
  if (is.null(apiKey) | is.na(apiKey)) stop("No API key provided.")

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
  id_url = '&id=6fd988326c'

  # Assembling URL
  query_url <- paste0(base_url, method_url, api_url, id_url)
  print(query_url)

  # Making query and processing results.
  doc <- fromJSON(getURL(query_url))
  data <- data.frame(
    date = as.character(as.Date(doc$day)),
    emails_sent = as.numeric(doc$emails_sent),
    unique_opens = as.numeric(doc$unique_opens),
    recipient_clicks = as.numeric(doc$recipient_clicks),
    hard_bounce = as.numeric(doc$hard_bounce),
    soft_bounce = as.numeric(doc$soft_bounce),
    abuse_reports = as.numeric(doc$abuse_reports),
    subscriptions = as.numeric(doc$subs),
    unsubscriptions = as.numeric(doc$unsubs),
    other_adds = as.numeric(doc$other_adds),
    other_removes = as.numeric(doc$other_removes)
    )

  # Returning a MailChimp data.frame
  cat('-----------------------------\n')
  cat('Done! \n')
  cat('-----------------------------\n')
  
  return(data)
}


############################################
############################################
########### ScraperWiki Logic ##############
############################################
############################################

# Scraper wrapper
runScraper <- function(csv = FALSE, p = NULL, table = NULL, k = NULL) {
  cat('-----------------------------\n')

  data <- queryMailChimp(apiKey = k, responseLimit = 300)

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

# Changing the status of SW.
tryCatch(runScraper(table = db_table_name, k = apikey),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "MailChimp Statistics: list statistics failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')

