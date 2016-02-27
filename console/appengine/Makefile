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
ifeq ($(VERBOSE), 1)
	VERB =
endif

# Catch the user running "make" without a target.
.PHONY default:
	$(VERB) echo "Valid actions: pip-install, local, deploy."

# Via https://cloud.google.com/appengine/docs/python/tools/libraries27#vendoring
THIRD_PARTY_PYTHON = third_party/python
pip-install:
	$(VERB) mkdir -p $(THIRD_PARTY_PYTHON)
	$(VERB) pip install -t $(THIRD_PARTY_PYTHON) -r requirements.txt

COMPUTE_API_PY = compute_api.py
COMPUTE_API_YAML = compute_api.yaml
COMPUTE_API_GEN_PY = compute_api_gen.py

compute_api_gen: $(COMPUTE_API_GEN_PY)

$(COMPUTE_API_GEN_PY): $(COMPUTE_API_PY) $(COMPUTE_API_YAML)
	$(VERB) ./$(COMPUTE_API_PY) $(COMPUTE_API_YAML) > $@

# See https://cloud.google.com/sdk/gcloud-app for more info.
local: compute_api_gen
	$(VERB) gcloud preview app run app.yaml

# See https://cloud.google.com/sdk/gcloud-app for more info.
deploy: compute_api_gen
	$(VERB) gcloud --project=$(PROJECT) preview app deploy --version=$(VERSION) app.yaml

# Provide libraries for testing.
pip-install-test:
	$(VERB) pip install -t $(THIRD_PARTY_PYTHON) -r requirements-test.txt

# Run tests.
test: compute_api_gen
	$(VERB) python -m unittest discover -p '*_test.py'

# Clean up directories of generated files as well as external libraries
# installed via "make pip-install{,-test}".
clean:
	$(VERB) rm -f *.pyc
	$(VERB) rm -rf $(THIRD_PARTY_PYTHON)
