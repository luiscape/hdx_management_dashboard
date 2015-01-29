# loading dependencies
library(twitteR)
library(ggplot2)

# SW helper function
onSw <- function(d = T, f = 'tool/twitter/') {
  if(d) return(f)
  else return("")
}

# Direct authentication with Twitter. No browser needed.
source(paste0(onSw(), 'code/auth/credentials.R'))
source(paste0(onSw(), 'code/write_tables.R'))
source(paste0(onSw(), 'code/sw_status.R'))

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


## TODO: function below doesn't seem to be working
## with the latest update of the twitteR package.
getHistoricTimeline <- function(iterations) {
  # running it the first time
  cat('Getting tweets.\n')
  cat('Try: 1\n')
  it <- userTimeline("humdata", n=3200)
  it = twListToDF(hdxTimeline)
  id = hdxTimeline$id[nrow(hdxTimeline)]
  
  for (i in 1:(iterations-1)) {
    cat('Try:', i)
    it <- userTimeline("humdata", n=3200, maxID = id)
    it = twListToDF(hdxTimeline)
    id = hdxTimeline$id[nrow(hdxTimeline)]
    if (i == 1) output <- it
    else output <- rbind(output, it)
  }
  return(output)
}

## collecting and storing data ##
# #HumanitarianData
#humanitariandata <- getHashtag(date = as.Date('2014-07-14'))
#writeTables(df = humanitariandata, 
            # table_name = 'humanitariandata', 
            # db = 'twitter/data/scraperwiki.sqlite',
            # testing = FALSE)

# ScraperWiki scraper wrapper
runScraper <- function() {
  friends_data <- getFriends()
  writeTable(friends_data, 'twitter_friends_data', 'scraperwiki')
}


# Changing the status of SW.
tryCatch(runScraper(),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "UN Iraq Casualty Figures failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')


# Calculating change
# twitter_friends$new_followers <- NA
# for(i in 1:nrow(twitter_friends)){
#   if (i == nrow(twitter_friends)) next
#   twitter_friends$new_followers[i+1] <- twitter_friends$followers[i + 1] - twitter_friends$followers[i]
# }

# Calculating mean
# followersMean <- mean(twitter_friends$new_followers, na.rm = T); ceiling(followersMean)