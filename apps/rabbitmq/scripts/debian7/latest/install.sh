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

apt-get -q -y update

if ! `which curl > /dev/null 2>&1` ; then
  apt-get -q -y install curl
fi

if ! [ -e /usr/lib/apt/methods/https ]; then
  apt-get -q -y install apt-transport-https
fi

# Add the RabbitMQ APT repo to get newer packages.
cat <<EOF > /etc/apt/sources.list.d/rabbitmq.list
deb https://www.rabbitmq.com/debian/ testing main
EOF

# Add the RabbitMQ signing key.
declare -r RABBITMQ_KEY_URL="https://www.rabbitmq.com/rabbitmq-signing-key-public.asc"
declare -r RABBITMQ_KEY="/tmp/$(basename "${RABBITMQ_KEY_URL}")"
curl -s "${RABBITMQ_KEY_URL}" -o "${RABBITMQ_KEY}"
apt-key add "${RABBITMQ_KEY}"
rm "${RABBITMQ_KEY}"

# Install RabbitMQ.
apt-get -q -y update
apt-get -q -y install rabbitmq-server
