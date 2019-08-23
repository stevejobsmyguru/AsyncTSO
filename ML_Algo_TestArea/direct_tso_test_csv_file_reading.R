library(xts)
ColClasses = c( "character","numeric")

#Pls. change to local folder - full path to point the Timeseries CSV file

Data <- read.zoo("/Users/harisankara/Documents/AlgoSoft/WarGames/Wargame_MediaSystem/BotsRunArea/ML_Algo_TestArea/Kohl_BB_Data.csv", index.column = 1, sep = ",", header = TRUE, FUN = as.POSIXct, colClasses = ColClasses)
xts_data = as.xts(Data)
ts0_object = DetectTSOutliers_UnSupervised(xts_data)
print(ts0_object$anomalyPoints)
print("Ends here")