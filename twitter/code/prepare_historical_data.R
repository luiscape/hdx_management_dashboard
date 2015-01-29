## Script to load other scripts and normalize Twitter data and its analysis.

# Loads data into two data.frames (within one): data$Followers + data$Following
source('tool/twitter/code/read_prepare.R')
source_list <- readPrepare()

# Doing analysis.
## Check if the results are correct ... seem wrong.
source('twitter/code/twitter_analysis.R')
results <- runTwitterAnalysis(source_list)

# selecting only what matters
friends_data_historical <- data.frame(tweets = NA,
                                      followers = as.numeric(results$n_followers),
                                      favorites = NA,
                                      following = as.numeric(results$n_following),
                                      date = as.character(results$df.Followers.date))

# storing in the twitter db
writeTables(df = friends_data_historical, 
            table_name = 'friends_data', 
            db = 'scraperwiki',
            testing = FALSE)