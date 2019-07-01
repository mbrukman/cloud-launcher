#!/bin/bash

# Cloudera Manager Server fails to start with an exception about loading the
# MySQL JDBC driver if this is not installed.
yum -q -y install mysql-connector-java

