# Script to read all the different Twitter files on a single db. 
# and prepare them for visualizations.

readPrepare <- function() { 
  # Load Data
  file_list <- data.frame(list.files('tool/twitter/data/'))
  
  for (i in 1:nrow(file_list)) {
    
    # check what kind of file it is
    if (i == 1) { 
      if (grepl("twitter_followers_", file_list[i,1]) == TRUE) { 
        file_list$type <- "Followers"
      }
      else file_list$type <- "Following"
    }
    else { 
      if (grepl("twitter_followers_", file_list[i,1]) == TRUE) { 
        file_list$type[i] <- "Followers"
      }
      else file_list$type[i] <- "Following"
    }
    
    # Stripping the actual dates from the file names.
    data_pre_d <- gsub("twitter_followers_", "", file_list[i, 1])
    data_pre_d <- gsub("twitter_following_", "", data_pre_d)
    data_pre_d <- gsub(".csv", "", data_pre_d)
    data_pre_d <- gsub("_", " ", data_pre_d)
    
    if (i == 1) file_list$data_pre_d <- data_pre_d
    else file_list$data_pre_d[i] <- data_pre_d
    
    # Converting to Date objects.
    date <- as.Date(file_list$data_pre_d[i], format = '%B %d')
    
    if (i == 1) file_list$date <- date
    else file_list$date[i] <- date
    
  }
  file_list$data_pre_d <- NULL
  names(file_list) <- c('file_name', 'type', 'date')
  z <- split(file_list, file_list$type)
  
  # output
  z
}