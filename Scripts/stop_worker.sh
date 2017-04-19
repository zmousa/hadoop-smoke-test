#!/bin/bash

sudo service flume-agent stop
sudo service spark-worker stop
sudo service hbase-regionserver stop
sudo service hadoop-yarn-nodemanager stop
sudo service  hadoop-hdfs-datanode stop
sudo service zookeeper-server stop
