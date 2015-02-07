### adding historical timeseries to the dashboard ###
# Progress: deploy

# Dependencies
library(reshape2)

# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/ckan/') {
  if(d) return(paste0(l,p))
  else return(p)
}

# config
PATH = onSw('data/temp.csv')
db_table_name = 'ckan_dataset_data'

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

# get data and insert in db
getAndInsert <- function(p = NULL, table = NULL) {
	# downloading the file from another box
	download.file(
	'https://ds-ec2.scraperwiki.com/zaflugd/iokwwtf3ldspuao/cgi-bin/csv/hdx_repo_analytics.csv',
	destfile=p,
	method='wget'
	)
	# adding data to local database
	data <- read.csv(p)
	data$Number_of_Licenses <- NULL
	data$Number_of_Countries <- NULL
	data$Number_of_Tags <- NULL
  data$orgs_sharing_data <- NA
	names(data) <- c('number_of_datasets', 'number_of_organizations', 'number_of_users', 'date', 'orgs_sharing_data')
	writeTable(data, table, 'scraperwiki', overwrite = TRUE)  # overwriting the table name if it exists
}

# ScraperWiki wraper function
runScraper <- function(p = NULL, table = NULL) {
	getAndInsert(p, table)
}

# ScraperWiki-specific error handler
# Changing the status of SW.
tryCatch(runScraper(p = PATH, table = db_table_name),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "CKAN statistics: historic collection failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')