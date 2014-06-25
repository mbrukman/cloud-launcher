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
# Manually resizes a disk using `resize2fs'.

PREFIX=""
if [ -n "${DEBUG:-}" ]; then
  PREFIX="echo"
fi

# Silence is golden, unless it's actually important.
declare -r GCUTIL="gcutil --log_level=ERROR --library_log_level=ERROR"

IDS="${IDS:-$(seq 0 4)}"
for id in ${IDS}; do
  instance_name="ambari-agent-${id}"
  # sudo requires a tty.
  # A single -t flag to ssh allocates a pseudo-tty; multiple -t flags allocate a tty.
  # see "man ssh" for more info.
  ${PREFIX} ${GCUTIL} ssh --ssh_arg=-t --ssh_arg=-t "${instance_name}" sudo resize2fs /dev/sda1
done
