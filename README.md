# AsyncTSO
This Utility is meant to call Outliers Detection on Time Series Data set using MessageQueue Design and Architecture. It is believed that this utility is compatable in Linux (64 bit)and Windows (64 bit)

Thew following are the steps to be follwoed
1) To run this Utility, You need to have R (Latest Version). 
2)Also You need to compile KFKSDS, stsm and TSOutliers R Pacakge by unzipping the R Pacakges and "Rebuild the Pacakge one by one. ( You will have install config & jsonlite, xts/zoo  R Pacakges too)
3) Install JDK 11.x version and run R CMD javareconf. You may need to hussle thru settings by passing javac, javah, java parameters. Pls. refer the online help by doing googling to fix the Java settings 
4) Download messageQueue R Package from r-forge repository; You must download rJava Pacakges. Be watchful on errors
5) Small Hack /Tips: messageQueue Package can be directly copied to R Package location because messageQueue is trying to run some set of unit testing pacakge. It is expected to fail because it is trying to connect ActiveMQ from Author IP Address.
6) You need to configure ActiveMQ endpoint IP Address in the config.yml file.

# Important Note

1) Pls. play with example code and test time series data in the ML_Algo_Test_Area subfolder before you want refer set of R files in the root folder level
   - Based on your learning from Samples, you will create input data. Input data is advised to be in JSON Style.
   - I advise you to spend 1 day on playing how to send input JSON Data to Queue and how to read and pass it to ML APIs

2) There is some limitation I noticed on JMS api calls used by messageQueue Package. 
   - When there is no messages in ActiveMQ, the Main caller section tries in loop. Some times, it goes mad.
   - So, I made such a way that if there is no message in queue location during firest attempy, It comes out gracefully.
   - So, You would need to create Pwoershell ( in windows) / Shell script ( in Lniux) to search for the Process name ( by R File). If it does not exist, then kick start in the Shell script commands in automated way.
