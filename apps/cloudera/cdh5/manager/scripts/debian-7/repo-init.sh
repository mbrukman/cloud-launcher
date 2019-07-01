#!/bin/bash

add_cdh_repo \
  http://archive.cloudera.com/cm5/debian/wheezy/amd64/cm/cloudera.list \
  /etc/apt/sources.list.d/cloudera.list

apt-get -q update
