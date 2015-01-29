## This tracker was written to create an elementary analytics
## reporting system for a CKAN instance (data.hdx.rwlabs.org).

## TODO: Error reported on SW. Debug!

# Progress: degugging.

# dependencies
library(RCurl)
library(rjson)

# config
db_table_name = 'ckan_dataset_data'

# ScraperWiki helper function
onSw <- function(p = NULL, d = FALSE, l = 'tool/ckan/') {
  if(d) return(paste0(p,l))
  else return(p)
}

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

# Main function for collecting data.
collectData <- function() {

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

	# Number of tags
	num_tags_url <- 'https://data.hdx.rwlabs.org/api/action/tag_list'
	number_of_tags <- nrow(data.frame(fromJSON(getURL(num_tags_url))))

	# Collecting date and time.
	date_and_time <- format(as.Date(Sys.time()), "%Y-%m-%d")

	# Making a single data.frame.
	hdx_repo_analytics <- data.frame(number_of_datasets, number_of_organizations,
	                                 number_of_users, number_of_tags, date_and_time)

	# Adding pretty names.
	names(hdx_repo_analytics) <- c("Number_of_Datasets", "Number_of_Organizations", "Number_of_Users", "Number_of_Tags", "Date_and_Time")

	return(hdx_repo_analytics)
}

# ScraperWiki wraper function
runScraper <- function(table = NULL) {
	ckan_data <- collectData()
	writeTable(ckan_data, table, 'scraperwiki')
}
runScraper(table = db_table_name)

# ScraperWiki-specific error handler
# Changing the status of SW.
# tryCatch(runScraper(table = db_table_name),
#          error = function(e) {
#            cat('Error detected ... sending notification.')
#            system('mail -s "CKAN statistics collection failed." luiscape@gmail.com')
#            changeSwStatus(type = "error", message = "Scraper failed.")
#            { stop("!!") }
#          }
# )

# # If success:
# changeSwStatus(type = 'ok')
