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
DISABLE_FIREWALL ?= $(NOOP)

# Common (build)

PACKER.build.in = \
  $(COMMON)/cloudera-user.sh \
  $(DISABLE_FIREWALL) \
  $(COMMON)/selinux-disable.sh

PACKER.build.out = packer-build.gen.sh

# Server (start)

PACKER.server.start.in = \
  $(FDISK) \
	$(COMMON)/hostname.sh \
  $(COMMON)/path-a/manager-install.sh

PACKER.server.start.out = packer-server-start.gen.sh

# Agent (start)

PACKER.agent.start.in = \
  $(FDISK) \
	$(COMMON)/hostname.sh

PACKER.agent.start.out = packer-agent-start.gen.sh

ALL_OUTPUTS = \
  $(PACKER.build.out) \
  $(PACKER.server.start.out) \
  $(PACKER.agent.start.out)

MAKEFILE_DEPS = \
  Makefile \
  $(COMMON)/path-a/common.mk

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

all: $(ALL_OUTPUTS)

clean:
	$(VERB) rm -f $(ALL_OUTPUTS)

# TODO(mbrukman): simplify these repeated rules via templates.

$(PACKER.build.out): $(PACKER.build.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.build.in) | sed '/^[[:space:]]*#/d' > $@

$(PACKER.server.start.out): $(PACKER.server.start.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.server.start.in) | sed '/^[[:space:]]*#/d' > $@

$(PACKER.agent.start.out): $(PACKER.agent.start.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(PACKER.agent.start.in) | sed '/^[[:space:]]*#/d' > $@
