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
# Utility script for running the fdisk script manually on instances.

declare -r SCRIPT_LOCAL="fdisk.sh"
declare -r SCRIPT_INSTALL="/home/$USER/fdisk.sh"

PREFIX=""
if [ -n "${DEBUG:-}" ]; then
  PREFIX="echo"
fi

# Silence is golden, unless it's actually important.
declare -r GCUTIL="gcutil --log_level=ERROR --library_log_level=ERROR"

declare -r COMMAND="${1:-}"
case "${COMMAND}" in

  push_all)
    IDS="${IDS:-$(seq 0 4)}"
    for id in ${IDS}; do
      instance_name="ambari-agent-${id}"
      ${GCUTIL} push "${instance_name}" "${SCRIPT_LOCAL}" "${SCRIPT_INSTALL}"
    done
    ;;

  fdisk_all)
    IDS="${IDS:-$(seq 0 4)}"
    for id in ${IDS}; do
      instance_name="ambari-agent-${id}"
      echo "Running command [$1] on instance ${instance_name} ..."
      # sudo requires a tty.
      # A single -t flag to ssh allocates a pseudo-tty; multiple -t flags allocate a tty.
      # see "man ssh" for more info.
      ${PREFIX} ${GCUTIL} ssh --ssh_arg=-t --ssh_arg=-t "${instance_name}" sudo bash "${SCRIPT_INSTALL}"
    done
    ;;

  *)
    echo "Invalid command: '${COMMAND}', choices: (push_all, fdisk_all)." >&2
    exit 1
    ;;

esac
