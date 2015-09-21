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
# Installs Docker. For more info, see https://get.docker.com/ubuntu/
#
################################################################################

apt-get update

# Add HTTPS support to apt-get.
if ! [ -e /usr/lib/apt/methods/https ]; then
  echo "Installing HTTPS support for apt-get..."
  apt-get install -q -y apt-transport-https ca-certificates
  echo "Done installing HTTPS support for apt-get."
fi

declare -r DOCKER_REPO_LIST="/etc/apt/sources.list.d/docker.list"

if ! [ -d "$(dirname "${DOCKER_REPO_LIST}")" ]; then
  mkdir -p "$(dirname "${DOCKER_REPO_LIST}")"
fi

if ! [ -e "${DOCKER_REPO_LIST}" ]; then
  echo "deb https://get.docker.com/ubuntu docker main" > "${DOCKER_REPO_LIST}"
  apt-get -q update
fi

if ! which docker > /dev/null 2>&1 ; then
  echo "Adding GPG key..."
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
      --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
  apt-get update
  echo "Done adding GPG key."

  echo "Installing Docker..."
  apt-get install -y lxc-docker
  echo "Done installing Docker."
fi

# Automatically start Docker on boot.
update-rc.d docker defaults
