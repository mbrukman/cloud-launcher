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

# Stop the current instance before making any changes.
rabbitmqctl stop_app

# Find other servers in the group via metadata and join them.
declare -r RABBITMQ_SERVERS="$(read_metadata 'rabbitmq-servers')"
declare -r RABBITMQ_USER="rabbit"

for server in ${RABBITMQ_SERVERS}; do
  rabbitmqctl join_cluster "${RABBITMQ_FLAGS}" "${RABBITMQ_USER}@${server}"
done

# Apply changes and display current status.
rabbitmqctl start_app
rabbitmqctl cluster_status
