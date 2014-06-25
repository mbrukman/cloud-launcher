#!/bin/bash
#
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
# Takes the same action on multiple GCP instances.

declare -r SETTINGS="${SETTINGS:-settings.sh}"

source "${SETTINGS}" || exit 1

# If the user set the env var $DEBUG, prefix mutating commands with "echo" so
# that they have no effect.
PREFIX=""
if [ -n "${DEBUG:-}" ]; then
  PREFIX="echo"
fi

declare IDS="${IDS:-$(seq 0 4)}"
for id in ${IDS}; do
  instance_name="ambari-agent-${id}"
  ${PREFIX} gcutil ssh --ssh_arg=-t --ssh_arg=-t --project="${PROJECT}" "${instance_name}" "$@"
done

