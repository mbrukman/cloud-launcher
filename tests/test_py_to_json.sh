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
# Runs all Python -> JSON tests.

echo
echo "------------------------"
echo "Running PY -> JSON tests"
echo "------------------------"

for in_py in testdata/*_in.py; do
  out_json="$(echo "${in_py}" | sed 's/_in.py/_out.json/')"
  out_json_base="$(basename "${out_json}")"
  echo -n "Testing ${in_py} -> ${out_json} ... "
  tempfile="$(mktemp "/tmp/${out_json_base}.XXXXXX")"
  env PYTHONPATH="${PYTHONPATH}" "${PYTHONPATH}/config_py.py" "${in_py}" > "${tempfile}" 2>&1

  if [[ $? -ne 0 ]]; then
    echo "FAILED (error log in ${tempfile})"
    cat "${tempfile}"
  elif diff "${out_json}" "${tempfile}" > /dev/null 2>&1 ; then
    echo "PASSED"
    rm -f "${tempfile}"
  else
    echo "FAILED (output in ${tempfile})"
    echo "Diff:"
    diff -u "${out_json}" "${tempfile}"
  fi
done
