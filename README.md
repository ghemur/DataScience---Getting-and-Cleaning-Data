---
title: "README"
---

This document explains some of the decisions in my code, captured in run_analysis.R.

First of all, I use a project folder called projectData, where the smartphones.zip file gets downloaded and unzipped, where the output files get written, and where I save my README.md and CodeBook.md documentation.
This avoids mixing all these project resources with files in whatever the working directory is set to be.

My original solution followed the steps of the requirements in the exact order in which hey were listed. However, there were some inefficiencies, so I've decided to change my solution into what I would use in a real project, rather than an assignment.

Briefly, it's inefficient to first merge all the training and test data, and only then drop the un-needed columns. It's more efficient to do the column selection first.

Then, as the code to read and process data is the same for test and training data, I defined a function that does that, and called it for the 2 parts before putting the two parts together:
```{r}
trainData <- loadAndProcess("train")
testData <- loadAndProcess("test")
allData <- rbind(trainData, testData)
```

Moreover, I don't want to lose information about which data came from the training and test set, so I capture that detail in a column called "part". In step 5, when I group data and compute summaries, I have the option to use just subject and activity for grouping, or I can also include the part. That's why I have the two output files: means_by_subject_activity.txt and means_by_part_subject_activity.txt.

We are supposed to do some transformation on the variable names. Well, the names were given by domain experts, so it would be hard to improve that. However, I did remove the parentheses, so that, for example "mean()" becomes "mean". I disagree with the advice in the course to use lowercase for variable names (the reasoning is that it's easier to type if you don't need to mix cases and to use special characters). See https://en.wikipedia.org/wiki/Naming_convention_(programming). Readability is more important - isn't "tGravityAcc-mean-Z" easier to read than "tgravityaccmeanz". So I've decided to keep the original capitalization and uses of dashes ("-").

From the feature description at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones I learned that the data in the Inertial Signals folder consisted of raw acceerometer and gyroscope reading, as oposed to mean or std. As such data is not needed, I chose not to even open those files.

I implemented step 5 in several ways:
First, I like the fluidity of the pipe operator in dplyr, as well as its grouping and summarizing capabilities, so that was the first option. Even here I wrote 2 alternatives:
- one is to do grouping and summarizing strictly as specified in the requirements, by subject identifier and type of activity; the output is in means_by_subject_activity.txt;
- the other is to include part (i.e. training vs testing) in grouping; the output is in means_by_part_subject_activity.txt.

Secondly, I used the melting and dcasting procedure exemplified in the course. The output, in reshapedData.txt, is actually identical to means_by_subject_activity.txt.

However, one can notice that not all 180 combinations of 30 subjects and 6 activities are present in the data. dplyr's summarization functionality as well as reshape2's dcast drop the missing combinations; there's no option to include them, filled with zeros or NAs. So I additionally used plyr's ddply function, in which I can request not to drop the empty combinations. This give the additional output file all_means.txt.

To read any of these output files, one should use:
```{r}
read.table(file_path, header = TRUE)
```

Note that the output is indeed tidy data:
- the entire data frame contains related measurements from smartphone signals;
- each row represents one processed reading of signals;
- each column represents a metric.


