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

ifeq ($(ENABLE_FDISK),1)
	FDISK = $(COMMON)/../../../../../common/fdisk.sh
endif

# Ensure a non-empty list of inputs to avoid hanging cat(1), which otherwise
# waits for input from stdin.
NOOP = /dev/null
FDISK ?= $(NOOP)
SERVER_PRE_INSTALL ?= $(NOOP)
SERVER_POST_INSTALL ?= $(NOOP)
AGENT_PRE_INSTALL ?= $(NOOP)
AGENT_POST_INSTALL ?= $(NOOP)

# Server

PACKER.server.build.1.in = \
  $(SERVER_PRE_INSTALL) \
  $(COMMON)/cloudera-user.sh \
  $(COMMON)/sshd-enable-password-auth.sh \
  $(COMMON)/selinux-disable.sh

PACKER.server.build.1.out = packer-server-build.1.gen.sh

PACKER.server.build.2.in = \
  $(SERVER_POST_INSTALL)

PACKER.server.build.2.out = packer-server-build.2.gen.sh

PACKER.server.build.out = \
  $(PACKER.server.build.1.out) \
  $(PACKER.server.build.2.out)

PACKER.server.start.in = \
  $(FDISK) \
  $(COMMON)/sshd-enable-password-auth.sh \
  $(COMMON)/path-a/manager-install.sh \
  $(COMMON)/server-start.sh

PACKER.server.start.out = packer-server-start.gen.sh

# Agent

PACKER.agent.build.1.in = \
  $(AGENT_PRE_INSTALL) \
  $(COMMON)/cloudera-user.sh \
  $(COMMON)/sshd-enable-password-auth.sh \
  $(COMMON)/selinux-disable.sh

PACKER.agent.build.1.out = packer-agent-build.1.gen.sh

PACKER.agent.build.2.in = \
  $(AGENT_POST_INSTALL)

PACKER.agent.build.2.out = packer-agent-build.2.gen.sh

PACKER.agent.build.out = \
  $(PACKER.agent.build.1.out) \
  $(PACKER.agent.build.2.out)

PACKER.agent.start.in = \
  $(FDISK) \
  $(COMMON)/sshd-enable-password-auth.sh

PACKER.agent.start.out = packer-agent-start.gen.sh

MAKEFILE_DEPS = \
  Makefile \
  $(COMMON)/path-a/common.mk

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

all: server agent

server: $(PACKER.server.build.out) $(PACKER.server.start.out)

agent: $(PACKER.agent.build.out) $(PACKER.agent.start.out)

clean:
	$(VERB) rm -f $(PACKER.server.build.out) $(PACKER.server.start.out)
	$(VERB) rm -f $(PACKER.agent.build.out) $(PACKER.agent.start.out)

# TODO(mbrukman): simplify these repeated rules via templates.

$(PACKER.server.build.1.out): $(PACKER.server.build.1.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.server.build.1.in) | sed '/^[[:space:]]*#/d' > $@

$(PACKER.server.build.2.out): $(PACKER.server.build.2.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.server.build.2.in) | sed '/^[[:space:]]*#/d' > $@

$(PACKER.server.start.out): $(PACKER.server.start.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.server.start.in) | sed '/^[[:space:]]*#/d' > $@

$(PACKER.agent.build.1.out): $(PACKER.agent.build.1.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.agent.build.1.in) | sed '/^[[:space:]]*#/d' > $@

$(PACKER.agent.build.2.out): $(PACKER.agent.build.2.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.agent.build.2.in) | sed '/^[[:space:]]*#/d' > $@

$(PACKER.agent.start.out): $(PACKER.agent.start.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.agent.start.in) | sed '/^[[:space:]]*#/d' > $@
