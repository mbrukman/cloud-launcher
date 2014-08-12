#!/bin/bash -eu
#
# Copyright 2014 Google Inc.
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
# Add the Hortonworks repository to download Ambari.
#
################################################################################

# TODO: make this an HTTPS URL (public-repo-1.hortonworks.com has an invalid SSL
# cert that identifies itself as a different host, likely due to hosting
# provider setup)
declare -r AMBARI_REPO="/etc/yum.repos.d/ambari.repo"
if ! [ -e "${AMBARI_REPO}" ]; then
  wget -O  "${AMBARI_REPO}" \
    http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.5.1/ambari.repo
fi

# Ensure that we have appropriate repositories set up.
# yum repolist | egrep -i '(ambari|hdp|hortonworks)'
