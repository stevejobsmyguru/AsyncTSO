# Detects anomalies in a time series using TSOutliers that is advanced in current world
#
# Args:

# load libs
#require(influxdbr2)
require(xts)
require(zoo)
library(tsoutliers)

mergeLists = function(first, second) {
  values <- list(first, second)
  coln <- unique(unlist(lapply(values, names)))
  names(coln) <- coln
  lapply(coln, function(ni)
    unlist(lapply(values, `[[`, ni)))
}


DetectTSOutliers_UnSupervised <- function (result_xts) {
  Sys.setenv(TZ = "UTC")

  storage.mode(result_xts) <- "numeric"
  #Omitting NA Value. Also In the case of misssing data in between two rows,  supply the Previous value with the help of fill(previous)
  result_xts <- na.omit(result_xts)


  #Apply Scaling
  maxVal <- max(result_xts)
  scale <- 1
  if (maxVal > 100000000)
  {
    scale <- 1000000
  }
  result_xts <- result_xts / scale


  num_obs <- length(result_xts)


  ts_obj <- as.ts(result_xts)
  tsoutliersObj <- NULL

  tryCatch({
    #It calls Level Shift Outliers that are very important for ResponseTime and TPS, TransCount KPI Anomlay Detection
    tsoutliersObj <- suppressWarnings(tso(ts_obj,types=c("LS"),remove.method = c("en-masse"),tsmethod = c("stsm"),args.tsmodel = list(model = "local-level")))

  },
  warning = function(w) {
    print(paste('warning:', w))
  },
  error = function(e)  {
    print(paste('error:', e))
  })

  if(is.null(tsoutliersObj))
  {
    return(NULL)
  }

  #revert scaling applied earlier
  if (scale > 1)
  {
    result_xts <- result_xts * scale
  }

  ##get xts with the anomaly time series
  if (!is.null(tsoutliersObj$outliers) &&
      nrow(tsoutliersObj$outliers) > 0) {
    anomalyPoints <- result_xts[tsoutliersObj$outliers$ind]
    #type is character (or factor), xts can't be muti typed.
    storage.mode(anomalyPoints) = "character"
    #For Some reason the merge call is not working in Shiny based appplication
    #anomalyPoints <-  merge(anomalyPoints, (as.xts(tsoutliersObj$outliers, order.by = index(anomalyPoints)))$type)
    anomalyPoints <-  cbind(anomalyPoints, (as.xts(tsoutliersObj$outliers, order.by = index(anomalyPoints)))$type)
    names(anomalyPoints)[1] <- "AnomalyValue"
    names(anomalyPoints)[2] <- "Model"
  } else {
    anomalyPoints <- NULL
  }


  adjustedModel <-
    as.xts(as.numeric(tsoutliersObj$yadj),order.by = index(result_xts))
  colnames(adjustedModel) <- colnames(result_xts)
  if (scale > 1) adjustedModel<- adjustedModel * scale

  #######################Managing Minus Values in the Adjusuted Model ##########################################
  #Sometime, Model value becomes negative even with the above Add-featuring  and reverse-featuring. So I am calling to make to Near zero
  # value like 0.1

  for ( i in 1 : nrow(adjustedModel) )
    if (adjustedModel[i,1] < 0 ) # If negative value
      adjustedModel[i,1] <- 0.1

  ##############################################################################################################

  structure(
    list(
      original = result_xts,
      anomalyPoints = anomalyPoints,
      adjustedModel = adjustedModel
    )
    ,
    class = "DataOutliers"
  )

}
