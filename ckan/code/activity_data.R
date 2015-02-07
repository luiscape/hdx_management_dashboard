## Collecting data for the making of a 
## simple bar-graph of the activity on CKAN.
## This script is configured to run at a certain amount of time.
# Progress: deployed.
library(rjson)
library(RCurl)
library(reshape2)

# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/ckan/') {
  if(d) return(paste0(l,p))
  else return(p)
}

# Helper functions
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

########################
#### Configuration #####
########################
args <- commandArgs(T)
limit = args[1]
PATH = onSw("data/ckan_activity_data.csv")
db_table_name = "ckan_activity_data"


#######################
#### Program Logic ####
#######################

# Function to fetch avctivity data from HDX. 
# And process it into an R data.frame.
fetchActivityData <- function(l = 25000) {
  # checking that the argumetns are numeric
  l = as.numeric(l)
  if (!is.numeric(l)) stop("Provide an integer.")
  if (is.na(l)) l = 25000

  # url to query
  url = paste0('https://data.hdx.rwlabs.org/api/action/recently_changed_packages_activity_list?limit=', l)
  path = onSw("data/activity_data.json")
  download.file(url, path, method = "wget")
  doc = fromJSON(file = path, unexpected.escape = "keep")

  # parsing results
  total = length(doc$result)
  m = paste0("Processing ", total, " activity entries.\n")
  cat(m)
  pb <- txtProgressBar(min = 0, max = total, style = 3, char = ".")
  for (i in 1:total) {
    setTxtProgressBar(pb, i)
    it <- data.frame(dataset_name = doc$result[[i]]$data$package$name,
                     timestamp = as.POSIXct(doc$result[[i]]$timestamp),
                     activity_type = doc$result[[i]]$activity_type,
                     user_id = doc$result[[i]]$user_id)

    # building data.frame
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }

  # results
  return(out)
}

collectUserData <- function(df = NULL) {
  id_list <- unique(df$user_id)
  total = length(id_list)
  
  cat('\n----------------------------\n')
  cat('Fetching user data.\n')
  pb <- txtProgressBar(min = 0, max = total, style = 3, char = ".")
  for (i in 1:total) {
    setTxtProgressBar(pb, i)
    tryCatch({
        # building url
        id = id_list[i]
        url = paste0('https://data.hdx.rwlabs.org/api/action/user_show?id=', id)
        doc = fromJSON(getURL(url))

        # iterating over results
        it <- data.frame(user_id = doc$result$id,
                         display_name = doc$result$display_name,
                         fullname = doc$result$fullname,
                         number_of_edits = doc$result$number_of_edits,
                         user_name = doc$result$name)

        # building data.frame
        if (i == 1) out <- it
        else out <- rbind(out, it)
      },
      # if error
      error = function(e) {
        # If error add an empty record.
        it <- data.frame(user_id = NA,
                         display_name = NA,
                         fullname = NA,
                         number_of_edits = NA,
                         user_name = NA)

        # building data.frame
        if (i == 1) out <- it
        else out <- rbind(out, it)
    })
  }
  
  # merging with activity data
  out <- merge(df, out, all.x = T)
  
  # returning output
  cat('\nDone!\n')
  cat('----------------------------\n')
  
  return(out)
}

# casting into chart shape
reshapeData <- function(df = NULL) {
  cat('----------------------------\n')
  cat('Reshaping data\n')
  activity_data_totals <- data.frame(table(df$timestamp, df$activity_type))
  names(activity_data_totals) <- c('date', 'variable', 'frequency')
  out <- dcast(activity_data_totals, date ~ variable, value.var = "frequency")
  names(out) <- c('date', 'changed', 'new', 'deleted')
  cat('----------------------------\n')
  return(out)
}

############################################
############################################
########### ScraperWiki Logic ##############
############################################
############################################

# Scraper wrapper
runScraper <- function(csv = FALSE, p = NULL, table = NULL) {
  cat('-----------------------------\n')
  cat('Collecting current data.\n')
  # collecting data. 25000 gets about everything (?)
  activity_data <- fetchActivityData(limit)
  activity_data_enhanced <- collectUserData(activity_data)
  activity_data_totals <- reshapeData(activity_data_enhanced)

  # The function parseData returns a string if
  # there isn't new data. Check if the object is a data.frame
  # and then proceed to writting the data in the database.
  if (is.data.frame(activity_data_totals)) {
    writeTable(activity_data_totals, table, 'scraperwiki')
    m <- paste('\nData saved to database.', nrow(data), 'records added.\n')
    cat(m)
  }
  else print(activity_data_totals)
  # Save CSV locally.
  if (csv) {
    # CSV storing
    write.csv(activity_data_enhanced, onSw('data/activity_data.csv'), row.names = F)
    write.csv(activity_data_totals, onSw('data/activity_data_totals.csv'), row.names = F)
  }
  cat('-----------------------------\n')
}

# Changing the status of SW.
tryCatch(runScraper(p=PATH, table=db_table_name),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "CKAN Statistics: Activity list failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')