# Script that contains functions to load information into functions.
# Information is taken from the configuration.yaml file that is located in
# /home/eline91/shared/Code/RCode/

library(yaml)
config = "/home/eline91/shared/Code/RCode/configuration.yaml"
info = yaml.load_file(config)

get_reclassMatrix = function(){
  # Function to return matrix to reclassify predicted raster to the proper codes.
  codes = info$classification$codes
  order = c(seq(1:length(codes)))
  
  mat = matrix(data = c(order, codes), nrow = 7, ncol = 2)
  
  return(mat)
}

get_illogicalChanges = function() {
  # Function that returns matrix which defines illogical changes
  # 1 = illogical change
  # 0 = possible change
  
  data = info$changeDetection$changeMatrix
  rcNames = info$changeDetection$rcNames

  mat = matrix(data = data, nrow=7, ncol=7, byrow=T)
  rownames(mat) = rcNames
  colnames(mat) = rcNames
  
  return(mat)
}

get_metrics = function(version = c("2y", "3y")) {
  if (version == "2y") {
    return(info$classification$metrics_2y)
  } else if (version == "3y") {
    return(info$classification$metrics_3y)
  } else {
    print("Version unknown. Choose between '2y' and '3y'.")
  }
}