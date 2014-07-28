#### Twitter ####
# Preparing Twitter data for analysis. 

runTwitterAnalysis <- function() { 
  
  ## Loading data. ## 
  # This data has to be updated every week. 
  # The data is collected from ScraperWiki and downloaded manually. 
  # There are better methods.
  # The names of the files have to be updated as well. 
  fers.last.week <- read.csv('data/twitter/twitter_followers_june_16.csv')
  fing.last.week <- read.csv('data/twitter/twitter_following_june_16.csv')
  fers.current.week <- read.csv('data/twitter/twitter_followers_june_20.csv')
  fing.current.week <- read.csv('data/twitter/twitter_following_june_20.csv')
  
  # ChangeinFollowers <- function() {}  # write function
  ## Number of following
  n.fing.last.week <- nrow(fing.last.week)
  n.fing.current.week <- nrow(fing.current.week)
  fing.change <- (nrow(fers.current.week) - nrow(fers.last.week))
  per.fing.change <- ((nrow(fing.current.week) - nrow(fing.last.week)) 
                      / nrow(fing.last.week)) * 100
  
  # Following Statistics
  n.fing.last.week
  n.fing.current.week
  fing.change
  per.fing.change
  
  ## Number of followers
  n.fers.last.week <- nrow(fers.last.week)
  n.fers.current.week <- nrow(fers.current.week)
  fers.change <- (nrow(fing.current.week) - nrow(fing.last.week))
  per.fers.change <- (n.fers.current.week - n.fers.last.week) / n.fers.last.week * 100
  
  # Followers Statistics
  n.fers.last.week
  n.fers.current.week
  fers.change
  per.fers.change
  
  # ChangeinReach <- function() {}
  ## Calculating reach. ##
  # Reach here is calculated by 
  reach.last.week <- sum(fers.last.week$followers_count)
  reach.current.week <- sum(fers.current.week$followers_count)
  reach.change <- reach.current.week - reach.last.week
  per.reach.change <- ((reach.current.week - reach.last.week) / reach.last.week) * 100
  
  # Potential Reach Statistics
  reach.last.week
  reach.current.week
  reach.change
  per.reach.change
  
  
  ## Most important members of the our followership ## 
  fers.current.week$follower_count <- as.numeric(fers.current.week$follower_count)
  
  write.csv(fers.current.week, file = 'test.csv')  # doing the ordering in Excel. Below not working.
  
  
  # fing.most.important <- fers.current.week[head(order(-fers.last.week$following_count)), ]
  # fers.least.important <- fers.current.week[head(order(fers.last.week$following_count)), ]
  # 
  # fing.most.important <- fing.current.week[head(order(-fers.last.week$following_count)), ]
  # fers.least.important <- fing.current.week[head(order(fers.last.week$following_count)), ]
  
  ## Tweets ##
  # Save this section for analyzing the most important 
  # tweet of the week. 
  # 
  # 
  # ## Saving the output ##
  # variables <- c('Reach', 'Followers', 'Following')
  # reach <- data.frame(reach.last.week, reach.current.week, reach.change)
  # followers <- data.frame()
  # following <- 
  # 
  # twitter.report <- data.frame(variables, as.list(reach))
  # 
  # names(twitter.report) <- c('Variables', 'Last Week (April 16)', 'Current Week (April 25)', 'Change')
  
  # Store in a data_base with append.
  db <- dbConnect()
  dbWriteTable(db, "_twitter_meta")
  dbWriteTable(db, "")
  
  
  # output
  z
  
  
}




