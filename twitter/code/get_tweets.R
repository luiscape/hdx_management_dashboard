# loading dependencies
library(twitteR)
source('twitter/code/credentials.R')  # have to open the file now. improve.
source('twitter/code/write_tables.R')


# run once below
# source('twitter/code/prepare_historical_data.R')  # for collecting historical data


########################################################
########################################################
###### Utils functions for colleting from Twitter ######
########################################################
########################################################

# Get the information from a hashtag
getHashtag <- function(hash = "#humanitariandata", 
                       date = as.Date(Sys.time())) {
  
  call <- searchTwitter(hash, n = 2000, since = as.character(date))
  df <- do.call("rbind", lapply(call, as.data.frame))
  df$created <- as.Date(df$created)
  value <- data.frame(summary(as.factor(df$created)))
  y <- data.frame(value, 
                  hashtag = hash)
  return(y)
}

# Get the 'friends' from an user
getFriends <- function() { 
  x <- as.data.frame(getUser('humdata'))
  y <- data.frame(tweets = x$statusesCount,
                  followers = x$followersCount,
                  favorites = x$favoritesCount,
                  following = x$friendsCount,
                  date = as.character(as.Date(Sys.time())))
}


## collecting and storing data ##
# #HumanitarianData
humanitariandata <- getHashtag(date = as.Date('2014-07-14'))
writeTables(df = humanitariandata, 
            table_name = 'humanitariandata', 
            db = 'scraperwiki',
            testing = FALSE)

# friends data
friends_data <- getFriends()
writeTables(df = friends_data, 
            table_name = 'friends_data', 
            db = 'scraperwiki',
            testing = FALSE)


# exporting twitter data to the HTTP directory
db <- dbConnect(SQLite(), dbname = 'twitter/data/scraperwiki.sqlite')
x <- dbReadTable(db, 'friends_data')
twitter_friends <- data.frame(date = x$date,
                              followers = x$followers,
                              following = x$following)
write.csv(twitter_friends, 'http/data/twitter_friends.csv', row.names = F, na = "")

twitter_tweets <- data.frame(date = x$date,
                             tweets = x$tweets)
write.csv(twitter_tweets, 'http/data/twitter_tweets.csv', row.names = F, na = "")

## Plotting ##
# plotting here has an exploratory analysis objective
# it is aimed at taking a brief look at the data before 
# working with it in C3.js
library(ggplot2)

ggplot(data) + theme_bw() + 
  geom_line(aes(created), stat = 'bin', color = '#0988bb', size = 1.3) + 
  geom_area(aes(created), stat = 'bin', fill = '#0988bb', alpha = .3)