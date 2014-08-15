### adding historical timeseries to the dashboard ###
library(reshape2)
source('code/write_tables.R')


# load data
data <- read.csv('data/source/hdx_repo_analytics.csv')

data_m <- melt(data)
names(data_m) <- c('period', 'indID', 'value')
observations <- data_m

indicators <- data.frame(indID = unique(data_m$indID), name = c('Number of Datasets in CKAN', 'Number of Countries in CKAN', 'Number of Organizations in CKAN', 'Number of Users Registered in CKAN', 'Number of Different Tags in CKAN', 'Number of Licenses in CKAN'), dsID = 'ckan')

datasets <- data.frame(dsID = 'ckan', last_scraped = as.character(as.Date(Sys.time())), name = 'CKAN', source = 'https://data.hdx.rwlabs.org/api')


# writing tables in db
writeTables(indicators, 'indicators', 'scraperwiki')
writeTables(datasets, 'datasets', 'scraperwiki')
writeTables(observations, 'observations', 'scraperwiki')