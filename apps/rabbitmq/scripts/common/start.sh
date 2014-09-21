#!/bin/bash -u
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

# Args:
#   $1: name of metadata key to retrieve
#
# Returns:
#   The value of the metadata key.
function read_metadata() {
  local key="$1"
  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${key}"
}

# Find out role of this server via metadata and set the right flag(s).
declare -r RABBITMQ_ROLE="$(read_metadata 'rabbitmq-role')"
RABBITMQ_FLAGS=""
case "${RABBITMQ_ROLE}" in
  ram)
    RABBITMQ_FLAGS="--ram"
    ;;

  disc|disk)
    RABBITMQ_FLAGS=""
    ;;

  *)
    echo "Unrecognized RabbitMQ role: ${RABBITMQ_ROLE}"
    ;;
esac

# Enable the HTTP-based API and web UI for administration.
rabbitmq-plugins enable rabbitmq_management

# Find other servers in the group via metadata and join them.
declare -r RABBITMQ_SERVER="$(read_metadata 'rabbitmq-server')"
declare -r RABBITMQ_USER="rabbit"

if [ "$(hostname -s)" != "${RABBITMQ_SERVER}" ] &&
   [ "$(hostname -f)" != "${RABBITMQ_SERVER}" ]; then
  # Stop the server before making any changes.
  rabbitmqctl stop_app

  while ! rabbitmqctl join_cluster "${RABBITMQ_FLAGS}" "${RABBITMQ_USER}@${RABBITMQ_SERVER}" ; do
    echo "Unable to join cluster; will try again in a few seconds." >&2
    sleep 7
  done

  # Apply changes made above and start the server.
  rabbitmqctl start_app
fi

rabbitmqctl cluster_status
