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

test:
	$(VERB) for test in *_test.*; do \
	  $(ECHO) -n "Running $$test ... "; \
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
