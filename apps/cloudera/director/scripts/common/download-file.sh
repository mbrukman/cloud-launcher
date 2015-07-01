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

# Args:
#   $1: remote URL
#   $2: local path
function download_file() {
  local remote_url="$1"
  local local_path="$2"
  if [ -e "${local_path}" ]; then
    return
  fi

  if `which curl > /dev/null 2>&1`; then
    curl "${remote_url}" -o "${local_path}"
  elif `which wget > /dev/null 2>&1`; then
    wget "${remote_url}" -O "${local_path}"
  else
    echo "ERROR: neither curl nor wget are available." >&2
    exit 1
  fi
}
