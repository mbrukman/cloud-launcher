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
# Install Coopr.
#
################################################################################

declare -r REPO_REMOTE="http://repository.cask.co/downloads/ubuntu/precise/amd64/cask.list"
declare -r REPO_LOCAL="/etc/apt/sources.list.d/cask.list"

if ! [ -e "${REPO_LOCAL}" ]; then
  curl -o "${REPO_LOCAL}" -s "${REPO_REMOTE}"
  curl -s "http://repository.cask.co/ubuntu/precise/amd64/releases/pubkey.gpg" \
    | apt-key add -
fi

apt-get -q -y update

if ! [ -d "/opt/coopr" ]; then
  apt-get install -q -y coopr-{server,provisioner,ui}
fi

if ! [ -e "/usr/bin/java" ]; then
  apt-get install -q -y openjdk-7-jre
fi
