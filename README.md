---
title: "README"
---

This document explains some of the decisions in my code, captured in run_analysis.R.

First of all, I use a project folder called projectData, where the smartphones.zip file gets downloaded and unzipped, where the output files get written, and where I save my README.md and CodeBook.md documentation.
This avoids mixing all these project resources with files in whatever the working directory is set to be.

My original solution followed the steps of the requirements in the order in which hey were listed. However, there were some inefficiencies, so I've decided to change my solution into what I would use in a real project, rather than an assignment.

Briefly, it's inefficient to first merge all the training and test data, and only then drop the un-needed columns. It's more efficient to do the column selection first.

Then, as the code to read and process data is the same for training data, I defined a function that does that, and called it for the 2 parts before putting the two parts together:
```{r}
trainData <- loadAndProcess("train")
testData <- loadAndProcess("test")
allData <- rbind(trainData, testData)
```

Moreover, I don't want to lose information about which data came from the training and test set, so I capture that detail in a column called "part". In step 5, when I group data and compute summaries, I have the option to use just subject and activity for grouping, or I can also include the part. That's why I have the two output files: means_by_subject_activity.txt and means_by_part_subject_activity.txt.

It's not obvious if we need to include the column names in the output (the header); I chose to do it, so that someone using the data can read the header, if the list of variables is not provided.

We are supposed to do some transformation on the variable names. Well, the names were given by domain experts, so it would be hard to improve that. However, I did remove the parentheses, so that, for example "mean()" becomes "main".

From the feature description at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones I learned that the data in the Inertial Signals folder consisted of raw accelerometer and gyroscope reading, as oposed to mean or std. As such data is not needed, I chose not to even open those files.

Step 5 poses another decisional challenge.
First, I like the fluidity of the pipe operator in dplyr, so I used it to do the grouping and summarizing. However, one can notice that not all 180 combinations of 30 subjects and 6 activities are present in the data. dplyr's summarization functionality drops the missing combinations; there's no option to include them, filled with zeros or NAs. So I additionally used plyr's ddply function, in which I can request not to drop the empty combinations. This give the additional output file all_means.txt.


