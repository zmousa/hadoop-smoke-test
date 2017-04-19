Hadoop Cluster Smoke Tests
==========================
Smoke tests applied on BigTop Hadoop cluster, in order to check the status of cluster services.

**Table of Contents**
+ Spark Test
+ HDFS Test
+ MapReduce Test
+ Hive Test
+ Oozie Test
+ Sqoop Test
+ Pig Test
+ Flume Test
+ Kafka Test

------------

## Spark Test
The test based on running the Spark default example related to “Pi Job”, by selecting the yarn as a master and set the number of executors based on our cluster
**Result:** by checking the output job result as succeeded or not.
```bash
   sudo -Hu hdfs spark-submit --master yarn-cluster --class org.apache.spark.examples.SparkPi --num-executors 2 --driver-cores 1 --driver-memory 512m --executor-memory 512m --executor-cores 2 --queue default /usr/lib/spark/lib/spark-examples.jar 10 
```

## HDFS Test
Simple test of writing and removing file on HDFS
**Result:** if no errors occurred then test passed.
```bash
   sudo -Hu hdfs hdfs dfs -touchz /hdfs_test
   sudo -Hu hdfs hdfs dfs -rm /hdfs_test
```

## MapReduce Test
The test based on running the Hadoop default example related to “Pi MapReduce Job”, and setting the number of mappers and reduceres.
**Result:** by checking the output job result as succeeded or not.
```bash
   sudo -Hu hdfs hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 2 2
```

## Hive Test
The test based on creating and dropping table on Hive.
**Result:** if no errors occurred then test passed.
```bash
   sudo -Hu hdfs beeline -u jdbc:hive2://localhost:10000 -nhdfs -p password -d org.apache.hive.jdbc.HiveDriver -e 'create table test_table ( id int )  location "/tmp/test_table"; drop table test_table;'
```


## Oozie Test
The test based on running the Oozie default example related to a workflow contains a MapReduce job.
**Result:** Printing job-id refers to service running, but the result of the job could be tracked on the Oozie web browser.
```bash
   sudo -Hi -u hdfs oozie job -oozie http://bigtop1.vagrant:11000/oozie -config /tmp/examples/apps/map-reduce/job.properties -run
```

## Sqoop Test
Test starts by creating table with data on RDBMS Mysql database and then run Sqoop import into hdfs.
**Result:** asserting that imported number of rows equals to the initially created rows on RDBMS table.
```bash
   sudo -u hdfs sqoop import --connect jdbc:mysql://10.10.10.11:3306/sqoop_test --username root --password **** --table test_table --target-dir /tmp_sqoop/
```

## Pig Test
Test starts with importing some data file into HDFS, and pig script will read the data, generate new set of rows and then dumb the data.
**Result:** by checking the number of rows on the job output log equals to the default number of rows.
```bash
   sudo pig /tmp/BigTopTest/Files/output.pig > /tmp/pigJobLog
```

## Flume Test
Test starts by running the Flume agent on a specific port with configuration file regarding the channel, sink and source.
Then telnet the same port and send some data.
**Result:** by asserting that flume received data rows are equal to the number sent from telnet.
```bash
   # Run Flume agent, on port 44444
   sudo -u hdfs flume-ng agent -f /tmp/BigTopTest/Files/flume-agent.conf -n shaman &

   # Telnet 44444 port and send some messages
   { echo "abc"; echo "def"; sleep 1; } | telnet localhost 44444
```

## Kafka Test
Test starts by creating a new topic (if not exists), and then run kafka consumer of that topic and check number of received messages (from the beginning of the topic queue).
Then we run a kafka producer and send a message for the same topic channel, after that we run a new consumer ans do the same old checking for messages.
**Result:** we assert that the number of consumed messages after the producer are more than the first consumed messages with one message.
```bash
   # Run Consumer 1 and log messages
   sudo /usr/lib/kafka/bin/kafka-simple-consumer-shell.sh --broker-list localhost:9092 --topic Hello-Kafka --partition 0 > /tmp/kafkaLog1 &

   # Run Producer and send one message
   echo "message" | /usr/lib/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic Hello-Kafka

   # Run Consumer 2 and log messages
   sudo /usr/lib/kafka/bin/kafka-simple-consumer-shell.sh --broker-list localhost:9092 --topic Hello-Kafka --partition 0 > /tmp/kafkaLog2 &
```

