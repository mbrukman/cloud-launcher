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

echo "Adding user: ${CLOUDERA_USER}..."
adduser "${CLOUDERA_USER}"
echo "${CLOUDERA_USER}:${CLOUDERA_PASSWD}" | chpasswd

# Enable password-less sudo
echo "Enabling sudo access for ${CLOUDERA_USER}..."
declare -r SUDOERS="/etc/sudoers"
echo >> "${SUDOERS}"
echo "# Added for automatic use by Cloudera Manager" >> "${SUDOERS}"
echo "${CLOUDERA_USER} ALL=(ALL) NOPASSWD: ALL" >> "${SUDOERS}"
echo >> "${SUDOERS}"
