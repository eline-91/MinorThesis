# List all unique image dates per tile

dataDir <- "../../../userdata3/cleanFiles"

listDates <- function(directory) {
  # List all files in directory and select only the first filename per tile-date 
  lf <- list.files(dataDir)
  lf = lf[nchar(lf) == 43]
  
  # List all dates per tile
  # list tiles
  lt <- c()
  for (file in lf) {
    tile <- substr(file, 15, 20)
    if (tile %in% lt == FALSE){
      lt <- c(lt, tile)
    }
  }
  # per tile, list all dates
  v <- c()
  for (tile  in lt) {
    dates <- c()
    for (file in lf) {
      if (substr(file, 15, 20) == tile){
        dates <- c(dates, substr(file, 22,29))
      }
    }
    print(dates)
    print(length(dates))
    
  }
  return(v)
}

li <- listDates(dataDir)



