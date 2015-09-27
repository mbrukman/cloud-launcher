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
# Creates a port-forwarding SSH connection.
#
################################################################################

source "$(dirname $0)/../../../../src/settings.sh"

declare -r VM="${VM:-cloudera-director}"
declare -ri LOCAL_PORT="${LOCAL_PORT:-7189}"
declare -ri REMOTE_PORT="${REMOTE_PORT:-7189}"

gcloud compute ssh ${VM} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --ssh-flag="-L ${LOCAL_PORT}:localhost:${REMOTE_PORT}"
