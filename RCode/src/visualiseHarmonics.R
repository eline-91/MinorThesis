# Script to visualise the harmonic metrics
# Largely based on code by Dainius Masiliunas:
# https://github.com/GreatEmerald/master-classification/blob/master/src/validation/visualise-harmonics.r

source("utils/loadData.R")
source("utils/loadInfo.R")

trainingData = load_trainingData(sp=T)

#from here edit 
tscurve = function(classname, ...)
{
  clsi = trainingData@data$class.name == classname
  curvefunc = function(x)
  {
    # 1 -> 0, 13 -> tau
    x = x-1 # 0-12
    x = x/12*2*pi
    mean(trainingData@data[clsi,"mean.ndvi"])+
      mean(trainingData@data[clsi,"amplitude.1"])*cos(x+mean(trainingData@data[clsi,"phase.1"]))+
      mean(trainingData@data[clsi,"amplitude.1"])*sin(x+mean(trainingData@data[clsi,"phase.1"]))+
      mean(trainingData@data[clsi,"amplitude.2"])*cos(2*(x+mean(trainingData@data[clsi,"phase.2"]))) +
      mean(trainingData@data[clsi,"amplitude.2"])*sin(2*(x+mean(trainingData@data[clsi,"phase.2"])))
  }
  curve(curvefunc, from=1, to=13, ylab="NDVI", xlab="Month", xaxp=c(1, 12, 11), ylim=c(-0.1, 1.1), ...)
}

pdf("../../../userdata3/output/thesisFigures/timeseries.pdf", width=7, height=4)
opar = par()
par(mar=c(5.1,4.1,1.1,8.1))
tscurve("Cropland", col="gold")
tscurve("Forest", col="darkgreen", add=TRUE)
tscurve("Shrubland", col="purple", add=TRUE)
tscurve("Grassland", col="lawngreen", add=TRUE)
tscurve("Bareland", col="khaki4", add=TRUE)
tscurve("Urban", col="red", add=TRUE)
tscurve("Water", col="blue", add=TRUE)
par(xpd=TRUE)
legend(13.5, 1, lty=1,
       legend=get_classes(),
       col=get_colors())
par(opar)
dev.off()