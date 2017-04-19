#!/bin/bash

# Start HDFS
sudo -u hdfs /usr/lib/hadoop/sbin/hadoop-daemon.sh start datanode

# Start YARN
sudo -u yarn /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh start nodemanager

