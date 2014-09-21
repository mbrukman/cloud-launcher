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
# Runs all tests.

declare -i STATUS=0

for script in test_*.sh; do
  ./${script}
  if [ $? -ne 0 ]; then
    STATUS=1
  fi
done

echo

if [ ${STATUS} -eq 0 ]; then
  echo "PASSED"
else
  echo "FAILED"
fi

exit ${STATUS}
