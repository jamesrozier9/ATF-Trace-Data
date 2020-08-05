
# Some initial cleanup
rm(list=ls())

# Set working directory to project folder
setwd("C:\\Users\\User\\Desktop\\project\\data")

# Specify packages required
packages = c("readxl", "tidyr")

# Load/install & load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
) # Source: https://vbaliga.github.io/verify-that-r-packages-are-installed-and-loaded/


# Convert xlsx files to csv
for (i in list.files()) {
  df.xls <- read_excel(i) # Read .xls docs
  colnames(df.xls) <- df.xls[1,] # Assign row 1 to be column names
  colnames(df.xls)[1:3] <- c("Type", "STi", "T2C") # Fill NAs with real column names
  df.xls <- df.xls[-1,-1] # Remove unnecessary row/column
  df.xls <- df.xls %>% fill(STi) # Fill NAs with state names (first instance)
  df.xls <- pivot_longer(df.xls, cols = 3:length(df.xls), names_to = "STj", values_to = "COUNT") # Pivot table
  df.xls$YEAR <- gsub("[^0-9]", "", unlist(i)) # Assign year in name in file as year variable
  df.xls <- df.xls[complete.cases(df.xls),] # Exclude missing values in rows
  name <- paste("t2c", gsub("[^0-9]", "", unlist(i)), sep = "_") # Assign file name
  filename <- paste(name, ".csv", sep = "") # Complete file name with doctype
  write.csv(df.xls, file = filename, row.names = FALSE) # Create .csv
  rm(list="df.xls") # Remove .xls doc
}

# Read csv files in environment
t2c_files <- list.files()[grep("t2c*", list.files())] # Create list of T2C files in folder
df_T2C = NULL # Create blank object
for (i in t2c_files) {
  filename <- gsub(".csv", "", unlist(i)) # Create filename from folder list
  j <- paste(".\\", i, sep = "") # Assign filename to object
  x = read.csv(j, header = T) # Read .csv objects
  df_T2C = rbind(df_T2C, x) # Row-bind T2C objects
  rm(list="x") # Remove loop created object
  #assign(filename, read.csv(j, header = TRUE)) # Create T2C objects for each year
}

# Create .csv from loop
write.csv(df_T2C, file = "C:\\Users\\User\\Desktop\\project\\data\\T2C_all.csv", row.names = F)

