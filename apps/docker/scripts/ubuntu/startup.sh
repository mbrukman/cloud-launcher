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
# Installs Docker. For more info, see https://get.docker.com/
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
  echo "deb https://apt.dockerproject.org/repo ubuntu-${UBUNTU_RELEASE} main" > "${DOCKER_REPO_LIST}"
  apt-get -q update
fi

if ! which docker > /dev/null 2>&1 ; then
  echo "Adding GPG key..."
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
      --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  apt-get update
  echo "Done adding GPG key."

  echo "Installing Docker..."
  apt-get install -y docker-engine
  echo "Done installing Docker."
fi

# Start the Docker service immediately.
service docker start
