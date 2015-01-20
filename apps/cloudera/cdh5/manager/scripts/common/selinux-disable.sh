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
# Disables SELinux as it conflicts with Cloudera Manager (installer exits).
#
# Docs:
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Security-Enhanced_Linux/sect-Security-Enhanced_Linux-Enabling_and_Disabling_SELinux-Disabling_SELinux.html
#
################################################################################

declare -r SELINUX_CONFIG="/etc/selinux/config"

if [ -e "${SELINUX_CONFIG}" ]; then
  if ! `grep ^SELINUX=disabled\$ "${SELINUX_CONFIG}" > /dev/null 2>&1`; then
    echo "Disabling SELinux..."
    sed -i 's/^SELINUX=.*$/SELINUX=disabled/' "${SELINUX_CONFIG}"

    # See the section "Handling Reboots" on
    # https://www.packer.io/docs/provisioners/shell.html
    echo "Rebooting..."
    reboot
    sleep 60
  fi
fi
