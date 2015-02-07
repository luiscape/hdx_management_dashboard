
# Function to know how many organizations are sharing data.
fetchAllDatasets <- function(key = NULL) {
  cat('----------------------------------\n')
  cat('Fetching data...\n')
  url = 'https://data.hdx.rwlabs.org/api/action/package_list'
  doc = fromJSON(getURL(url, httpheader = c(Authorization = key)))
  total = length(doc$result)

  data <- data.frame(
    dataset_url = paste0(
      "https://data.hdx.rwlabs.org/api/action/package_list",
      doc$result
      )
    ),
    tagging_complete = FALSE)
  )
  
  cat('Correctly fetched ')
  cat(total)
  cat(' datasets.\n')
  cat('----------------------------------\n')
  return(data)
}

# Collecting data + storing in CSV.
data = fetchAllDatasets(key = )
write.csv(data, "data/dataset_list.csv", row.names=F)