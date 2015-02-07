## Collecting user list from HDX
# Progress: deployed.
library(rjson)
library(RCurl)

# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/ckan/') {
  if(d) return(paste0(l,p))
  else return(p)
}

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

###################
## Configuration ##
###################
PATH = onSw('data/organization_data.csv')
db_table_name = "ckan_organization_data"
args <- commandArgs(T)
apikey = args[1]

###################
## Program Logic ##
###################
# Function to fetch related visualizations
# from HDX.
fetchOrganizations <- function(key = NULL) {
  cat('Downloading data...\n')
  url = 'https://data.hdx.rwlabs.org/api/action/organization_list'
  doc = fromJSON(getURL(url, httpheader = c(Authorization = key)))
  total = length(doc$result)

  cat('Assembling data.frame...\n')
  pb <- txtProgressBar(min = 0, max = total, style = 3, char = ".")
  for(i in 1:total) {
    setTxtProgressBar(pb, i)

    # Querying specific organizations.
    org_id = doc$result[[i]]
    org_url = paste0('https://data.hdx.rwlabs.org/api/action/organization_show?id=', org_id)
    org_doc = fromJSON(getURL(org_url, httpheader = c(Authorization = key)))

    # Assembling a data.frame.
    it <- data.frame(
      display_name = ifelse(is.null(org_doc$result$display_name), NA, org_doc$result$display_name),
      num_followers = ifelse(is.null(org_doc$result$num_followers), NA, org_doc$result$num_followers),
      package_count = ifelse(is.null(org_doc$result$package_count), NA, org_doc$result$package_count),
      number_users = length(org_doc$result$users),
      date = as.character(Sys.Date())
      )

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
runScraper <- function(csv = FALSE, p = NULL, table = NULL, key = NULL) {
  cat('-----------------------------\n')

  data <- fetchOrganizations(key)

  # The function parseData returns a string if
  # there isn't new data. Check if the object is a data.frame
  # and then proceed to writting the data in the database.
  if (is.data.frame(data)) {
    writeTable(data, table, 'scraperwiki')
    m <- paste('\nData saved to database.', nrow(data), 'records added.\n')
    cat(m)
  }
  else print(data)
  # Save CSV locally.
  if (csv) write.csv(data, p, row.names = F)
  cat('-----------------------------\n')
}

# Changing the status of SW.
tryCatch(runScraper(p = PATH, table = db_table_name, key = apikey),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "CKAN Statistics: Organization list failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')