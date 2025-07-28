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

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

ECHO = /bin/echo


default:
	$(VERB) $(ECHO) "Valid targets: clean, mypy-test, pytype-test, test."

clean:
	$(VERB) rm -f `find . -name \*\.pyc`

mypy-test:
	$(VERB) env PYTHONPATH=$(PYTHONPATH):$(pwd)/third_party/bunch:$(pwd)/src \
		python -m mypy --python-version=$(PYTHON_VERSION) examples src tests

pytype-test:
	$(VERB) env PYTHONPATH=$(PYTHONPATH):$(pwd)/third_party/bunch:$(pwd)/src \
		python -m pytype --python-version=$(PYTHON_VERSION) -k examples src tests

test:
	$(VERB) make -C tests test

# Requires having installed autopep8 first:
# https://github.com/hhatto/autopep8
#
# Note: we filter out several directories because we don't want to auto-format
# external (but version-controlled) source code (third_party/*) or
# auto-downloaded third-party source code (console/appengine/lib/*).
autopep8:
	$(VERB) find . -name \*\.py \
		| egrep -v '^./third_party/' \
		| egrep -v '^./console/appengine/lib' \
		| xargs -I {} autopep8 --in-place {}
