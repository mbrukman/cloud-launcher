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
# Installs Cloudera Director and dependencies.
#
################################################################################

declare -r INSTALL_DIR="/opt/cloudera-director"

if [[ ! -d "${INSTALL_DIR}" ]]; then
  mkdir -p "${INSTALL_DIR}"
fi
cd "${INSTALL_DIR}"

# Oracle JDK is a prerequisite for Cloudera Director.
declare -r INSTALLED_JAVA="${INSTALL_DIR}/installed_java"
if [[ ! -f "${INSTALLED_JAVA}" ]]; then
  echo "Downloading Oracle JDK..."
  curl -s -b oraclelicense=accept-securebackup-cookie -O \
      -L http://download.oracle.com/otn-pub/java/jdk/8u11-b12/jre-8u11-linux-x64.rpm
  echo "Installing Oracle JDK..."
  yum -q -y install jre-8u11-linux-x64.rpm
  touch "${INSTALLED_JAVA}"
  echo "Oracle JDK is installed."
fi

# Add the Cloudera Director YUM repo.
declare -r DIRECTOR_REPO_URL="http://archive.cloudera.com/director/redhat/6/x86_64/director/cloudera-director.repo"
declare -r DIRECTOR_REPO_PATH="/etc/yum.repos.d/cloudera-director.repo"
if [[ ! -f "${DIRECTOR_REPO_PATH}" ]]; then
  echo "Adding Cloudera yum repository..."
  wget "${DIRECTOR_REPO_URL}" -O "${DIRECTOR_REPO_PATH}"
  echo "Updating the yum metadata..."
  yum makecache
  echo "Added Cloudera yum repository."
fi

# Install Cloudera Director.
declare -r INSTALLED_DIRECTOR="${INSTALL_DIR}/installed_cloudera_director"
if [[ ! -f "${INSTALLED_DIRECTOR}" ]]; then
  echo "Installing Cloudera Director server..."
  yum -q -y install cloudera-director-server
  touch "${INSTALLED_DIRECTOR}"
  echo "Cloudera Director server installed."
fi

echo "Starting Cloudera Director server..."
service cloudera-director-server start

echo "Stopping iptables..."
service iptables stop

echo "Waiting for Cloudera Director to start up..."

# netcat is not available by default, so we'll use curl to test the port.
while ! curl localhost:7189 >& /dev/null; do
  sleep 1
done

echo "Cloudera Director is now ready."
