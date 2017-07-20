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

get_colorScheme = function() {
  
  
  
}