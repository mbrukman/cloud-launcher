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
# Set the hostname to the FQDN everywhere.
#
################################################################################

# Docs:
# * http://www.centos.org/docs/5/html/5.2/Deployment_Guide/s2-sysconfig-network.html
# * https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Deployment_Guide/ch-sysconfig.html#s2-sysconfig-network
# say:
#
#   "HOSTNAME=<value>, where <value> should be the Fully Qualified Domain Name
#   (FQDN), such as hostname.expample.com, but can be whatever hostname is
#   necessary."
declare -r SYSCONFIG_NETWORK="/etc/sysconfig/network"
sed -i "s/^HOSTNAME=.*$/HOSTNAME=$(hostname -f)/" "${SYSCONFIG_NETWORK}"

# Set the hostname to the FQDN.
if [[ "$(hostname)" != "$(hostname --fqdn)" ]]; then
  hostname "$(hostname --fqdn)"
fi
