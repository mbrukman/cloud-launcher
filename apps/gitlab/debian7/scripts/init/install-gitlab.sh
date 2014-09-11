#!/bin/bash -u
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

declare -r GITLAB_DEB_URL="https://downloads-packages.s3.amazonaws.com/debian-7.6/gitlab_7.2.1-omnibus-1_amd64.deb"
declare -r GITLAB_DEB="$(basename "${GITLAB_DEB_URL}")"

if ! which curl > /dev/null 2>&1 ; then
  apt-get -q -y install curl
fi

curl -O "${GITLAB_DEB_URL}"
dpkg -i "${GITLAB_DEB}"

# Note: edit this to set the server URL.
cat > /etc/gitlab/gitlab.rb <<EOF
external_url 'http://gitlab.example.com'
EOF

gitlab-ctl reconfigure
