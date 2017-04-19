A = LOAD 'hdfs://bigtop1.vagrant:8020/user/pig/information.txt' using PigStorage ('\t') as (FName: chararray, LName: chararray, MobileNo: int);
B = FOREACH A generate FName, LName, MobileNo;
DUMP B;
