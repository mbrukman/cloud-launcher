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
# Configure Cloudera Manager Agent.
#
################################################################################

declare -r MANAGER_AGENT_INI="/etc/cloudera-scm-agent/config.ini"

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

# Sets the given key to given value in ${MANAGER_AGENT_INI}.
#
# Args:
#   $1: key
#   $2: value
function set_agent_ini_key_value() {
  local key="$1"
  local value="$2"
  sed -i "s|^${key}=.*$|${key}=${value}|" "${MANAGER_AGENT_INI}"
}

declare -r MANAGER_SERVER_METADATA_ERR="manager-server-metadata.err"
MANAGER_SERVER_FQDN="$(get_instance_metadata 'scm-server-fqdn' "${MANAGER_SERVER_METADATA_ERR}")"
if [ -z "${MANAGER_SERVER_FQDN}" ]; then
  echo "Missing metadata key 'scm-server-fqdn'; using fallback key 'scm-server' ..."
  declare -r MANAGER_SERVER="$(get_instance_metadata 'scm-server' "${MANAGER_SERVER_METADATA_ERR}")"
  if [ -z "${MANAGER_SERVER}" ]; then
    echo "Error retrieving SCM server hostname via 'scm-server' metadata key:"
    cat "${MANAGER_SERVER_METADATA_ERR}"
    MANAGER_SERVER_FQDN="error"
  else
    MANAGER_SERVER_FQDN="${MANAGER_SERVER}.$(hostname -d)"
  fi
fi
set_agent_ini_key_value "server_host" "${MANAGER_SERVER_FQDN}"

declare MANAGER_SERVER_PORT=$(get_instance_metadata 'scm-server-port' /dev/null)
if [ -n "${MANAGER_SERVER_PORT}" ]; then
  set_agent_ini_key_value "server_port" "${MANAGER_SERVER_PORT}"
fi

echo "Final config file params:"
grep server_host "${MANAGER_AGENT_INI}"
grep server_port "${MANAGER_AGENT_INI}"
