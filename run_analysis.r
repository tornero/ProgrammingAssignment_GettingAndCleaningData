# run_analysis.R
library(reshape2)

# setwd("~/devel/coursera/getting_cleaning_data/getting_cleaning_data_project")

# this could be completely automated to download, unzip, etc.
# download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
#               destfile = "getdata-projectfiles-UCI HAR Dataset.zip", 
#               method = "curl")

# unzip(zipfile = "getdata-projectfiles-UCI HAR Dataset.zip")

DATADIR <- "UCI HAR Dataset"

# Combine Test Data
# The "y" files are the id of activity
# The "subject" files are the id of the subject

# Create a list of activities from the y_file and activity names
# This will allow us to use activity names instead of numbers in the tidy_data
activities   <- read.table(file= paste(DATADIR, "activity_labels.txt", sep = "/"), 
                           col.names = c("Activity.ID", "Activity.Name"))
y_test       <- read.table(paste(DATADIR, "test", "y_test.txt",        sep = "/"),
                           col.names = c("Activity.ID"))
y_activities <- merge(y_test, activities, by.x="Activity.ID", by.y="Activity.ID")
Activity     <- y_activities[,2]

# Create a vector of feature names
# This will allow us to apply the column names to the data
features     <- read.table(paste(DATADIR, "features.txt", sep ="/"), 
                           col.names = c("Feature.Number", "Feature.Name"))
features     <- features[,2]

# Create a data.frame of the subject
subject_test <- read.table(file = paste(DATADIR, "test", "subject_test.txt", sep = "/"),
                           col.names = c("Subject"))

# Read in the test data and apply the feature column names
x_test       <- read.table(file = paste(DATADIR, "test", "X_test.txt", sep = "/"),
                           col.names = features)

# Combine the subject, activity, and test data.frames into one data.frame
test_data    <- cbind(subject_test, Activity, x_test)

# Combine Training Data
# This is very similar to the above, but for the training data
y_train       <- read.table(paste(DATADIR, "train", "y_train.txt",        sep = "/"),
                            col.names = c("Activity.ID"))
y_activities  <- merge(y_train, activities, by.x="Activity.ID", by.y="Activity.ID")
Activity      <- y_activities[,2]

subject_train <- read.table(file = paste(DATADIR, "train", "subject_train.txt", sep = "/"),
                            col.names = c("Subject"))
x_train       <- read.table(file = paste(DATADIR, "train", "X_train.txt", sep = "/"),
                            col.names = features)

train_data    <- cbind(subject_train, Activity, x_train)

# Combine Test & Train data (append the data.frames)
data          <- rbind(test_data, train_data)

# Keep only the columns that are mean or standard deviation
# Use grep to find the column names that are either mean or std
data_mean_std <- data[,c("Subject",
                         "Activity",
                         grep("mean|std", colnames(data), value=TRUE))
                      ]

# melt the data by subject/activity
sub_act_data  <- melt(data_mean_std, id.vars=c("Subject","Activity"))

# cast the data by subject/activity and calculate the average of the variables
tidy_data     <- dcast(sub_act_data, Subject + Activity ~ variable, mean)

# write the tidy_data to a file
write.table(tidy_data, row.name=FALSE, file = "tidy_data.txt")

# Output just the column names of tidy_data for CodeBook.md
# cat(names(tidy_data), sep="\n")