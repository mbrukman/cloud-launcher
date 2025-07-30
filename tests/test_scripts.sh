#!/bin/bash -u
#
# Licensed under the Apache License, Version 2.0 (the "License")
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
# Runs all *_test.* scripts.

declare -i STATUS=0
declare -r PYTHON="${PYTHON:-python}"

echo
echo "--------------------"
echo "Running script tests"
echo "--------------------"
for test in *_test.*; do
  tempfile="$(mktemp "/tmp/$test.XXXXXX")"
  echo -n "Testing ${test} ... "
  if [[ $test =~ _test.py ]]; then
    env PYTHONPATH="${PYTHONPATH}" "${PYTHON}" "./${test}" > "${tempfile}" 2>&1
  else
    "./${test}" > "${tempfile}" 2>&1
  fi
  if [ $? -eq 0 ]; then
    echo "PASSED"
    rm -f "${tempfile}"
  else
    STATUS=1
    echo "FAILED (log in ${tempfile})"
    cat "${tempfile}"
  fi
done

exit ${STATUS}
