# run_analysis.R

# Define location of project data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localFolder <- "projectData"
localFile <- paste(localFolder, "smartphones.zip", sep = "/")

# Create local folder, if needed
if(!file.exists(localFolder)) {
    dir.create(localFolder)
}

# Download and unzip project data
download.file(fileUrl, destfile = localFile, method = "curl")
unzip(localFile, exdir = localFolder)

# Define the unzipped project folder, with the data
projectFolder <- paste(localFolder, "UCI HAR Dataset", sep = "/")

# Read activity labels
activities <- read.table(paste(projectFolder, "activity_labels.txt", sep = "/"), col.names = c("activityCode", "activityName"))

# Read features table
featuresDT <- read.table(paste(projectFolder, "features.txt", sep = "/"), col.names = c("featureCode", "featureName"), stringsAsFactors = FALSE)

# Extract the feature names
features <- featuresDT$featureName  # 561 values, 477 distinct
# Get feature names used for mean or std stats
statFeatures <- features[grepl("mean|std", features)]  # 79 values

# My choice of name transformation: removing parentheses from variable name
transformName <- function(name) { gsub("[()]", "", name) }
outputFeatures <- transformName(statFeatures)

outFile <- paste(localFolder, "outputFeatures.txt", sep = "/")
write.table(outputFeatures, outFile, col.names = FALSE, row.names = FALSE, quote = FALSE)

# Define a function that loads and processes the data for each
# of the two parts: train and test
loadAndProcess <- function(part) {
    # File conaining subject code
    subjects_file <- paste(projectFolder, part, paste0("subject_", part, ".txt"), sep = "/")
    # Read data into table
    subjects <- read.table(subjects_file, col.names = "subjectCode", colClasses = "factor")
    
    # File containing (output) activity data
    y_file <- paste(projectFolder, part, paste0("y_", part, ".txt"), sep = "/")
    # Read data into table
    y <- read.table(y_file, col.names = "activityCode")
    # Merge to get activity name
    y_rich <- merge(y, activities, by.x = "activityCode", by.y = "activityCode")
    activityName <- y_rich$activityName
    
    # File containing (input) feature data
    X_file <- paste(projectFolder, part, paste0("X_", part, ".txt"), sep = "/")
    # Read data into table
    X <- read.table(X_file)
    # Assign the features as column names
    names(X) <- features
    # Select just the features that capture main and std stats
    X_stat <- X[, statFeatures]
    # Apply name transformation
    names(X_stat) <- outputFeatures
    
    # Put the columns together
    # The first column will record whether this is training or test data
    data <- cbind(part, subjects, activityName, X_stat)
    
    # Output
    data
}

# Load and process the training and test data, and merge the rows of observations
trainData <- loadAndProcess("train")
testData <- loadAndProcess("test")
allData <- rbind(trainData, testData)
str(allData)

# Now on to step 5
# Requirements are somewhat ambiguous, so I'll use several ways of sumarizing data

library(dplyr)

# I would want the summaries to be separated by training and test parts, not just subjectCode and activityName
means_by_part_subject_activity <- allData %>% group_by(part, subjectCode, activityName) %>% summarize_each(funs(mean))
outFile <- paste(localFolder, "means_by_part_subject_activity.txt", sep = "/")
write.table(means_by_part_subject_activity, outFile, col.names = TRUE, quote = FALSE)

# An alternative is to ignore whether it's training or test data
means_by_subject_activity <- allData %>% select(-part) %>% group_by(subjectCode, activityName) %>% summarize_each(funs(mean))
outFile <- paste(localFolder, "means_by_subject_activity.txt", sep = "/")
write.table(means_by_subject_activity, outFile, col.names = TRUE, quote = FALSE)

# In both alternatives above, dplyr's summarize only keeps the groups that have some data
# If some combinations of subjectCode and activityName have no data, those groups are missing
# While I think that's fine, let's look for a solution that returns 60 * 5 rows, even if some summaries are NA
library(plyr)
all_means <- ddply(allData, .(subjectCode, activityName), numcolwise(mean), .drop = FALSE)
outFile <- paste(localFolder, "all_means.txt", sep = "/")
write.table(all_means, outFile, col.names = TRUE, quote = FALSE)

