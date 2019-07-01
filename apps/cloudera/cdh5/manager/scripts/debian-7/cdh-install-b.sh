#!/bin/bash

curl -s http://archive.cloudera.com/cdh5/debian/wheezy/amd64/cdh/archive.key \
  | sudo apt-key add -

apt-get update

# Install Cloudera Manager Server and Agent.
apt-get -q -y install cloudera-manager-{daemons,server,agent}

# Install Cloudera CDH components.
apt-get -q -y install \
  avro-tools crunch flume-ng hadoop-hdfs-fuse hadoop-hdfs-nfs3 hadoop-httpfs \
  hbase-solr hive-hbase hive-webhcat hue-beeswax hue-hbase hue-impala hue-pig \
  hue-plugins hue-rdbms hue-search hue-spark hue-sqoop hue-zookeeper impala \
  impala-shell kite llama mahout oozie pig pig-udf-datafu search sentry \
  solr-mapreduce spark-python sqoop sqoop2 whirr
