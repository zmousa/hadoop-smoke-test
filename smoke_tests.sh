#!/bin/bash

echo
echo "############################## Spark Test ###############################"
echo

# Run Spark Job on Yarn
sudo -Hu hdfs spark-submit --master yarn-cluster --class org.apache.spark.examples.SparkPi --num-executors 2 --driver-cores 1 --driver-memory 512m --executor-memory 512m --executor-cores 2 --queue default /usr/lib/spark/lib/spark-examples.jar 10

echo
echo "############################### HDFS Test ###############################"
echo

# Create/Remove file on HDFS
sudo -Hu hdfs hdfs dfs -touchz /hdfs_test
sudo -Hu hdfs hdfs dfs -rm /hdfs_test
 
echo
echo "############################ Map Reduce Test ############################"
echo

# Run hadoop MapReduce PI job
sudo -Hu hdfs hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 1 1

echo
echo "############################# Hive Test #################################"
echo

# Create/Drop table on hive
sudo -Hu hdfs beeline -u jdbc:hive2://localhost:10000 -nhdfs -p password -d org.apache.hive.jdbc.HiveDriver -e 'create table test_table ( id int )  location "/tmp/test_table"; drop table test_table;'

echo
echo "############################# Oozie Test ################################"
echo

# Look for oozie examples
oozieExample="$(rpm -ql oozie-client | grep oozie-examples)"
echo $oozieExample
cp $oozieExample /tmp
cd /tmp
ls *.tar.* | xargs -r tar -xvzf > /dev/null 2>&1

# Put examples in HDFS
sudo -Hiu hdfs hdfs dfs -put -f /tmp/examples examples

sed -i 's#^nameNode=.*#nameNode=hdfs://bigtop1.vagrant:8020#' /tmp/examples/apps/map-reduce/job.properties
sed -i 's#^jobTracker=.*#jobTracker=hdfs://bigtop1.vagrant:8032#' /tmp/examples/apps/map-reduce/job.properties

# Run oozie job
jobOutput="$(sudo -Hi -u hdfs oozie job -oozie http://bigtop1.vagrant:11000/oozie -config /tmp/examples/apps/map-reduce/job.properties -run)"
arrJob=($jobOutput)
jobNumber=${arrJob[1]}
echo "Job Number -" $jobNumber
sudo -Hiu hdfs oozie job -oozie http://localhost:11000/oozie -info $jobNumber | awk '/^Status/{ print $3 }'

echo
echo "############################ Sqoop Test #################################"
echo

# Connect to Mysql and Run sql script to create data
mysql -u root --password=Root@123 < /tmp/BigTopTest/Files/sqoop_test_myqsl.sql

# Sqoop import
sudo -u hdfs sqoop import --connect jdbc:mysql://10.10.10.11:3306/sqoop_test --username root --password Root@123 --table test_table --target-dir /tmp_sqoop/ 

# Check table rows number
tbl_cnt="$(mysql -u root --password=Root@123 -s -e 'select count(*) from test_table' sqoop_test| cut -f1)"

# Check sqoop imported data rows number
hdfs_tbl_cnt="$(sudo -u hdfs hdfs dfs -cat /tmp_sqoop/* | wc -l)"

# Assert imported row number
if [ $tbl_cnt == $hdfs_tbl_cnt ]
then
   echo "Sqoop Job Succeeded"
else
   echo "Sqoop Job Failed"
fi

sudo -u hdfs hdfs dfs -rm -r hdfs://bigtop1.vagrant:8020/tmp_sqoop

echo
echo "############################ Pig Test ####################################"
echo

# Create HDFS folder and move information to HDFS
sudo -u hdfs hdfs dfs -mkdir /user/pig
sudo chmod 777 -R /tmp/BigTopTest/Files/
sudo -u hdfs hdfs dfs -put /tmp/BigTopTest/Files/information.txt  /user/pig

# Run Pig script
sudo pig /tmp/BigTopTest/Files/output.pig > /tmp/pigJobLog

# Check log result
if [ $(cat /tmp/pigJobLog | wc -l) -eq 3 ]; then
  echo "Pig Job Succeeded"
else
  echo "Pig Job Failed"
fi

rm -rf /tmp/pigJobLog

echo
echo "############################# Flume Test #################################"
echo

sudo -u hdfs hdfs dfs -mkdir -p /tmp/flume_test

# Check if there is connection to the port 44444
SERVER=localhost
PORT=44444
</dev/tcp/$SERVER/$PORT
if [ "$?" -ne 0 ]; then
  echo "Connection to $SERVER on port $PORT failed"
  # Run Flume agent, on port 44444
  sudo -u hdfs flume-ng agent -f /tmp/BigTopTest/Files/flume-agent.conf -n shaman &
  pid=$!
else
  echo "Connection to $SERVER on port $PORT succeeded"
fi

{ sleep 5; }
# Telnet 44444 port and send some messages
{ echo "abc"; echo "def"; sleep 1; } | telnet localhost 44444

# Check Flume saved log
if [ $(sudo -u hdfs hdfs dfs -cat /tmp/flume_test/* | wc -l) -eq 2 ]; then
  echo "Flume Job Succeeded"
else
  echo "Flume Job Failed"
fi

#sudo -u hdfs hdfs dfs -rm -r hdfs://bigtop1.vagrant:8020/tmp/flume_test/*
#sudo kill -9 $pid

echo
echo "############################# Kafka Test #################################"
echo

if [ $(sudo /usr/lib/kafka/bin/kafka-topics.sh --list --zookeeper localhost:2181 | wc -l) -eq 0 ]; then
  sudo /usr/lib/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic Hello-Kafka
fi

# Run Consumer 1 and log messages
sudo /usr/lib/kafka/bin/kafka-simple-consumer-shell.sh --broker-list localhost:9092 --topic Hello-Kafka --partition 0 > /tmp/kafkaLog1 &
consumer1_pid=$!
echo $consumer1_pid
{ sleep 3; }
# Consumer 1, number of consumed messages
messages_count1="$(cat /tmp/kafkaLog1 | wc -l)"
sudo kill -9 $consumer1_pid

# Run Producer and send one message
echo "message" | /usr/lib/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic Hello-Kafka

# Run Consumer 2 and log messages
sudo /usr/lib/kafka/bin/kafka-simple-consumer-shell.sh --broker-list localhost:9092 --topic Hello-Kafka --partition 0 > /tmp/kafkaLog2 &
consumer2_pid=$!
echo $consumer2_pid
{ sleep 3; }
# Consumer 2, number of consumed messages
messages_count2="$(cat /tmp/kafkaLog2 | wc -l)"
sudo kill -9 $consumer2_pid

# Assert Consumer 2, read the produced message
if [ `expr $messages_count1 + 1` == $messages_count2 ]; then
  echo "kafka Test Succeeded"
else
  echo "kafka Test Failed"
fi

# Delete temp log files
sudo rm /tmp/kafkaLog1
sudo rm /tmp/kafkaLog2

