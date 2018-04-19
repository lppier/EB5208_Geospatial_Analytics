# Helper function to remove the commas
remove_commas <- function(df) {
  for (i in 1:nrow(df)) 
    for (j in 1:ncol(df)) 
      df[i,j] <- gsub(",", "", df[i,j])
    
    return(df)
}

df <- read.csv("./original/2017.csv", stringsAsFactors=FALSE )
df[df == '-'] <- 0
df <- remove_commas(df)

# assign row 2 as the header
for (i in 1:ncol(df)) {
  colnames(df)[i] <- as.character(df[2,i])
}

# remove unecessary rows
df <- df[-1:-3, ] 
#df <- df[!(is.na(df$"Planning Area") | df$"Planning Area"==""), ]

# remove rows where planning_area is filled in
df <- df[df$"Planning Area"=="",]

# remove planning area column
df <- df[,-1]

# rename some columns 
df$"85_and_over" <- df$"85 & Over"
df$SUBZONE_N <- toupper(df$`Subzone`)

# derive 65_AND_OVER column
tmp <- subset(df, select=c('65 - 69', '70 - 74', '75 - 79', '80 - 84', '85_and_over'))
tmp[tmp == '-'] <- 0
tmp <- remove_commas(tmp)
tmp <- sapply(tmp, as.numeric)
df_new = data.frame(rowSums(tmp))
df_new$"65_AND_OVER"<- df_new$rowSums.tmp.
df_new <- subset(df_new, select=c('65_AND_OVER'))

df <- cbind(df, df_new)
df$ELDERLY_DENSITY <- df$`65_AND_OVER` / as.numeric(df$Total)

# derive 55_AND_OVER column
tmp <- subset(df, select=c('55 - 59', '60 - 64', '65 - 69', '70 - 74', '75 - 79', '80 - 84', '85_and_over'))
tmp[tmp == '-'] <- 0
tmp <- remove_commas(tmp)
tmp <- sapply(tmp, as.numeric)
df_new = data.frame(rowSums(tmp))
df_new$"55_AND_OVER"<- df_new$rowSums.tmp.
df_new <- subset(df_new, select=c('55_AND_OVER'))
df <- cbind(df, df_new)

is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))

df[is.nan(df)] <- 0
write.csv(df, file="./processed_subzone/2017.csv")
