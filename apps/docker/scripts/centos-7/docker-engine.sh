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

# This package is not supported by Docker, may hang on CentOS 7 on GCE.
#
# For more info, see:
# * https://github.com/docker/docker/issues/9696
# * https://github.com/docker/docker/pull/9918/files

declare -r DOCKER_REPO="/etc/yum.repos.d/docker.repo"
if ! [[ -e "${DOCKER_REPO}" ]]; then
  cat > "${DOCKER_REPO}" <<-EOF
[docker-repo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
fi

# Install Docker itself.
yum install -q -y docker-engine
