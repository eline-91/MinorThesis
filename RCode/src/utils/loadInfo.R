# Script that contains functions to load information into functions.
# Information is taken from the configuration.yaml file that is located in
# /home/eline91/shared/Code/RCode/

library(yaml)
config = "/home/eline91/shared/Code/RCode/configuration.yaml"
info = yaml.load_file(config)

get_reclassMatrix = function(){
  # Function to return matrix to reclassify predicted raster to the proper codes.
  codes = get_codes()
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

# TODO: should become get_classes
get_legend = function() {
  #legend=c("Bareland", "Cropland", "Forest", "Grassland", "Shrubland", "Urban", "Water")
  classes = info$classification$classes
  return(classes)
}

get_colors = function() {
  #colors=c("khaki4", "gold", "darkgreen", "lawngreen", "purple", "red", "blue")
  colors = info$classification$colors
  return(colors)
}

get_codes = function() {
  codes = info$classification$codes
  return(codes)
}

get_bandPattern = function() {
  bandPattern = info$dataset$bandPattern
  return(bandPattern)
}

get_tile = function() {
  tile = info$dataset$tile
  return(tile)
}

get_tempDir = function() {
  tempDir = info$folders$temp
  return(tempDir)
}

get_inputDir = function() {
  inputDir = info$folders$NDVI_images
  return(inputDir)
}