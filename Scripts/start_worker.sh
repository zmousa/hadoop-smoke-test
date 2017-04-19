#!/bin/bash

sudo service zookeeper-server start
sudo service  hadoop-hdfs-datanode start
sudo service hadoop-yarn-nodemanager start
sudo service hbase-regionserver start
sudo service spark-worker start
sudo service flume-agent start
