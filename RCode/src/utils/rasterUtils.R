# Utility function for the raster package. For sourcing, not calling.
# Code taken from Dainius Masiliunas.
# https://github.com/GreatEmerald/master-classification/blob/master/src/utils/raster-utils.r

# A wrapper for the mosaic function of the raster package, to allow it to
# accept lists.
setMethod('mosaic', signature(x='list', y='missing'), 
          function(x, y, fun, tolerance=0.05, filename="", overwrite=FALSE){
            stopifnot(missing(y))
            args <- x
            if (!missing(fun)) args$fun <- fun
            if (!missing(tolerance)) args$tolerance<- tolerance
            if (!missing(filename)) args$filename<- filename
            if (!missing(overwrite)) args$overwrite<- overwrite
            do.call(mosaic, args)
          })