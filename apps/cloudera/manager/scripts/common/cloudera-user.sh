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
# Create a user for Cloudera Manager to be able to SSH and become this user.
#
# This user needs to either have:
# * a known password, OR
# * public-key authentication (requires private key uploaded to web UI)
#
# AND
#
# * password-less sudo access
#
################################################################################

# TODO(mbrukman): consider using public-key authentication instead?
#
# The issue is that Cloudera Manager requires the key to be re-uploaded to the
# web UI rather than accepting that /home/$USER/.ssh might already have both the
# public and private key on every host, thus simplifying the workflow.

declare -r CLOUDERA_USER="cloudera"
declare -r CLOUDERA_PASSWD="cloudera"

if ! `grep "${CLOUDERA_USER}" /etc/passwd > /dev/null 2>&1`; then
  echo "Adding user: ${CLOUDERA_USER}..."
  adduser "${CLOUDERA_USER}"
  echo "${CLOUDERA_USER}:${CLOUDERA_PASSWD}" | chpasswd
else
  echo "User ${CLOUDERA_USER} already exists; skipping."
fi

# Enable password-less sudo
declare -r SUDOERS="/etc/sudoers"
declare -r CLOUDERA_SUDO="${CLOUDERA_USER} ALL=(ALL) NOPASSWD: ALL"

if ! `egrep "^${CLOUDERA_SUDO}\$" "${SUDOERS}" > /dev/null 2>&1`; then
  echo "Enabling sudo access for user ${CLOUDERA_USER}..."
  echo >> "${SUDOERS}"
  echo "# Added for automatic use by Cloudera Manager" >> "${SUDOERS}"
  echo "${CLOUDERA_SUDO}" >> "${SUDOERS}"
  echo >> "${SUDOERS}"
else
  echo "User ${CLOUDERA_USER} already has sudo access; skipping."
fi

# Make sure this user can only login via SSH from the private network as we are
# otherwise exposing a known user/password account with sudo access directly to
# the outside world.
declare -r SSHD_CONFIG="/etc/ssh/sshd_config"

if ! `egrep "^Match User ${CLODUERA_USER}" "${SSHD_CONFIG}" > /dev/null 2>&1`; then
  echo "Adding limited SSH access for user ${CLOUDERA_USER}..."
  cat <<EOF >> "${SSHD_CONFIG}"
# Only allow the Cloudera user to connect with password via the private network.
Match User ${CLOUDERA_USER} Address 10.*
  PasswordAuthentication yes
EOF
else
  echo "User ${CLOUDERA_USER} already has limited ssh access; skipping."
fi
