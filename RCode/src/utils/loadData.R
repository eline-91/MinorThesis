# Script that contains functions to load data into functions.

load_groundData = function(filename = "../../../userdata3/TrainingData/TotalTrainingData_080617.csv") {
  # Function to load the ground truth data as a SpatialPointsDataFrame.
  
  data = read.csv(filename)
  coordinates(data) = ~X+Y
  projection(data) = "+proj=longlat +datum=WGS84 +no_defs"
  
  return(data)
}

load_harmonicMetrics = function(filename = "../../../userdata3/output/harmonics/phase_amplitude.tif", only_mean=F) {
  # Function to load the harmonic metrics as a brick and clarify the band names.
  
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

load_trainingData = function(trainingData = "../../../userdata3/TrainingData/TrainingData_variables.csv",
                             sp = FALSE) {
  # Function to load the training variables.
  # Option to return either a data frame (sp = FALSE, default) or a SpatialPointsDataFrame (sp = TRUE)
  
  trainingVariables = load_groundData(trainingData)
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