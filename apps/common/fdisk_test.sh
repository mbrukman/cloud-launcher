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
# Tests for fdisk.sh
#
################################################################################

source "$(dirname $0)/fdisk.sh"

declare STATUS="PASSED"
declare -i EXIT_CODE=0

function fail() {
  STATUS="FAILED"
  EXIT_CODE=1
}

# Args:
#   $1: expected value
#   $2: actual value
#   $3: message to print if $1 != $2 (will also exit)
function expect_eq() {
  if [[ "${1}" != "${2}" ]]; then
    echo "Failure: ${3}" >&2
    echo "Expected: ${1}" >&2
    echo "  Actual: ${2}" >&2
    echo >&2
    fail
  fi
}

# Args:
#   $1: numer
#   $2: denom
#   $3: result
function expect_ratio_test() {
  local numer="${1}"
  local denom="${2}"
  local result="${3}"

  expect_eq "${result}" "$(ratio_over_threshold "${numer}" "${denom}")" "${numer} / ${denom}"
}

expect_ratio_test 1 1 0
expect_ratio_test 1 2 0
expect_ratio_test 1 3 0
expect_ratio_test 2 5 0

expect_ratio_test 2 1 1
expect_ratio_test 4 2 1
expect_ratio_test 7 3 1

# These require floating point support; if adding new calculator approaches to
# fdisk.sh, beware that these will fail without floating point calculation.
expect_ratio_test 1.5 1 1
expect_ratio_test 3 2 1

echo "${STATUS}"
exit ${EXIT_CODE}
