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
# Runs Google Chrome pointing at a SOCKS proxy on a given port.
#
################################################################################

source "$(dirname $0)/../../../../src/settings.sh"

declare -r VM="${VM:-cloudera-director}"
declare -ri REMOTE_PORT="${REMOTE_PORT:-7189}"
declare -ri SOCKS_PORT="${SOCKS_PORT:-9000}"
declare -r PROXY_PROFILE="${PROXY_PROFILE:-${HOME}/chrome-proxy-profile}"

declare -r CLOUDERA_DIRECTOR_URL="http://${VM}:${REMOTE_PORT}"

if ! [[ -e "${PROXY_PROFILE}" ]]; then
  mkdir -p "${PROXY_PROFILE}"
elif ! [[ -d "${PROXY_PROFILE}" ]]; then
  echo "Chrome proxy profile [${PROXY_PROFILE}] exists but is not a directory." >&2
  exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      --user-data-dir="${PROXY_PROFILE}" \
      --proxy-server="socks5://localhost:${SOCKS_PORT}" \
      "${CLOUDERA_DIRECTOR_URL}" >& /dev/null 2>&1 &
elif [[ "$(uname -s)" == "Linux" ]]; then
  /usr/bin/google-chrome \
      --user-data-dir="${PROXY_PROFILE}" \
      --proxy-server="socks5://localhost:${SOCKS_PORT}" \
      "${CLOUDERA_DIRECTOR_URL}" >& /dev/null 2>&1 &
fi
