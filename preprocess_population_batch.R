# Preprocessing for population data 
# Reads from ./original/ path and dumps into ./processed/ path

# Helper function to remove the commas
remove_commas <- function(df) {
  for (i in 1:nrow(df)) 
    for (j in 1:ncol(df)) 
      df[i,j] <- gsub(",", "", df[i,j])
    
    return(df)
}

# Function to preprocess the year population data 
preprocess_year <- function(file_path) {
  
  year_2000 <- read.csv(file_path, stringsAsFactors=FALSE )
  year_2000[year_2000 == '-'] <- 0
  year_2000 <- remove_commas(year_2000)
  
  # assign row 2 as the header
  for (i in 1:22) {
    colnames(year_2000)[i] <- as.character(year_2000[2,i])
  }
  
  # remove unecessary rows
  year_2000 <- year_2000[-1:-3, ] 
  year_2000 <- year_2000[!(is.na(year_2000$"Planning Area") | year_2000$"Planning Area"==""), ]
  
  # remove unnecessary columns
  year_2000 <- year_2000[,-2]
  year_2000 <- year_2000[,-21:-24]
  
  # rename some columns 
  year_2000$"85_and_over" <- year_2000$"85 & Over"
  year_2000$PLN_AREA_N <- toupper(year_2000$`Planning Area`)
  tmp <- subset(year_2000, select=c('65 - 69', '70 - 74', '75 - 79', '80 - 84', '85_and_over'))
  tmp[tmp == '-'] <- 0
  
  tmp <- remove_commas(tmp)
  tmp <- sapply(tmp, as.numeric)
  df_new = data.frame(rowSums(tmp))
  df_new$"65_AND_OVER"<- df_new$rowSums.tmp.
  df_new <- subset(df_new, select=c('65_AND_OVER'))
  
  year_2000 <- cbind(year_2000, df_new)
  year_2000$ELDERLY_DENSITY <- year_2000$`65_AND_OVER` / as.numeric(year_2000$Total)
  
  is.nan.data.frame <- function(x)
    do.call(cbind, lapply(x, is.nan))
  
  year_2000[is.nan(year_2000)] <- 0
  
  new_file_path <- sub("original", "processed", file_path)
  write.csv(year_2000, file=new_file_path)
  return (year_2000)
}

files <- list.files(path="C:/Users/pierl/OneDrive/Documents/R_Projects/Geospatial_CA/original/", pattern="*.csv", full.names=T, recursive=FALSE)
lapply(files, function(x) {
  out <- preprocess_year(x)
})