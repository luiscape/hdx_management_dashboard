## Collecting user list from HDX
# Progress: deploy.
library(rjson)
library(RCurl)


# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/ckan/') {
  if(d) return(paste0(p,l))
  else return(p)
}

# Collect API key from command line.
args <- commandArgs(T)
apikey = args[1]
PATH = onSw('data/user_data.csv')
db_table_name = "ckan_user_data"

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

# Function to fetch a list of users
# from HDX.
fetchUsers <- function(key = NULL) {
  cat('Downloading data...\n')
  url = 'https://data.hdx.rwlabs.org/api/action/user_list'
  doc = fromJSON(getURL(url, httpheader = c(Authorization = key)))
  total = length(doc$result)

  cat('Assembling data.frame...\n')
  pb <- txtProgressBar(min = 0, max = total, style = 3, char = ".")
  for(i in 1:total) {
    setTxtProgressBar(pb, i)
    it <- data.frame(
      display_name = ifelse(is.null(doc$result[[i]]$display_name), NA, doc$result[[i]]$display_name),
      fullname = ifelse(is.null(doc$result[[i]]$fullname), NA, doc$result[[i]]$fullname),
      name = doc$result[[i]]$name,
      email = ifelse(is.null(doc$result[[i]]$email), NA, doc$result[[i]]$email),
      sysadmin = doc$result[[i]]$sysadmin,
      number_of_edits = doc$result[[i]]$number_of_edits,
      id = doc$result[[i]]$id)

    if (i == 1) out <- it
    else out <- rbind(out, it)
  }

  return(out)
}

############################################
############################################
########### ScraperWiki Logic ##############
############################################
############################################

# Scraper wrapper
runScraper <- function(csv = FALSE, p = NULL, table = NULL) {
  cat('-----------------------------\n')
  cat('Collecting user data.\n')
  data <- fetchUsers(apikey)
  # The function parseData returns a string if
  # there isn't new data. Check if the object is a data.frame
  # and then proceed to writting the data in the database.
  if (is.data.frame(data)) {
    writeTable(data, table, 'scraperwiki')
    m <- paste('Data saved on database.', nrow(data), 'records added.\n')
    cat(m)
  }
  else print(data)
  # Save CSV locally.
  if (csv) write.csv(data, p, row.names = F)
  cat('-----------------------------\n')
}

# Changing the status of SW.
tryCatch(runScraper(p = PATH, table = db_table_name),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "CKAN Statistics: User list failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')
