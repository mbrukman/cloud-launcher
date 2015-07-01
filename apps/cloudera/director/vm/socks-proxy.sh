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
# Creates a SOCKS proxy.
#
################################################################################

source "$(dirname $0)/../../../../src/settings.sh"

declare -r VM="${VM:-cloudera-director}"
declare -ri SOCKS_PORT="${SOCKS_PORT:-9000}"

gcloud compute ssh ${VM} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --ssh-flag="-D ${SOCKS_PORT}" \
    --ssh-flag="-N"
