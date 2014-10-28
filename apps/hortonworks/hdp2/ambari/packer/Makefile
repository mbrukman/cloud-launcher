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
# Use Packer to build a GCE VM image with Ambari agent and server preinstalled.
#
################################################################################

TEMPLATE_JSON = ambari.json
TEMPLATE_YAML = ambari.yaml

YAML2JSON = ./yaml2json.py

# User settings, can be overridden on the make command line.

# Google Compute Engine settings.
PROJECT = encoded-source-539
ZONE = us-central1-b

# Google Cloud Storage settings.
GS_BUCKET = centos6-packer-images
AMBARI_IMAGE = centos6-ambari

VARS = \
  -var "ambari_image=$(AMBARI_IMAGE)" \
  -var "bucket_name=$(GS_BUCKET)" \
  -var "project=$(PROJECT)" \
  -var "zone=$(ZONE)"

VERB = @
ifeq ($(VERBOSE),1)
	VERB :=
endif

default:
	$(VERB) echo "Valid actions: build, inspect, validate, clean-images"

%.json: %.yaml $(YAML2JSON)
	$(VERB) $(YAML2JSON) "$<" > "$@"

build: $(TEMPLATE_JSON)
	$(VERB) packer build -force $(VARS) $(TEMPLATE_JSON)

inspect: $(TEMPLATE_JSON)
	$(VERB) packer inspect $(TEMPLATE_JSON)

validate: $(TEMPLATE_JSON)
	$(VERB) packer validate $(VARS) $(TEMPLATE_JSON)

clean-images:
	$(VERB) for image in $(AMBARI_IMAGE); do \
	  echo "Removing $${image} image ..."; \
	  gsutil rm -f gs://$(GS_BUCKET)/$${image}.tar.gz; \
	  gcutil --project=$(PROJECT) deleteimage -f $${image}; \
	done
	$(VERB) echo "Done."
