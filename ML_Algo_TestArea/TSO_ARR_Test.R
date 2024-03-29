library(xts)
ColClasses = c( "character","numeric")
Data <- read.zoo("~/MyOpenSource/AsyncTSOutliers/ML_Algo_TestArea/Kohl_BB_Data.csv", index.column = 1, sep = ",", header = TRUE, FUN = as.POSIXct, colClasses = ColClasses)
xts_data = as.xts(Data)
ts0_object = DetectTSOutliers_UnSupervised(xts_data)
print(ts0_object$anomalyPoints)
print("Ends here")