# Script for downloading the indicator metadata from Google Docs,
# executing validation tests, and storing
# data into a table in ScraperWiki.

# Dependencies
library(RCurl)

###################
## Configuration ##
###################
FILE_PATH = 'data/temp.csv'
GDOCS_URL = 'https://docs.google.com/spreadsheets/d/12MDbdfI2dnvnKJkLB6CWrIwqLgITJbcrhF1nsHH4re0/export?format=csv&gid=0&single=true'
TABLE_NAME = '_indicator_metadata'  # making it a `developer table`.

# ScraperWiki helper script.
onSw <- function(p = NULL, l = 'tool/indicators/', d = TRUE) {
	if (d) return(paste0(l, p))
	else return(p)
}

# Helper functions
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

# Function to validate the spreadsheet.
downloadFile <- function(url = NULL, file_path = NULL) {
	download.file(url, file_path, method="wget")
	data <- read.csv(file_path)
	return(data)
}

###################
### ScraperWiki ###
###################

# ScraperWiki wraper function
runScraper <- function() {
	data <- downloadFile(GDOCS_URL, FILE_PATH)
	if (is.data.frame(data)) writeTable(data, TABLE_NAME, "scraperwiki", overwrite=TRUE)
	else stop("Could not write table: isn't data.frame.")
}

# ScraperWiki-specific error handler
# Changing the status of SW.
tryCatch(runScraper(),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "Indicators: creating metadata failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Validation failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')
