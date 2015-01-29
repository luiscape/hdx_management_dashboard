## Collecting user list from HDX
# Progress: deployed.
library(rjson)
library(RCurl)

# ScraperWiki helper function
onSw <- function(p = NULL, d = TRUE, l = 'tool/') {
  if(d) return(paste0(p,l))
  else return(p)
}

# Collect API key from command line.
args <- commandArgs(T)
apikey = args[1]

# Loading helper libaries
source(onSw('code/write_tables.R'))
source(onSw('code/sw_status.R'))

###################
## Configuration ##
###################
PATH = onSw('data/organization_data.csv')
db_table_name = "ckan_organization_data"

# Function to fetch related visualizations
# from HDX.
fetchOrganizations <- function(key = NULL) {
  cat('Downloading data...\n')
  url = 'https://data.hdx.rwlabs.org/api/action/organization_list'
  doc = fromJSON(getURL(url, httpheader = c(Authorization = 'a6863277-f35e-4f50-af85-78a2d9ebcdd3')))
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

# Storing output.
organization_list <- fetchOrganizations(apikey)

############################################
############################################
########### ScraperWiki Logic ##############
############################################
############################################

# Scraper wrapper
runScraper <- function(csv = FALSE, p = NULL, table = NULL) {
  cat('-----------------------------\n')
  cat('Collecting current data.\n')
  data <- parseData(args[1])  # add custom date here (run once!)
  checkData(data)
  # The function parseData returns a string if
  # there isn't new data. Check if the object is a data.frame
  # and then proceed to writting the data in the database.
  if (is.data.frame(data)) {
    writeTable(data, 'ckan_organization_data', 'scraperwiki')
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
           system('mail -s "CKAN Statistics: Organization list failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')