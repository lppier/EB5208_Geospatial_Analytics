# add date field "1/1/YYYY" into all the files
setwd('C:/Users/pierl/OneDrive/Documents/R_Projects/EB5208_Geospatial_Analytics')
add_date_field_and_save <- function(file_name) {
  req_date <- sub(".csv", "", file_name)
  print(req_date)
  # req_date <- paste("", req_date, sep="")
  path_to_read <- file_name
  path_to_read <- paste("./processed/", path_to_read, sep="")
  df <- read.csv(path_to_read, check.names=F, header=T, sep=",")
  list_of_dates <- rep(req_date,nrow(df))
  df_date <- data.frame(list_of_dates)
  df_date$POP_DATE <- df_date$list_of_dates
  df_date <- subset(df_date, select=c('POP_DATE'))
  new_df <- cbind(df, df_date)
  write.csv(new_df, file=path_to_read)
  print(path_to_read)
}


files <- list.files(path="C:/Users/pierl/OneDrive/Documents/R_Projects/EB5208_Geospatial_Analytics/processed/", pattern="*.csv", full.names=F, recursive=FALSE)
lapply(files, function(x) {
  add_date_field_and_save(x)
})

# read all files as dataframes and put them in a list df_list
files <- list.files(path="C:/Users/pierl/OneDrive/Documents/R_Projects/EB5208_Geospatial_Analytics/processed/", pattern="*.csv", full.names=T, recursive=FALSE)
df_list = c()
i = 1
for (file_name in files) {
  df_1 <- read.csv(file_name, check.names=F, header=T)
  df_list[[i]] <- df_1
  i = i + 1
}

# iteratively merge the data frames by row
merged <- data.frame()
for (i in 1:length(df_list)) {
  merged <- rbind(merged, df_list[[i]])
}


write.csv(merged, file='merged.csv')
                