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
# Regenerates outputs for PY->JSON and YAML->JSON tests.

declare -i EXIT_CODE=0
declare -r PYTHONPATH=..

for in_py in testdata/*_in.py; do
  out_json="$(echo "${in_py}" | sed 's/_in.py/_out.json/')"
  out_json_base="$(basename "${out_json}")"
  tempfile="$(mktemp "/tmp/${out_json_base}.XXXXXX")"
  env PYTHONPATH="${PYTHONPATH}" "${PYTHONPATH}/config_py.py" "${in_py}" > "${tempfile}" 2>&1
  if [ $? -eq 0 ]; then
    mv "${tempfile}" "${out_json}"
  else
    echo "FAILED to generate ${out_json_base}, log in ${tempfile}" >&2
    EXIT_CODE=1
  fi
done

for in_yaml in testdata/*.in.yaml; do
  out_json="$(echo $in_yaml | sed 's/.in.yaml/.out.json/')"
  out_json_base="$(basename "${out_json}")"
  tempfile="$(mktemp "/tmp/${out_json_base}.XXXXXX")"
  ${PYTHONPATH}/config_yaml.py "${in_yaml}" > "${tempfile}" 2>&1
  if [ $? -eq 0 ]; then
    mv "${tempfile}" "${out_json}"
  else
    echo "FAILED to generate ${out_json_base}, log in ${tempfile}" >&2
    EXIT_CODE=1
  fi
done

exit $EXIT_CODE
