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

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

ECHO = /bin/echo

# Can override this to apply a different config.
CONFIG = centos6.pp

default:
	$(VERB) $(ECHO) "Available actions: apply"
	$(VERB) $(ECHO) "% make apply CONFIG=centos6.pp"

gce_compute:
	$(VERB) puppet module install --target-dir=. puppetlabs-gce_compute

startup-scripts:
	$(VERB) make -C ../scripts/centos-6
	$(VERB) make -C ../scripts/rhel-6

apply: startup-scripts gce_compute
	$(VERB) puppet apply --modulepath=. $(CONFIG)
