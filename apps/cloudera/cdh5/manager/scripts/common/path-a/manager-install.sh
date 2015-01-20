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
# Install Cloudera Manager via single all-inclusive binary installer.
#
################################################################################

# If you like living on the edge, you can automatically get the latest version:
# http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin"
declare -r CDH_REMOTE_BIN="http://archive.cloudera.com/cm5/installer/5.3.0/cloudera-manager-installer.bin"
declare -r CDH_LOCAL_BIN="/tmp/$(basename ${CDH_REMOTE_BIN})"

declare -r TERM_SESSION="cloudera-manager-installer"
declare -r CDH_INSTALLER_DONE_FILE="${HOME}/cloudera-manager-installer-done"

function running_os() {
  egrep -i "${1}" /etc/issue > /dev/null 2>&1
}

# Note: this functions assumes that the tool has the same binary name and
# package name on all distributions, which is not the case in all situations but
# works in the use case below for screen(1).
function install_tool() {
  local tool="${1}"
  if `which "${tool}" > /dev/null 2>&1` ; then
    return
  fi

  if running_os '(Debian|Ubuntu)' ; then
    apt-get install -q -y "${tool}"
  elif running_os '(RHEL|CentOS)' ; then
    yum install -q -y "${tool}"
  elif running_os '(SLES|OpenSuse)' ; then
    zypper -n install -q -y "${tool}"
  fi
}

# Install Cloudera Manager Server once the instance is running because it
# hard-codes the name of the machine into its configuration files.
if ! [ -e /etc/cloudera-scm-server ]; then
  echo "Downloading Cloudera Manager installer..."
  curl -s "${CDH_REMOTE_BIN}" -o "${CDH_LOCAL_BIN}"
  chmod a+x "${CDH_LOCAL_BIN}"

  echo "Installing Cloudera Manager in the background..."
  # We would use tmux(1) here, but `tmux` doesn't appear to be a standard
  # package at least on CentOS and as screen(1) is more wide-spread and we don't
  # need to use any tmux-specific features, we use `screen` below instead.
  #
  # The tmux(1) equivalent would be:
  #     tmux new-session -d -s "${TERM_SESION}" [...cmd...]
  install_tool screen
  # Note: we can use `screen -D -m` to make screen(1) wait for the process to
  # complete without having to write our own busy-loop below but then we won't
  # be able to see any progress markers since we're hiding the UI.
  screen -d -m -S "${TERM_SESSION}" bash -c \
      "${CDH_LOCAL_BIN} \
        --i-agree-to-all-licenses \
        --noprompt \
        --noreadme \
        --nooptions && \
        touch ${CDH_INSTALLER_DONE_FILE}"

  # Wait for the installer to finish running in the tmux session.
  while ! [ -e "${CDH_INSTALLER_DONE_FILE}" ]; do
    echo "$(date) - Cloudera Manager installer is running..."
    sleep 10
  done
  echo "$(date) - Cloudera Manager installer is done."

  # Cleanup the artifacts.
  rm -f "${CDH_INSTALLER_DONE_FILE}"
  rm -f "${CDH_LOCAL_BIN}"
else
  echo "Cloudera Manager Server is already installed; skipping." >&2
fi
