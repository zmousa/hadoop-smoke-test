#!/bin/bash

sudo service hue stop
sudo service kafka-server stop
sudo service oozie stop
sudo service hive-server2 stop
sudo service hive-metastore stop
sudo service flume-agent stop
sudo service sqoop2-server stop
sudo service spark-worker stop
#sudo service spark-history-server stop
sudo service spark-master stop
sudo service hbase-thrift stop
#sudo service hbase-rest stop
sudo service hbase-regionserver stop
sudo service hbase-master stop
#sudo service hadoop-0.20-mapreduce-jobtrackerha stop 
#sudo service hadoop-0.20-mapreduce-jobtracker stop 
#sudo service hadoop-0.20-mapreduce-tasktracker stop
sudo service hadoop-mapreduce-historyserver stop
sudo service hadoop-yarn-resourcemanager stop
sudo service hadoop-yarn-nodemanager stop
sudo service hadoop-hdfs-namenode stop
sudo service hadoop-hdfs-datanode stop 
sudo service zookeeper-server stop
