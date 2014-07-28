#### Twitter ####
# Preparing Twitter data for analysis. 

runTwitterAnalysis <- function(df = NULL) {
  
  # Sanity check.
  if (is.null(df) == TRUE) stop('Provide a data.frame.')
  
  ## Loading data. ## 
  # Loading data from the respective files in the data folder.
  output <- data.frame(df$Followers$date)
  
  for(i in 1:(nrow(data$Followers) - 1)) { 
  
    followers_file <- paste0('twitter/data/', df$Followers$file_name[i])
    following_file <- paste0('twitter/data/', df$Following$file_name[i])
    
    followers <- read.csv(followers_file)
    following <- read.csv(following_file)
    
    
    # ChangeinFollowers <- function() {}  # write function
    ## Number of following
    n_followers <- nrow(followers)
    n_following <- nrow(following)
    
    
    if (i == 1) {
      output$n_followers <- n_followers
      output$n_following <- n_following
    }
    else { 
      output$n_followers[i] <- n_followers
      output$n_following[i] <- n_following
    }
    
    # Calculating change. 
    if (i == 1) { 
      output$n_change_followers <- output$n_followers[i] - output$n_followers[i + 1]
      output$n_change_following <- output$n_following[i] - output$n_following[i + 1]
      
      p_change_followers <- 
        (
          (output$n_followers[i] - output$n_followers[i + 1]) / 
          (output$n_followers[i + 1])
        ) * 100
      
      output$p_change_followers <- round(p_change_followers, 2)
  
        
      p_change_following <- 
          (
            (output$n_following[i] - output$n_following[i + 1]) / 
              (output$n_following[i + 1])
          ) * 100
      
    output$p_change_following <- round(p_change_following, 2)
    
    }
    else { 
      output$n_change_followers[i] <- output$n_followers[i] - output$n_followers[i + 1]
      output$n_change_following[i] <- output$n_following[i] - output$n_following[i + 1]
      
      p_change_followers <-
        (
          (output$n_followers[i] - output$n_followers[i + 1]) / 
            (output$n_followers[i + 1])
        ) * 100
      output$p_change_followers[i] <- round(p_change_followers, 2)
      
      p_change_following <- 
        (
          (output$n_following[i] - output$n_following[i + 1]) / 
            (output$n_following[i + 1])
        ) * 100
      output$p_change_following[i] <- round(p_change_following, 2)
    }
    if (i == nrow(df$Followers)) { 
      output$n_change_followers[i] <- NA
      output$n_change_following[i] <- NA
      output$p_change_followers[i] <- NA
      output$p_change_following[i] <- NA
    }
    
#     
#     # Following Statistics
#     n.fing.last.week
#     n.fing.current.week
#     fing.change
#     per.fing.change
#     
#     ## Number of followers
#     n.fers.last.week <- nrow(fers.last.week)
#     n.fers.current.week <- nrow(fers.current.week)
#     fers.change <- (nrow(fing.current.week) - nrow(fing.last.week))
#     per.fers.change <- (n.fers.current.week - n.fers.last.week) / n.fers.last.week * 100
#     
#     # Followers Statistics
#     n.fers.last.week
#     n.fers.current.week
#     fers.change
#     per.fers.change
#     
#     # ChangeinReach <- function() {}
#     ## Calculating reach. ##
#     # Reach here is calculated by 
#     reach.last.week <- sum(fers.last.week$followers_count)
#     reach.current.week <- sum(fers.current.week$followers_count)
#     reach.change <- reach.current.week - reach.last.week
#     per.reach.change <- ((reach.current.week - reach.last.week) / reach.last.week) * 100
#     
#     # Potential Reach Statistics
#     reach.last.week
#     reach.current.week
#     reach.change
#     per.reach.change
#     
#     
#     ## Most important members of the our followership ## 
#     fers.current.week$follower_count <- as.numeric(fers.current.week$follower_count)
#     
#     write.csv(fers.current.week, file = 'test.csv')  # doing the ordering in Excel. Below not working.
#     
#     
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
    
  }
  # output
  output
  
}




