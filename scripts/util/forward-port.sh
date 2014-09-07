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
# Forwards a port from the local host to a remote host via `gcutil'.

declare -r SETTINGS="${SETTINGS:-settings.sh}"

source "${SETTINGS}" || exit 1

declare -r SERVER="${SERVER:-ambari-server-0}"
declare -i -r REMOTE_PORT="${REMOTE_PORT:-8080}"
declare -i -r LOCAL_PORT="${LOCAL_PORT:-8080}"

gcloud compute ssh \
  --project="${PROJECT}" \
  --zone="${ZONE}" \
  --ssh-flag="-L" \
  --ssh-flag="${LOCAL_PORT}:${SERVER}:${REMOTE_PORT}" \
  "${SERVER}"
