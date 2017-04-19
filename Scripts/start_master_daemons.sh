#!/bin/bash

# Start HDFS
sudo -u hdfs /usr/lib/hadoop/sbin/hadoop-daemon.sh start namenode
sudo -u hdfs /usr/lib/hadoop/sbin/hadoop-daemon.sh start datanode

# Start YARN
sudo -u yarn /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh start resourcemanager
sudo -u yarn /usr/lib/hadoop-yarn/sbin/yarn-daemon.sh start nodemanager

# Start HBase
sudo -u hbase /usr/lib/hbase/bin/hbase-daemon.sh start master
sleep 25
sudo -u hbase /usr/lib/hbase/bin/hbase-daemon.sh start regionserver

# Start the Hive Metastore
sudo -u hive nohup /usr/lib/hive/bin/hive --service metastore>/var/log/hive/hive.out 2>/var/log/hive/hive.log &
sudo -u hive nohup /usr/lib/hive/bin/hiveserver2 -hiveconf hive.metastore.uris=" " >>/tmp/hiveserver2HD.out 2>> /tmp/hiveserver2HD.log &

# Start Oozie
sudo -u oozie sudo /usr/lib/oozie/bin/oozie-sys.sh start


#$HADOOP_PREFIX/sbin/start-dfs.sh
#$HADOOP_PREFIX/sbin/start-yarn.sh





