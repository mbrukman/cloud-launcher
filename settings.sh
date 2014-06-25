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
# Project settings for a Google Cloud Platform project.
# This file should be sourced into another shell script.
#
################################################################################

# Set common GCP variables. This allows us to either read from the environment,
# if those vars are set, or supply default values.
declare -r PROJECT="${PROJECT:-curious-lemmings-42}"
declare -r ZONE="${ZONE:-us-central1-b}"
