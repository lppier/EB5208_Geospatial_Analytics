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
  
  df <- read.csv(file_path, stringsAsFactors=FALSE )
  df[df == '-'] <- 0
  df <- remove_commas(df)
  
  # assign row 2 as the header
  for (i in 1:ncol(df)) {
    colnames(df)[i] <- as.character(df[2,i])
  }
  
  # remove unecessary rows
  df <- df[-1:-3, ] 
  df <- df[!(is.na(df$"Planning Area") | df$"Planning Area"==""), ]
  
  # remove unnecessary columns
  df <- df[,-2]
  
  # there should only be 21 columns
  if (ncol(df) > 21)
    df <- df[,-21:-ncol(df)]
  
  # rename some columns 
  df$"85_and_over" <- df$"85 & Over"
  df$PLN_AREA_N <- toupper(df$`Planning Area`)
  tmp <- subset(df, select=c('65 - 69', '70 - 74', '75 - 79', '80 - 84', '85_and_over'))
  tmp[tmp == '-'] <- 0
  
  tmp <- remove_commas(tmp)
  tmp <- sapply(tmp, as.numeric)
  df_new = data.frame(rowSums(tmp))
  df_new$"65_AND_OVER"<- df_new$rowSums.tmp.
  df_new <- subset(df_new, select=c('65_AND_OVER'))
  
  df <- cbind(df, df_new)
  df$ELDERLY_DENSITY <- df$`65_AND_OVER` / as.numeric(df$Total)
  
  is.nan.data.frame <- function(x)
    do.call(cbind, lapply(x, is.nan))
  
  df[is.nan(df)] <- 0
  
  new_file_path <- sub("original", "processed", file_path)
  write.csv(df, file=new_file_path)
  return (df)
}

files <- list.files(path="C:/Users/pierl/OneDrive/Documents/R_Projects/EB5208_Geospatial_Analytics/original/", pattern="*.csv", full.names=T, recursive=FALSE)
lapply(files, function(x) {
  out <- preprocess_year(x)
})