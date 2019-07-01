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
# Builds the Cloudera CDH Manager agent and server init scripts.
#
# Note: each OS distribution must provide the following scripts:
#
# * repo-init.sh (may use function in repo-init-fn.sh)
# * agent-install.sh
# * server-install.sh
#
################################################################################

ifeq ($(ENABLE_FDISK),1)
	FDISK = ../../../../../common/fdisk.sh
else
	FDISK =
endif

REPO_INIT_FN = $(COMMON)/repo-init-fn.sh

# These are typically expected to be in the same directory as the including
# script, but are exposed here to enable overriddes.
REPO_INIT = repo-init.sh
AGENT_INSTALL = agent-install.sh
SERVER_INSTALL = server-install.sh

CDH_INSTALL.a-bin = cdh-install-a-bin.sh
CDH_INSTALL.a-pkg = cdh-install-a-pkg.sh
CDH_INSTALL.b = cdh-install-b.sh
CDH_INSTALL_METHOD = b
CDH_INSTALL = $(CDH_INSTALL.$(CDH_INSTALL_METHOD))
ifeq ($(CDH_INSTALL),)
	$(error CDH_INSTALL_METHOD undefined or invalid, valid values: 'a-bin', 'a-pkg', 'b')
endif

AGENT_INPUTS = \
  $(FDISK) \
  $(REPO_INIT_FN) \
  $(REPO_INIT) \
  $(AGENT_INSTALL) \
  $(COMMON)/agent-setup.sh \
  $(COMMON)/agent-start.sh
AGENT_INIT = agent-init.gen.sh

SERVER_INPUTS = \
  $(FDISK) \
  $(REPO_INIT_FN) \
  $(REPO_INIT) \
  $(SERVER_INSTALL) \
  $(COMMON)/server-start.sh
SERVER_INIT = server-init.gen.sh

PACKER_BUILD_INPUTS = \
  $(REPO_INIT_FN) \
  $(REPO_INIT) \
  $(CDH_INSTALL) \
  $(AGENT_INSTALL) \
  $(COMMON)/agent-stop.sh \
  $(SERVER_INSTALL) \
  $(COMMON)/server-stop.sh
PACKER_BUILD = packer-build.gen.sh

PACKER_AGENT_INIT_INPUTS = \
  $(FDISK) \
  $(COMMON)/agent-setup.sh \
  $(COMMON)/agent-start.sh
PACKER_AGENT_INIT = packer-agent-init.gen.sh

PACKER_SERVER_INIT_INPUTS = \
  $(FDISK) \
  $(COMMON)/server-start.sh
PACKER_SERVER_INIT = packer-server-init.gen.sh

PACKER_SERVER_AGENT_INIT_INPUTS = \
  $(FDISK) \
  $(COMMON)/server-start.sh \
  $(COMMON)/agent-setup.sh \
  $(COMMON)/agent-start.sh \
PACKER_SERVER_AGENT_INIT = packer-server-init.gen.sh

MAKEFILE_DEPS = \
  Makefile \
  $(COMMON)/common.mk

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

DEBUG = @ true
ifeq ($(DEBUGGING),1)
	DEBUG = @
endif

.PHONY default:
	$(VERB) echo "Available targets:"
	$(VERB) echo " [raw]:    build startup scripts for raw images"
	$(VERB) echo " [custom]: build startup scripts for custom-built (Packer) images"

raw: $(AGENT_INIT) $(SERVER_INIT)

custom: $(PACKER_BUILD) $(PACKER_AGENT_INIT) $(PACKER_SERVER_INIT) $(PACKER_SERVER_AGENT_INIT)

clean:
	$(VERB) rm -f $(AGENT_INIT) $(SERVER_INIT)
	$(VERB) rm -f $(PACKER_BUILD)
	$(VERB) rm -f $(PACKER_AGENT_INIT) $(PACKER_SERVER_INIT)

$(AGENT_INIT): $(AGENT_INPUTS) $(MAKEFILE_DEPS)
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Agent input scripts: $(AGENT_INPUTS)"
	$(VERB) cat $(AGENT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Agent output script:"
	$(DEBUG) cat $@

$(SERVER_INIT): $(SERVER_INPUTS) $(MAKEFILE_DEPS)
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Server input scripts: $(SERVER_INPUTS)"
	$(VERB) cat $(SERVER_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Server output script:"
	$(DEBUG) cat $@

$(PACKER_BUILD): $(PACKER_BUILD_INPUTS) $(MAKEFILE_DEPS)
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Packer build input scripts: $(PACKER_BUILD_INPUTS)"
	$(VERB) cat $(PACKER_BUILD_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Packer build output script:"
	$(DEBUG) cat $@

$(PACKER_AGENT_INIT): $(PACKER_AGENT_INIT_INPUTS) $(MAKEFILE_DEPS)
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Agent (init) input scripts: $(PACKER_AGENT_INIT_INPUTS)"
	$(VERB) cat $(PACKER_AGENT_INIT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Agent (init) output script:"
	$(DEBUG) cat $@

$(PACKER_SERVER_INIT): $(PACKER_SERVER_INIT_INPUTS) $(MAKEFILE_DEPS)
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Server (init) input scripts: $(PACKER_SERVER_INIT_INPUTS)"
	$(VERB) cat $(PACKER_SERVER_INIT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Server (init) output script:"
	$(DEBUG) cat $@

$(PACKER_SERVER_AGENT_INIT): $(PACKER_SERVER_AGENT_INIT_INPUTS) $(MAKEFILE_DEPS)
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Server + agent (init) input scripts: $(PACKER_SERVER_AGENT_INIT_INPUTS)"
	$(VERB) cat $(PACKER_SERVER_AGENT_INIT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Server + agent (init) output script:"
	$(DEBUG) cat $@
