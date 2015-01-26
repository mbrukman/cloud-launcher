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
# Disable IPv4 and IPv6 firewall via iptables to enable all hosts in the cluster
# to communicate with each other over all ports.
#
# The cluster is still protected from the outside by the GCE firewall, which
# only allows SSH access on port 22 by default.
#
################################################################################

# IPv4
service iptables save
service iptables stop
chkconfig iptables off

# IPv6
service ip6tables save
service ip6tables stop
chkconfig ip6tables off
