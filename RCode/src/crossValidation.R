#!/usr/bin/env Rscript

# Script to perfom cross validation. Input is the number of folds. Other needed
# data is taken from the configuration.yaml file. These are: training variables
# (csv file), and filename of the output csv file with the accuracy statistics.

# Output is a csv file with the confusion matrix, and error statistics 
# (producer's and user´s accuracy, errors of omission and commission, and kappa 
# coefficient and overall accuracy.)

# Can be run via the command line, via for example:
# R --slave --no-restore --file=crossValidation.R --args --folds=5

library(ranger)
library(raster)
library(caret)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadData.R")
source("utils/loadInfo.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--folds", type="integer", default=5,
                    help="Number of folds to use for cross validation. (Default: %default)", 
                    metavar="integer")
args = parse_args(parser)

# Function that calculates producer's accuracy based on the confusion matrix.
calc_producersAcc = function(confMatrix) {
  accs = list()
  for (i in 1:dim(confMatrix)[1]) {
    correct = confMatrix[i,i]
    total = sum(confMatrix[,i])
    acc = correct/total
    accs = list(accs, acc)
  }
  accs = unlist(accs)
  return(accs)
}

# Function that calculates user's accuracy based on the confusion matrix.
calc_usersAcc = function(confMatrix) {
  accs = list()
  for (i in 1:dim(confMatrix)[1]) {
    correct = confMatrix[i,i]
    total = sum(confMatrix[i,])
    acc = correct/total
    accs = list(accs, acc)
  }
  accs = unlist(accs)
  return(accs)
}

cross_validate = function(folds = args[["folds"]]) {
  
  validationData = load_trainingData(sp=T)[-(c(1,3))]
  folds = createFolds(validationData$class.name, folds)
  predictions = data.frame(observed = validationData$class.name)
  predictions$predicted = NA
  
  classes = info$classification$classes
  predictions$predicted = factor(predictions$predicted, levels=c(seq(1,7)), 
                                 labels = classes)
  
  # Repeat for each fold
  for (i in 1:length(folds)) {
    # Make an rf model for all data except the current fold
    rfmodel = ranger(class.name ~ ., validationData@data[-folds[[i]],], 
                     seed = 123456)
    
    # Predict to the remaining locations
    rfprediction = predict(rfmodel, 
                           validationData@data[folds[[i]],])$predictions
    
    predictions$predicted[folds[[i]]] = rfprediction
  }
  
  # Make the confusion matrix based on the observed and predicted values
  confusion = confusionMatrix(data = predictions$predicted, 
                              reference = predictions$observed)
  
  # Calculate accuracies
  confusionTable = confusion$table
  prod_acc = calc_producersAcc(confusionTable)
  us_acc = calc_usersAcc(confusionTable)
  om_error = 1 - prod_acc
  com_error = 1 - us_acc
  k = confusion$overall["Kappa"]
  overall_acc = confusion$overall["Accuracy"]
  names(overall_acc) = "OverallAccuracy"
  
  # Add accuracies to the table
  confusionTable = rbind(confusionTable, producersAccuracy = prod_acc)
  confusionTable = rbind(confusionTable, usersAccuracy = us_acc)
  confusionTable = rbind(confusionTable, omissionError = om_error)
  confusionTable = rbind(confusionTable, commissionError = com_error)
  
  # Get filename to save the accuracy information to
  f = info$validation$accStats_basemap
  
  # Write the accuracy information to file
  write.csv(confusionTable, file = f)
  write.table(k, file = f, append = TRUE, sep=",", col.names = FALSE)
  write.table(overall_acc, file = f, append=TRUE, sep=",", col.names = FALSE)
  
  print(paste0("Results written to: ", basename(f), " located in folder: ", 
               dirname(f)))
  
  return(confusionTable)
}

cross_validate()