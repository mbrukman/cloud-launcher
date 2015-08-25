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

PROJECT = curious-lemmings-42
VERSION = new-version

VERB = @
ifeq (VERBOSE, 1)
	VERB =
endif

# Catch the user running "make" without a target.
.PHONY default:
	$(VERB) echo "Valid actions: pip-install, local, deploy."

# Via https://cloud.google.com/appengine/docs/python/tools/libraries27#vendoring
pip-install:
	$(VERB) pip install -t lib -r requirements.txt

# See https://cloud.google.com/sdk/gcloud-app for more info.
local:
	$(VERB) gcloud preview app run app.yaml

# See https://cloud.google.com/sdk/gcloud-app for more info.
deploy:
	$(VERB) gcloud --project=$(PROJECT) preview app deploy --version=$(VERSION) app.yaml
