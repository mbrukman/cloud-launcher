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
# Adds the Cloudera CDH repos for easy package discovery and installation.
#
################################################################################

add_cdh_repo \
  http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/cloudera-manager.repo \
  /etc/yum.repos.d/cloudera-manager.repo

add_cdh_repo \
  http://archive.cloudera.com/gplextras5/redhat/6/x86_64/gplextras/cloudera-gplextras5.repo \
   /etc/yum.repos.d/cloudera-gplextras5.repo

yum makecache
