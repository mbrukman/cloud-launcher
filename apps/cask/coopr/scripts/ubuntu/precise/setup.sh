#!/bin/bash -eu
#
# Copyright 2015 Google Inc.
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
# Setup Coopr for operation.
#
################################################################################

# Do the initial setup and load defaults only once.
export COOPR_SERVER_URI="http://localhost:55054"

declare -r COOPR_SETUP="${HOME}/coopr_setup_done"
if ! [ -e "${COOPR_SETUP}" ]; then
  /opt/coopr/provisioner/bin/setup.sh
  touch "${COOPR_SETUP}"
fi

declare -r COOPR_DEFAULTS="${HOME}/coopr_defaults_loaded"
if ! [ -e "${COOPR_DEFAULTS}" ]; then
  /opt/coopr/server/config/defaults/load-defaults.sh
  touch "${COOPR_DEFAULTS}"
fi
