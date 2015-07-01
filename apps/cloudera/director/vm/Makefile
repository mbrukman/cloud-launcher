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
# Simplifies creating and destroying VMs with Cloudera Director pre-installed.
#
# Also simplifies creating secure connections to the VM by using either
# port-forwarding or a SOCKS proxy, as well as starting a browser with the
# right flags to use the SOCKS proxy.
#
################################################################################

# User-configurable values.
OS = centos6

# Note: this name must be the same as the VM that is deployed via the Python
# scripts; they are currently not automatically propagated or synchronized.
VM = cloudera-director

# Variables for port forwarding.

# The local port to listen on for forwarding only; does not apply to SOCKS proxy.
LOCAL_PORT = 7189

# The port Cloudera Director runs on.
CLOUDERA_DIRECTOR_PORT = 7189

# The local port to listen on for SOCKS proxy; does not apply to port forwarding.
SOCKS_PORT = 9000

# Derived values; do not modify.
CONFIG.centos6 = centos6.py
CONFIG.rhel6 = rhel6.py
CONFIG = $(CONFIG.$(OS))

ifndef CONFIG
$(error OS must be set to either 'centos6' or 'rhel6')
endif

VERB = @
ifeq ($(VERBOSE),1)
	VERB :=
endif

CLOUD_LAUNCHER = ../../../../src/cloud_launcher.sh

define USAGE
Valid variables
  OS           - base OS image to use; either 'centos6' or 'rhel6'

Valid commands:
  vm-insert    - creates a VM with a given OS image
  vm-delete    - deletes the created VM
  port-fwd     - create port-forwarding on 7189 to the VM over SSH
  socks-proxy  - create a SOCKS proxy to the VM over SSH
endef

export USAGE

default:
	$(VERB) echo "$${USAGE}"

update-scripts:
	$(VERB) $(MAKE) -s -C ../scripts/centos-6
	$(VERB) $(MAKE) -s -C ../scripts/rhel-6

vm-create: update-scripts
	$(VERB) $(CLOUD_LAUNCHER) --config="$(CONFIG)" insert

vm-delete:
	$(VERB) $(CLOUD_LAUNCHER) --config="$(CONFIG)" delete

port-fwd:
	$(VERB) env VM=$(VM) LOCAL_PORT=$(LOCAL_PORT) \
				REMOTE_PORT=$(CLOUDERA_DIRECTOR_PORT) ./port-forward.sh

socks-proxy:
	$(VERB) env VM=$(VM) REMOTE_PORT=$(CLOUDERA_DIRECTOR_PORT) \
				SOCKS_PORT=$(SOCKS_PORT) ./socks-proxy.sh

chrome-with-proxy:
	$(VERB) env REMOTE_PORT=$(CLOUDERA_DIRECTOR_PORT) SOCKS_PORT=$(SOCKS_PORT) \
				./chrome-with-proxy.sh
