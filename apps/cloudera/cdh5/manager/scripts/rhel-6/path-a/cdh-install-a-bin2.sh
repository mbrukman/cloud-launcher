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
# Install Cloudera CDH via single all-inclusive binary installer.
#
################################################################################

rpm --import "http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera"

# If you like living on the edge, you can automatically get the latest version:
# http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin"
declare -r CDH_REMOTE_BIN="http://archive.cloudera.com/cm5/installer/5.3.0/cloudera-manager-installer.bin"
declare -r CDH_LOCAL_BIN="/tmp/$(basename ${CDH_REMOTE_BIN})"

curl -s "${CDH_REMOTE_BIN}" -o "${CDH_LOCAL_BIN}"
${CDH_LOCAL_BIN} \
  --i-agree-to-all-licenses \
  --noprompt \
  --noreadme \
  --nooptions
rm -f "${CDH_LOCAL_BIN}"

# Install compression (optional).
yum -q -y install hadoop-lzo
