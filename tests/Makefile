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
# Automatically runs all the tests in this directory.

PYTHONPATH = ..

VERB = @
ifeq (VERBOSE,1)
	VERB =
endif

ECHO = /bin/echo

default: test

test: test_scripts test_golden

test_golden:
	$(VERB) echo "---------------------------------"
	$(VERB) echo "Running golden input/output tests"
	$(VERB) echo "---------------------------------"
	$(VERB) for in_yaml in testdata/*.in.yaml; do \
		out_json="`echo $$in_yaml | sed 's/.in.yaml/.out.json/'`"; \
		out_json_base="`basename $$out_json`"; \
	  $(ECHO) -n "Testing $$in_yaml -> $$out_json ... "; \
	  tempfile=`mktemp "/tmp/$$out_json_base.XXXXXX"`; \
		../config_yaml.py ./$$in_yaml > $$tempfile 2>&1; \
		if [[ $$? -eq 0 ]] && [ ! `diff $$out_json $$tempfile > /dev/null 2>&1` ]; then \
			$(ECHO) "PASSED"; \
	    rm -f "$$tempfile"; \
	  else \
	    $(ECHO) "FAILED (output and log in $$tempfile)"; \
	    cat $$tempfile; \
	  fi; \
	done

test_scripts:
	$(VERB) echo "--------------------"
	$(VERB) echo "Running script tests"
	$(VERB) echo "--------------------"
	$(VERB) for test in *_test.*; do \
	  $(ECHO) -n "Testing $$test ... "; \
	  tempfile=`mktemp "/tmp/$$test.XXXXXX"`; \
	  env PYTHONPATH=$(PYTHONPATH) ./$$test > $$tempfile 2>&1; \
	  if [[ $$? -eq 0 ]]; then \
	    $(ECHO) "PASSED"; \
	    rm -f "$$tempfile"; \
	  else \
	    $(ECHO) "FAILED (log in $$tempfile)"; \
	    cat $$tempfile; \
	  fi; \
	done
