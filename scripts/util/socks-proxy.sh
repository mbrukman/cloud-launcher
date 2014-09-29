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
# Creates a SOCKS proxy to a GCE instance for easier access via a web browser.
#
################################################################################

declare -r SETTINGS="${SETTINGS:-$(dirname $0)/../../src/settings.sh}"

source "${SETTINGS}" || exit 1

declare SERVER="${SERVER:-ambari-server}"
declare -i PORT="${PORT:-9000}"

while [ $# -gt 0 ]; do
  case "$1" in
    --project)
      PROJECT="$2"
      shift
      ;;

    --project=*)
      SERVER="${1#--project=}"
      ;;

    --port|-p)
      PORT="$2"
      shift
      ;;

    --server)
      SERVER="$2"
      shift
      ;;

    --server=*)
      SERVER="${1#--server=}"
      ;;

    --zone)
      ZONE="$2"
      shift
      ;;

    --zone=*)
      ZONE="${1#--zone=}"
      ;;

    --)
      shift
      break
      ;;
  esac
  shift
done

echo "Running SOCKS proxy on localhost:${PORT}"
echo "Proxy server: ${SERVER} (project=${PROJECT}, zone=${ZONE})"

gcloud compute ssh \
  --project="${PROJECT}" \
  --zone="${ZONE}" \
  --ssh-flag="-D" \
  --ssh-flag="${PORT}" \
  --ssh-flag="-N" \
  "${SERVER}"
