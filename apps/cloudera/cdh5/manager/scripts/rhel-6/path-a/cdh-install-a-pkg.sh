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
# Install Cloudera CDH via single package.
#
################################################################################

declare -r CDH_REMOTE_RPM="http://archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm"
declare -r CDH_LOCAL_RPM="/tmp/$(basename ${CDH_REMOTE_RPM})"

curl "${CDH_REMOTE_RPM}" -o "${CDH_LOCAL_RPM}"
yum -q -y install "${CDH_LOCAL_RPM}"
rm -f "${CDH_LOCAL_RPM}"
