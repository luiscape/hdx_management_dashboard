#### Google Analytics script. ####

# loading Google dependencies
source("google_analytics/code/RGoogleAnalytics.R")
source("google_analytics/code/QueryBuilder.R")
source("google_analytics/code/Configuration.R")
source("google_analytics/code/write_tables.R")


# Step 1. Authorize your account and paste the accesstoken 
query <- QueryBuilder()
access_token <- query$authorize()

# Step 2. Initialize the configuration object
conf <- Configuration()

# Retrieving a list of Accounts
ga.account <- conf$GetAccounts()

testConnection <- function() {
    if (nrow(ga.account) != 3) message('There are problems with auth.')
    else message('Connection established with Google Analytics.\n.')
}
testConnection()


# Retrieving a list of Web Properties
# With passing parameter as (ga.account$id[index]) will retrieve list of web properties under that account 
ga.webProperty <- conf$GetWebProperty()

# Retrieving a list of web profiles available for specific Google Analytics account and Web property
# by passing with two parameters - (ga.account$id,ga.webProperty$id).
# With passing No parameters will retrieve all of web profiles
ga.webProfile_repo <- conf$GetWebProfile(ga.account$id[3],ga.webProperty$id[7])
ga.webProfile_blog <- conf$GetWebProfile(ga.account$id[3],ga.webProperty$id[6])


# Step 3. Create a new Google Analytics API object
ga <- RGoogleAnalytics()

# Old way to retrieve profiles from Google Analytics 
ga.profiles <- ga$GetProfileData(access_token)

profile <- ga.webProfile_repo$id[1]  # data for the repository

startdate <- "2014-01-01"
enddate <- "2014-08-18"

sort <- "ga:visits"
maxresults <- 10000

# Step 5. Build the query string, use the profile by setting its index value 
# Buiding the queries. 
r_profile <- "ga:85660823"
b_profile <- "ga:82675519"


query$Init(start.date = startdate,
           end.date = enddate,
           # dimensions = dimension,
           metrics = metric,
           #sort = sort,
           #filters="",
           #segment=segment,
           # max.results = maxresults,
           table.id = paste("ga:",profile, sep=""),
           access_token=access_token)


######################
#### Repo Metrics ####
######################
# Number of Visits to the Repository 
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:visits",
           table.id = r_profile,
           access_token=access_token)
number_visits_repo_total <- ga$GetReportData(query)

# Number of Unique Users to the Repository
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:users",
           table.id = r_profile,
           access_token=access_token)
number_unique_users_repo_total <- ga$GetReportData(query)

# Number of Pageviews to the Repository
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:pageviews",
           table.id = r_profile,
           access_token=access_token)
number_pageviews_repo_total <- ga$GetReportData(query)

# Number of Sessions to the Repository
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:sessions",
           table.id = r_profile,
           access_token=access_token)
number_sessions_repo_total <- ga$GetReportData(query)


######################
#### Blog Metrics ####
######################
# Number of Visits to the Blog 
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:visits",
           table.id = b_profile,
           access_token=access_token)
number_visits_blog_total <- ga$GetReportData(query)

# Number of Unique Users to the Blog
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:users",
           table.id = b_profile,
           access_token=access_token)
number_unique_users_blog_total <- ga$GetReportData(query)

# Number of Pageviews to the Blog
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:pageviews",
           table.id = b_profile,
           access_token=access_token)
number_pageviews_blog_total <- ga$GetReportData(query)

# Number of Sessions to the Blog
query$Init(start.date = "2014-01-01",
           end.date = as.character(as.Date(Sys.time())),
           metrics = "ga:sessions",
           table.id = b_profile,
           access_token=access_token)
number_sessions_blog_total <- ga$GetReportData(query)



#### Storing Data ####
# Organizing data into the db format.
observations <- data.frame(period = as.character(as.Date(Sys.time())),
                           indID = c('Number_of_Visits_Repo_Total', 
                                     'Number_of_Unique_Users_Repo_Total',
                                     'Number_of_Pageviews_Repo_Total',
                                     'Number_of_Sessions_Repo_Total',
                                     'Number_of_Visits_Blog_Total',
                                     'Number_of_Unique_Users_Blog_Total',
                                     'Number_of_Pageviews_Blog_Total',
                                     'Number_of_Sessions_Blog_Total'),
                 values = c(as.numeric(number_visits_repo_total), 
                            as.numeric(number_unique_users_repo_total),
                            as.numeric(number_pageviews_repo_total), 
                            as.numeric(number_sessions_repo_total),
                            as.numeric(number_visits_blog_total),
                            as.numeric(number_unique_users_blog_total),
                            as.numeric(number_pageviews_blog_total),
                            as.numeric(number_sessions_blog_total)))

writeTables(observations, 'observations', 'scraperwiki')


# Storing the GA indicators
# indicators <- data.frame(indID = unique(observations$indID), name = c('Number of Visits to the Repository (total)', 'Number of Unique Users to the Repository (total)', 'Number of Pageviews to the Repository (total)', 'Number of Sessions to the Repository (total)', 'Number of Visits to the Blog (total)', 'Number of Unique Users to the Blog (total)', 'Number of Pageviews to the Blog (total)', 'Number of Sessions to the Blog (total)'), dsID = 'google-analytics')
# writeTables(indicators, 'indicators', 'scraperwiki')


# Storing the GA dataset
#datasets <- data.frame(dsID = 'google-analytics', last_scraped = as.character(as.Date(Sys.time())), name = 'Google Analytics', source = 'https://developers.google.com/analytics/')
#writeTables(datasets, 'datasets', 'scraperwiki')


# DB tests
# db <- dbConnect(SQLite(), dbname = 'scraperwiki.sqlite')
#x <- dbReadTable(db, 'datasets')