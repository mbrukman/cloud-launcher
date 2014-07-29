#!/bin/bash -u
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
# Runs all YAML -> JSON tests.

echo
echo "--------------------------"
echo "Running YAML -> JSON tests"
echo "--------------------------"
for in_yaml in testdata/*.in.yaml; do
	out_json="$(echo $in_yaml | sed 's/.in.yaml/.out.json/')"
	out_json_base="$(basename "${out_json}")"
  echo -n "Testing ${in_yaml} -> ${out_json} ... "
	tempfile="$(mktemp "/tmp/${out_json_base}.XXXXXX")"
	${PYTHONPATH}/config_yaml.py "${in_yaml}" > "${tempfile}" 2>&1
	if [[ $? -eq 0 ]] && [ ! `diff "${out_json}" "${tempfile}"` ]; then
		echo "PASSED"
    rm -f "${tempfile}"
  else
    echo "FAILED (output and log in $tempfile)"
    cat "${tempfile}"
  fi
done
