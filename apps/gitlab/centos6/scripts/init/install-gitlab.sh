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

declare -r GITLAB_RPM_URL="https://downloads-packages.s3.amazonaws.com/centos-6.5/gitlab-7.2.1_omnibus-1.el6.x86_64.rpm"
declare -r GITLAB_RPM="$(basename "${GITLAB_RPM_URL}")"

if ! which curl > /dev/null 2>&1 ; then
  yum -q -y install curl
fi

curl -O "${GITLAB_RPM_URL}"
rpm -i "${GITLAB_RPM}"

# Note: edit this to set the server URL.
cat > /etc/gitlab/gitlab.rb <<EOF
external_url 'http://gitlab.example.com'
EOF

gitlab-ctl reconfigure
lokkit -s http -s ssh
