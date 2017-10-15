# This function makes a nice dataframe containing all information on unique
# changes.

source("utils/loadInfo.R")

makeDF = function() {
  mat = get_uniqueChanges()
  
  cl = c("Forest", "Shrubland", "Grassland", "Cropland", "Urban", "Bareland", "Water")
  rownames(mat) = cl
  colnames(mat) = cl
  
  
  df = data.frame(matrix(ncol = 5, nrow = 49))
  colnames(df) = c("UniqueValues", "FromClass", "ToClass", "Illogical", 
                   "ToSameClass")
  
  ill_mat = get_illogicalChanges()
  
  for(row in 1:nrow(mat)) {
    for(col in 1:ncol(mat)) {
      val = mat[row,col]
      df$UniqueValues[val] = val
      df$FromClass[val] = cl[row]
      df$ToClass[val] = cl[col]
      
      logicality = ill_mat[row,col]
      if (logicality == 1) {
        df$Illogical[val] = 1
      } else {
        df$Illogical[val] = 0
      }
      
      if (cl[row]==cl[col]){
        df$ToSameClass[val] = 1
      } else {
        df$ToSameClass[val] = 0
      }
    }
  }
  return(df)
}
