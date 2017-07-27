# Script that contains functions to load information into functions.

get_reclassMatrix = function(){
  # Function to return matrix to reclassify predicted raster to the proper codes.
  data = c(1, 60, # Bareland
           2, 40, # Cropland
           3, 10, # Forest
           4, 30, # Grassland
           5, 20, # Shrubland
           6, 50, # Urban
           7, 80) # Water
  mat = matrix(data = data, nrow=7, ncol=2, byrow=T)
  return(mat)
}

get_legend = function() {
  legend=c("Bareland", "Cropland", "Forest", "Grassland", "Shrubland", "Urban", "Water")
  return(legend)
}

get_colors = function() {
  colors=c("khaki4", "gold", "darkgreen", "lawngreen", "purple", "red", "blue")
  return(colors)
}

get_bandPattern = function() {
  bandPattern = "NDVI_sm_ts.tif$"
  return(bandPattern)
}

get_tile = function() {
  tile = "X16Y06"
  return(tile)
}

get_tempDir = function() {
  tempDir = "../../../userdata3/tmp/"
  return(tempDir)
}