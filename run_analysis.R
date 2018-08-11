##install libraries
library(tibble)
library(magrittr)
library(dplyr)

##Download Data + unzip

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./projectfiles.zip")
unzip(zipfile="./projectfiles.zip", exdir= "./projectfiles")


##read data

xtrain <- read.table("./projectfiles/UCI HAR Dataset/train/X_train.txt") %>% as_tibble 
ytrain <- read.table("./projectfiles/UCI HAR Dataset/train/Y_train.txt") %>% as_tibble 
strain <- read.table("./projectfiles/UCI HAR Dataset/train/subject_train.txt") %>% as_tibble 

xtest <- read.table("./projectfiles/UCI HAR Dataset/test/X_test.txt") %>% as_tibble
ytest <- read.table("./projectfiles/UCI HAR Dataset/test/Y_test.txt") %>% as_tibble
stest <- read.table("./projectfiles/UCI HAR Dataset/test/subject_test.txt") %>% as_tibble

headers <- read.table("./projectfiles/UCI HAR Dataset/features.txt")

actlab <- read.table("./projectfiles/UCI HAR Dataset/activity_labels.txt")


##Combine into single tibble, add headers, replace activity number with text name and remove unnecessary data

xtot <- bind_rows(xtest, xtrain)
ytot <- bind_rows(ytest, ytrain)
stot <- bind_rows(stest, strain)
tot <- bind_cols(stot, ytot, xtot)

heads <- as.character(headers$V2)
clean_heads <- make.names(heads, unique = TRUE)
colnames(tot) <- c("subject", "activity", clean_heads)

tot$activity <- factor(tot$activity, levels = actlab[,1], labels = actlab[,2])

rm(xtrain, ytrain, strain, xtest, ytest, stest, headers, actlab, xtot, ytot, stot)

##extract measurements/columns only relating to mean and standard deviation (retaining subject and activity)

target <- grep("subject|activity|mean|std",  colnames(tot), ignore.case = TRUE)
target <- tot[, target]


##create a second, independent tidy data set with the average of each variable for each activity and each subject

sumr <- target %>% group_by(subject, activity) %>% summarise_all(funs(mean)) 

##write to .txt file

write.table(sumr, file = "tidy_data.txt", sep = "\t", row.name=FALSE)
