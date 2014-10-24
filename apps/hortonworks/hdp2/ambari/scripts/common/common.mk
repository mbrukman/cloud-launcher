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
#
# Builds the Ambari agent and server init scripts.
#
# Note: each OS distribution must provide the following scripts:
#
# * repo-init.sh (may use function in repo-init-fn.sh)
# * agent-install.sh
# * server-install.sh
#
################################################################################

FDISK = ../../../../../common/fdisk.sh

# These are typically expected to be in the same directory as the including
# script, but are exposed here to enable overriddes.
REPO_INIT = repo-init.sh
AGENT_INSTALL = agent-install.sh
SERVER_INSTALL = server-install.sh

AGENT_INPUTS = \
  $(FDISK) \
  $(COMMON)/repo-init-fn.sh \
  $(REPO_INIT) \
  $(AGENT_INSTALL) \
  $(COMMON)/agent-setup.sh \
  $(COMMON)/agent-start.sh
AGENT_INIT = agent-init.gen.sh

SERVER_INPUTS = \
  $(FDISK) \
  $(COMMON)/repo-init-fn.sh \
  $(REPO_INIT) \
  $(SERVER_INSTALL) \
  $(COMMON)/server-setup.sh \
  $(COMMON)/server-start.sh
SERVER_INIT = server-init.gen.sh

PACKER_AGENT_BUILD_INPUTS = \
  $(COMMON)/repo-init-fn.sh \
  $(REPO_INIT) \
  $(AGENT_INSTALL)
PACKER_AGENT_BUILD = packer-agent-build.gen.sh

PACKER_AGENT_INIT_INPUTS = \
  $(FDISK) \
  $(COMMON)/agent-setup.sh \
  $(COMMON)/agent-start.sh
PACKER_AGENT_INIT = packer-agent-init.gen.sh

PACKER_SERVER_BUILD_INPUTS = \
  $(COMMON)/repo-init-fn.sh \
  $(REPO_INIT) \
  $(SERVER_INSTALL) \
  $(COMMON)/server-setup.sh
PACKER_SERVER_BUILD = packer-server-build.gen.sh

PACKER_SERVER_INIT_INPUTS = \
  $(FDISK) \
  $(COMMON)/server-start.sh
PACKER_SERVER_INIT = packer-server-init.gen.sh

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

DEBUG = @ true
ifeq ($(DEBUGGING),1)
	DEBUG = @
endif

all: vm packer

vm: $(AGENT_INIT) $(SERVER_INIT)

packer: $(PACKER_AGENT_BUILD) $(PACKER_AGENT_INIT) $(PACKER_SERVER_BUILD) $(PACKER_SERVER_INIT)

clean:
	$(VERB) rm -f $(AGENT_INIT) $(SERVER_INIT)
	$(VERB) rm -f $(PACKER_AGENT_BUILD) $(PACKER_SERVER_BUILD)
	$(VERB) rm -f $(PACKER_AGENT_INIT) $(PACKER_SERVER_INIT)

$(AGENT_INIT): $(AGENT_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Agent input scripts: $(AGENT_INPUTS)"
	$(VERB) cat $(AGENT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Agent output script:"
	$(DEBUG) cat $@

$(SERVER_INIT): $(SERVER_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Server input scripts: $(SERVER_INPUTS)"
	$(VERB) cat $(SERVER_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Server output script:"
	$(DEBUG) cat $@

$(PACKER_AGENT_BUILD): $(PACKER_AGENT_BUILD_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Agent (build) input scripts: $(PACKER_AGENT_BUILD_INPUTS)"
	$(VERB) cat $(PACKER_AGENT_BUILD_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Agent (build) output script:"
	$(DEBUG) cat $@

$(PACKER_AGENT_INIT): $(PACKER_AGENT_INIT_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Agent (init) input scripts: $(PACKER_AGENT_INIT_INPUTS)"
	$(VERB) cat $(PACKER_AGENT_INIT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Agent (init) output script:"
	$(DEBUG) cat $@

$(PACKER_SERVER_BUILD): $(PACKER_SERVER_BUILD_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Server (build) input scripts: $(PACKER_SERVER_BUILD_INPUTS)"
	$(VERB) cat $(PACKER_SERVER_BUILD_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Server (build) output script:"
	$(DEBUG) cat $@

$(PACKER_SERVER_INIT): $(PACKER_SERVER_INIT_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Server (init) input scripts: $(PACKER_SERVER_INIT_INPUTS)"
	$(VERB) cat $(PACKER_SERVER_INIT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Server (init) output script:"
	$(DEBUG) cat $@
