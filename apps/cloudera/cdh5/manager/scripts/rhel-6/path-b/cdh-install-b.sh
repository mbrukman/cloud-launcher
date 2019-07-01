#!/bin/bash -eu
#
# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
#
# Install Cloudera CDH via packages manually.
#
################################################################################

rpm --import "http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera"

# CDH 5.3.x (*) supports and is certified with Oracle JDK 1.7.0_67 and 1.8.0_11:
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_req_supported_versions.html
# (*) latest version at the time of this writing
yum -q -y install oracle-j2sdk1.7

# Install embedded PostgreSQL database for Cloudera Manager Server.
yum -q -y install cloudera-manager-server-db-2

# Install Cloudera Manager Server and Agent.
yum -q -y install cloudera-manager-{daemons,server,agent}

# Install Cloudera CDH components.
yum -q -y install \
  avro-tools crunch flume-ng hadoop-hdfs-fuse hadoop-hdfs-nfs3 hadoop-httpfs \
  hbase-solr hive-hbase hive-webhcat hue-beeswax hue-hbase hue-impala hue-pig \
  hue-plugins hue-rdbms hue-search hue-spark hue-sqoop hue-zookeeper impala \
  impala-shell kite llama mahout oozie pig pig-udf-datafu search sentry \
  solr-mapreduce spark-python sqoop sqoop2 whirr

# Install HDFS compression (optional).
yum -q -y install hadoop-lzo

yum -q -y clean packages
