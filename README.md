# AsyncTSO
This Utility is meant to call Outliers Detection on Time Series Data set using MessageQueue Design and Architecture. It is believed that this utility is compatable in Linux (64 bit)and Windows (64 bit)

Thew following are the steps to be follwoed
1) To run this Utility, You need to have R (Latest Version). 
2)Also You need to compile KFKSDS, stsm and TSOutliers R Pacakge by unzipping the R Pacakges and "Rebuild the Pacakge one by one.
3) Install JDK 11.x version and run R CMD javareconf. You may need to hussle thru settings by passing javac, javah, java parameters. Pls. refer the online help
4) Download messageQueue R Package from r-forge repository; You must download rJava Pacakges. Be watchful on errors
5) Small Hack /Tips: messageQueue Package can be directly copied to R Package location because messageQueue is trying to run some set of unit testing pacakge. It is expected to fail because it is trying to connect ActiveMQ from Author IP Address.
6) You need to configure ActiveMQ endpoint IP Address in the config.yml file.
