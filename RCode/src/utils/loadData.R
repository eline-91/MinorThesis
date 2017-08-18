# Script that contains functions to load data into functions. If necessary,
# information is taken from the configuration.yaml file.

source("utils/loadInfo.R")

load_groundData = function() {
  # Function to load the ground truth data as a SpatialPointsDataFrame.
  filename = info$classification$ground_truth
  
  data = read.csv(filename)
  coordinates(data) = ~X+Y
  projection(data) = "+proj=longlat +datum=WGS84 +no_defs"
  
  return(data)
}

load_harmonicMetrics = function(version=c("2y", "3y"), only_mean=F) {
  # Function to load the harmonic metrics as a brick and clarify the band names.
  filename = get_metrics(version)
  
  data = brick(filename)
  if(data@file@nbands == 5) {
    names(data) = c("mean.ndvi", "phase.1", "amplitude.1", "phase.2", "amplitude.2")
  } else {
    print(paste0("File contains unknown bands. Number of bands: ", data@file@nbands, 
                 ". Names of bands are left unchanged."))
  }
  
  if(only_mean) {
    return(data[[1]])
  }
  
  return(data)
}

load_demVariables = function() {
  # Function to load the harmonic metrics as a brick and clarify the band names.
  filename = info$classification$dem_variables
  
  data = brick(filename)
  names(data) = c("height", "slope", "aspect", "tpi")
  return(data)
}

load_trainingData = function(sp = FALSE) {
  # Function to load the training variables.
  # Option to return either a data frame (sp = FALSE, default) or a SpatialPointsDataFrame (sp = TRUE)
  
  filename = info$classification$training_variables
  trainingVariables = read.csv(filename)
  coordinates(trainingVariables) = ~X+Y
  projection(trainingVariables) = "+proj=longlat +datum=WGS84 +no_defs"
  
  trainingVariables$X.1=NULL
  trainingVariables$optional=NULL
  trainingVariables$id=NULL
  
  if(!sp){
    df = trainingVariables@data
    df$class.name = as.factor(df$class.name)
    
    return(df)
  } else {
    
    return(trainingVariables)
  }
}

load_trainingRasters = function(version=c("2y", "3y")) {
  metrics = load_harmonicMetrics(version)
  dems = load_demVariables()
  
  trainingRasters = stack(metrics, dems)
  return(trainingRasters)
}