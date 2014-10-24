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

# Args:
#   $1: key to look up in the instance metadata
#   $2: file to send error logs to
#
# Returns:
#   value on stdout, or empty on error
#   errors will be logged to file $2
function get_instance_metadata() {
  local key="$1"
  local stderr="$2"
  curl -f -s -S \
    "http://metadata/computeMetadata/v1/instance/attributes/${key}" \
    -H "X-Google-Metadata-Request: True" \
    2> "${stderr}"
}

# First, try to see if the metadata key "ambari-server-fqdn" is available.
# If it is, use it. Otherwise, fall back to "ambari-server" key and construct
# the FQDN by using the known pattern.
declare -r AMBARI_SERVER_METADATA_ERR="ambari-server-metadata.err"
AMBARI_SERVER_FQDN="$(get_instance_metadata 'ambari-server-fqdn' "${AMBARI_SERVER_METADATA_ERR}")"
if [ -z "${AMBARI_SERVER_FQDN}" ]; then
  echo "Could not retrieve metadata key ambari-server-fqdn (likely not defined):"
  cat "${AMBARI_SERVER_METADATA_ERR}"
  echo "Using fallback metadata key 'ambari-server' ..."
  declare -r AMBARI_SERVER="$(get_instance_metadata 'ambari-server' "${AMBARI_SERVER_METADATA_ERR}")"
  if [ -z "${AMBARI_SERVER}" ]; then
    echo "Error retrieving Ambari server hostname via 'ambari-server' metadata key:"
    cat "${AMBARI_SERVER_METADATA_ERR}"
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
