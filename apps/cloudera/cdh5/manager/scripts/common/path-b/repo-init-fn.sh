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
# Add the Cloudera repository to download CDH components.
#
################################################################################

# Args:
#   $1: source URL
#   $2: destination file
function add_cdh_repo() {
  local url="$1"
  local dest="$2"

  if ! [ -e "${dest}" ]; then
    curl -o "${dest}" -s "${url}"
  fi
}
