## Course Project Execution R Source - Getting and Cleaning Data produced by Tae Wook Oh
## run_analysis.R

library(reshape2)

filename <- "2FUCI HAR Dataset.zip"

## 1. Download the dataset from the site and unzip the dataset

if(!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}

if(!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}


## 2. Load the activity and feature info to R dataset

activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_Labels[,2] <- as.character(activity_Labels[,2])

feactures <- read.table("UCI HAR Dataset/features.txt")
feactures[,2] <- as.character(feactures[,2])

## 3. Load trainning datasets and test datasets, 
## including only columns that reflect mean / standard deviation value

Features_static_Labels <- grep(".*mean.*|.*std.*", feactures[,2])
Features_static_Labels.names <- feactures[Features_static_Labels,2]
Features_static_Labels.names = gsub('-mean','Mean',Features_static_Labels.names)
Features_static_Labels.names = gsub('-std','Std',Features_static_Labels.names)
Features_static_Labels.names <- gsub('[-()]','', Features_static_Labels.names)

## 4. Load the activity and subject data for each dataset, 
## and merge those columns with dataset

train_ds <- read.table("UCI HAR Dataset/train/X_train.txt")[Features_static_Labels]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_ds <- cbind(train_subjects, train_activities, train_ds)

test_ds <- read.table("UCI HAR Dataset/test/X_test.txt")[Features_static_Labels]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_ds <- cbind(test_subjects, test_activities, test_ds)

## 5. Merge two datasets
final_ds <- rbind(train_ds,test_ds)
colnames(final_ds) <- c("subject","activity",Features_static_Labels.names)

## 6. Convert activity and subject columns into meaningful and descriptive factor
final_ds$activity <- factor(final_ds$activity, levels=activity_Labels[,1],labels=activity_Labels[,2])
final_ds$subject <- as.factor(final_ds$subject)

final_ds.melted <- melt(final_ds, id=c("subject","activity"))
final_ds.mean <- dcast(final_ds.melted, subject + activity ~ variable, mean)

## 7. Create a tidy dataset that consists of average value of each variable  
## 8. End results will be saved as tidy.txt file
write.table(final_ds.mean, "tidy.txt", row.names=FALSE, quote=FALSE)




