library(raster)
source("utils/SetTempPath.R")
source("utils/loadData.R")

merge_data = function() {
  
  groundData = load_groundData()
  metrics = load_harmonicMetrics()
  
  data = extract(metrics, groundData, method = "simple", cellnumbers=T, sp=T)
  print(anyNA(data@data))
  
  write.csv(data, "../../../userdata3/TrainingData/TrainingData_variables.csv")
  
}

merge_data()