library(messageQueue)
library(config)
library(xts)
#####################################Function Def Area###############################################
createTS_TestData = function() {
  
  ColClasses = c( "character","numeric")
  Data <- read.zoo("~/MyOpenSource/AsyncTSOutliers/ML_Algo_TestArea/Kohl_BB_Data.csv", index.column = 1, sep = ",", header = TRUE, FUN = as.POSIXct, colClasses = ColClasses)
  xts_data = as.xts(Data)
  return(as.json.xts(xts_data))
}
testSendInputJSON_2_QueueServer = function() {
  
  config_yml = config::get(file ="./config.yml")
  
  queueUrl <- paste0("tcp://",config_yml$Destination_MessageQueueServer_Address,":",config_yml$Destination_MessageQueueServer_PortNum)

  # create a queue producer
  queueproducer <- messageQueue.factory.getProducerFor(queueUrl,config_yml$Incoming_Request_Queue_Name,config_yml$Type_Message_Queue_Type)
  msgData <- createTS_TestData()
  status <- messageQueue.producer.putText(queueproducer, msgData)
  
  # close the producer
  status <- messageQueue.producer.close(queueproducer)
}
testReceiveInputJSON_2_QueueServer = function() {
  
  config_yml = config::get(file ="./config.yml")
  
  retry_count = config_yml$Incoming_Request_Retry_count
  
  queueUrl <- paste0("tcp://",config_yml$Destination_MessageQueueServer_Address,":",config_yml$Destination_MessageQueueServer_PortNum)

  # create a queue consumer
  queueconsumer <- messageQueue.factory.getConsumerFor(queueUrl,config_yml$Incoming_Request_Queue_Name,config_yml$Type_Message_Queue_Type)
  
  repeat {
    
    if (retry_count == 0)
      break
    
    msgData <- messageQueue.consumer.getNextText(queueconsumer)
    
    if (!is.null(msgData))
      break
    
    Sys.sleep(config_yml$Breathing_Time_Seconds_4_NextRequest)
    retry_count = retry_count -1
  }
  
  # close the producer
  status <- messageQueue.consumer.close(queueconsumer)

  if (is.null(msgData)){
    print("Somthing Wrong in Queue Server or Broken Network between Queue Server and MyPoint ")
    return (0)
  }
    
  xts_data = xtsFromJSON(msgData$value)
  
  ts0_object = DetectTSOutliers_UnSupervised(xts_data)
  print(ts0_object$anomalyPoints)
}
#####################################Main Calling Area######################################################
options(warn=0)

for (i in 1:1) {
  testSendInputJSON_2_QueueServer()
  #testReceiveInputJSON_2_QueueServer()
  
}
