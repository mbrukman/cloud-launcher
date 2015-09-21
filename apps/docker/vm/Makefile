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

ROOT = ../../..
CLOUD_LAUNCHER = $(ROOT)/src/cloud_launcher.sh

OS = centos-7
CONFIG = $(OS).py

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

.PHONY default:
	$(VERB) echo "Valid targets: startup-script, insert, delete."

startup-script:
	$(VERB) make -s -C ../scripts/centos-7

insert: startup-script
	$(VERB) $(CLOUD_LAUNCHER) --config=$(CONFIG) insert

# The config must be valid even for delete, so we have to make sure that the
# startup-script exists.
delete: startup-script
	$(VERB) $(CLOUD_LAUNCHER) --config=$(CONFIG) delete
