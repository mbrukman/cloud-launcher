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
# Configure the Ambari Agent by editing its config file to connect it to the
# Ambari Server.
#
################################################################################

declare -r AMBARI_AGENT_INI="/etc/ambari-agent/conf/ambari-agent.ini"

# First, try to see if the metadata key "ambari-server-fqdn" is available.
# If it is, use it. Otherwise, fall back to "ambari-server" key and construct
# the FQDN by using the known pattern.
AMBARI_SERVER_FQDN="$(curl -f "http://metadata/computeMetadata/v1/instance/attributes/ambari-server-fqdn" -H "X-Google-Metadata-Request: True" 2> /dev/null)"
if [[ $? -ne 0 ]]; then
  echo "Metadata key ambari-server-fqdn not defined; using fallback 'ambari-server'"
  declare -r AMBARI_SERVER="$(curl -f "http://metadata/computeMetadata/v1/instance/attributes/ambari-server" -H "X-Google-Metadata-Request: True" 2> /dev/null)"
  if [[ $? -ne 0 ]]; then
    echo "Error retrieving Ambari server hostname."
    AMBARI_SERVER_FQDN="error"
  else
    AMBARI_SERVER_FQDN="${AMBARI_SERVER}.$(hostname -d)"
  fi
fi
export AMBARI_SERVER_FQDN="${AMBARI_SERVER_FQDN}"

echo "Ambari server: ${AMBARI_SERVER_FQDN}"
sed -i "s|^hostname=localhost$|hostname=${AMBARI_SERVER_FQDN}|" \
  "${AMBARI_AGENT_INI}"
unset AMBARI_SERVER_FQDN
