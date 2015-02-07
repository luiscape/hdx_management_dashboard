## This tracker was written to create an elementary analytics
## reporting system for a CKAN instance (data.hdx.rwlabs.org).

# Progress: development.

# Dependencies
library(RCurl)
library(rjson)

###################
## Configuration ##
###################
db_table_name = 'ckan_dataset_data'
args <- commandArgs(T)
apikey = args[1]

# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/ckan/') {
  if(d) return(paste0(l,p))
  else return(p)
}

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

# Main function for collecting data.
collectData <- function(k = apikey) {

	# Number of packages
	num_packages_url <- 'https://data.hdx.rwlabs.org/api/action/package_list'
	number_of_datasets <- nrow(data.frame(fromJSON(getURL(num_packages_url))))

	# Number of organizations
	num_organizations_url <- 'https://data.hdx.rwlabs.org/api/action/organization_list'
	number_of_organizations <- nrow(data.frame(fromJSON(getURL(num_organizations_url))))

	# Number of users
	num_user_url <- 'https://data.hdx.rwlabs.org/api/action/user_list'
	users_result <- fromJSON(getURL(num_user_url))
	number_of_users <- length(users_result[3]$result)

	# Collecting date and time.
	date_and_time <- format(as.Date(Sys.time()), "%Y-%m-%d")

	# Making a single data.frame.
	hdx_repo_analytics <- data.frame(number_of_datasets, number_of_organizations,
	                                 number_of_users, date_and_time)

	hdx_repo_analytics$orgs_sharing_data <- orgsSharingData(key = k)
  
  # Adding pretty names.
	names(hdx_repo_analytics) <- c('number_of_datasets', 'number_of_organizations', 'number_of_users', 'date', 'orgs_sharing_data')

	return(hdx_repo_analytics)
}

# Function to know how many organizations are sharing data.
orgsSharingData <- function(key = NULL) {
  cat('Downloading data...\n')
  url = 'https://data.hdx.rwlabs.org/api/action/organization_list'
  doc = fromJSON(getURL(url, httpheader = c(Authorization = key)))
  total = length(doc$result)
  
  cat('Calculating the orgs sharing data ...')
  pb <- txtProgressBar(min = 0, max = total, style = 3, char = ".")
  for(i in 1:total) {
    setTxtProgressBar(pb, i)
    
    # Querying specific organizations.
    org_id = doc$result[[i]]
    org_url = paste0('https://data.hdx.rwlabs.org/api/action/organization_show?id=', org_id)
    org_doc = fromJSON(getURL(org_url, httpheader = c(Authorization = key)))
    
    # Assembling a data.frame.
    it <- data.frame(
      display_name = ifelse(is.null(org_doc$result$display_name), NA, org_doc$result$display_name),
      num_followers = ifelse(is.null(org_doc$result$num_followers), NA, org_doc$result$num_followers),
      package_count = ifelse(is.null(org_doc$result$package_count), NA, org_doc$result$package_count),
      number_users = length(org_doc$result$users),
      date = as.character(Sys.Date())
    )
    
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }
  cat('Done\n')
  orgs_sharing_data = sum(out$package_count)
  return(orgs_sharing_data)
}



# ScraperWiki wraper function
runScraper <- function(table = NULL) {
	ckan_data <- collectData()
	writeTable(ckan_data, table, 'scraperwiki')
}

# ScraperWiki-specific error handler
# Changing the status of SW.
tryCatch(runScraper(table = db_table_name),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "CKAN Statistics: dataset data failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')
