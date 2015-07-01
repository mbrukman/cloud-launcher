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
	FDISK = $(COMMON)/../../../../common/fdisk.sh
endif

ifeq ($(DOWNLOAD_FILE),1)
	DOWNLOAD_FILE = $(COMMON)/download-file.sh
endif

# Ensure a non-empty list of inputs to avoid hanging cat(1), which otherwise
# waits for input from stdin.
NOOP = /dev/null
FDISK ?= $(NOOP)
DISABLE_FIREWALL ?= $(NOOP)
DOWNLOAD_FILE ?= $(NOOP)
ADD_REPO ?= $(NOOP)
INSTALL ?= $(NOOP)
START ?= $(NOOP)

# Server (start)

SERVER.in = \
  $(FDISK) \
	$(DOWNLOAD_FILE) \
	$(ADD_REPO) \
	$(INSTALL) \
  $(START)

SERVER.out = init.gen.sh

ALL_OUTPUTS = $(SERVER.out)

MAKEFILE_DEPS = \
  Makefile \
  $(COMMON)/common.mk

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

all: $(ALL_OUTPUTS)

clean:
	$(VERB) rm -f $(ALL_OUTPUTS)

$(SERVER.out): $(SERVER.in) $(MAKEFILE_DEPS)
	$(VERB) cat $(SERVER.in) | sed '/^[[:space:]]*#/d' > $@
