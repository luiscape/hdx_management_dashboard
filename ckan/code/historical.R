### adding historical timeseries to the dashboard ###
library(reshape2)

# ScraperWiki helper library
onSw <- function(d = T, f = 'tool/ckan/') {
	if (d) return(f)
	else return("")
}

# config
PATH = paste0(onSw(), 'data/temp.csv')

# Loading helper libaries
source(paste0(onSw(), 'code/write_tables.R'))
source(paste0(onSw(), 'code/sw_status.R'))

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
           system('mail -s "CKAN statistics collection failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')