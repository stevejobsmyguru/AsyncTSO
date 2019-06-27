library(messageQueue)
library(config)
library(jsonlite)
library(xts)
#####################################Function Def Area###############################################

Send_outcome_JSON_2_QueueServer = function(obj_Original_JSON,tso_Object_Outcome) {
  
  config_yml = config::get(file ="./config.yml")
  
  queueUrl <- paste0("tcp://",config_yml$Destination_MessageQueueServer_Address,":",config_yml$Destination_MessageQueueServer_PortNum)

  # create a queue producer
  queueproducer <- messageQueue.factory.getProducerFor(queueUrl,config_yml$Outcoming_Response_Queue_Name,config_yml$Type_Message_Queue_Type)
  obj_Original_JSON$TSO_Outcome$Adj_Model_TS_Data = as.json.xts(tso_Object_Outcome$adjustedModel)
  obj_Original_JSON$TSO_Outcome$Anomaly_TS_Data = as.json.xts(tso_Object_Outcome$anomalyPoints)
  obj_Original_JSON$Input_TS_Data = NULL
  
  status <- messageQueue.producer.putText(queueproducer, toJSON(obj_Original_JSON))
  
  # close the producer
  #status <- messageQueue.producer.close(queueproducer)
}
ProcessOutliers_4_MQ_Request = function(lst_MQobject) {
  
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
    print("There may be  no message  in Incoming Queue ")
    return (0)
  }
  
  obj_json_request = fromJSON(msgData$value)
  xts_data = xtsFromJSON(obj_json_request$Input_TS_Data)
  
  tso_object = DetectTSOutliers_UnSupervised(xts_data)
  if (!is.null(tso_object)) {
    Send_outcome_JSON_2_QueueServer(obj_json_request,tso_object)
    print("Anomaly Found")
  }
  return (1)
  
  
}
#####################################Main Calling Area######################################################
options(warn=0)
iteration = 1

while (1) {
  retval = ProcessOutliers_4_MQ_Request(lst_MQObject)
  if (retval ==0) {
    print("R Session Need smart restarts")
    break
  }
    
  iteration = iteration + 1
}
  

