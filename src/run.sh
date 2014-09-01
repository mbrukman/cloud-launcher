#!/bin/bash -eu
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
# Simplifies using run.py by automatically providing its required flags.

# The file containing settings such as project name, region, zone, etc.
declare -r SETTINGS="${SETTINGS:-$(dirname $0)/settings.sh}"
source "${SETTINGS}" || exit 1

$(dirname $0)/run.py --project="${PROJECT}" --zone="${ZONE}" "$@"
