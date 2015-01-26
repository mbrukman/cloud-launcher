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
# Use Packer to build a GCE VM image with Cloudera Manager agent and server
# preinstalled.
#
################################################################################

include settings.mk

TEMPLATE_JSON = manager.json
TEMPLATE_YAML = manager.yaml

YAML2JSON = ./yaml2json.py

OS = centos-6
# This is the method of installation (e.g., A, B, or C) as defined by the
# Cloudera CDH installation manual.
CDH_INSTALL = path-a

IMAGE.$(OS).in = $(OS)-$(VERSION.$(OS))

IMAGE.$(OS).out = $(OS)-$(VERSION.$(OS))-cloudera

BASE_VARS = \
  -var "project=$(PROJECT)" \
  -var "zone=$(ZONE)" \
  -var input_image="$(IMAGE.$(OS).in)" \
  -var output_image="$(IMAGE.$(OS).out)"

VERSION.centos-6 = v20141218
SCRIPTS.centos-6 = "../scripts/centos-6/$(CDH_INSTALL)"
VARS.centos-6 = \
  $(BASE_VARS) \
  -var output_image_desc="CentOS 6 $(VERSION.centos-6) + Cloudera" \
  -var build_script="$(SCRIPTS.centos-6)/packer-build.gen.sh"

VERSION.rhel-6 = v20141218
SCRIPTS.rhel-6 = "../scripts/rhel-6/$(CDH_INSTALL)"
VARS.rhel-6 = \
  $(BASE_VARS) \
  -var output_image_desc="RHEL 6 $(VERSION.rhel-6) + Cloudera" \
  -var build_script="$(SCRIPTS.rhel-6)/packer-build.gen.sh"

VARS = $(BASE_VARS) $(VARS.$(OS))

VERB = @
ifeq ($(VERBOSE),1)
	VERB :=
endif

MAKEFILE_DEPS = Makefile

default:
	$(VERB) echo "Valid actions: build, inspect, validate, clean"

%.json: %.yaml $(YAML2JSON)
	$(VERB) $(YAML2JSON) "$<" > "$@"

# Automatically regenerate the build scripts prior to running Packer commands.
build-scripts:
	$(VERB) $(MAKE) VERBOSE=$(VERBOSE) -s -C ../scripts/$(OS)/$(CDH_INSTALL)

build: $(TEMPLATE_JSON) $(MAKEFILE_DEPS) build-scripts validate
	$(VERB) echo "Building images for $(OS) via $(CDH_INSTALL)"
	$(VERB) packer build -force $(VARS) $(TEMPLATE_JSON)

inspect: $(TEMPLATE_JSON) $(MAKEFILE_DEPS) build-scripts
	$(VERB) packer inspect $(TEMPLATE_JSON)

validate: $(TEMPLATE_JSON) $(MAKEFILE_DEPS) build-scripts
	$(VERB) packer validate $(VARS) $(TEMPLATE_JSON)

clean:
	$(VERB) gcloud compute images delete --quiet $(IMAGE.$(OS).out) --project=$(PROJECT)
