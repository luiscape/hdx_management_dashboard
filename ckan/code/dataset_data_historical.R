### adding historical timeseries to the dashboard ###
library(reshape2)

# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/') {
  if(d) return(paste0(p,l))
  else return(p)
}

# config
PATH = onSw('data/temp.csv')

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

# get data and insert in db
getAndInsert <- function(p) {
	# downloading the file from another box
	download.file(
	'https://ds-ec2.scraperwiki.com/zaflugd/iokwwtf3ldspuao/cgi-bin/csv/hdx_repo_analytics.csv',
	destfile=p,
	method='wget'
	)
	# adding data to local database
	data <- read.csv(p)
	writeTable(data,'ckan', 'scraperwiki', overwrite=T)  # overwriting the table name if it exists
}

# ScraperWiki wraper function
runScraper <- function(p) {
	getAndInsert(p)
}

# ScraperWiki-specific error handler
# Changing the status of SW.
tryCatch(runScraper(PATH),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "CKAN statistics: historic collection failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')