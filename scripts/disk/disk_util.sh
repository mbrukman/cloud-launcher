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
# Utilities for managing disks from within a VM, such as mounting and unmounting.
#
################################################################################

# On each Ambari agent VM instance, the disk appears as
# /dev/disk/by-id/google-data due to the aliasing, which allows us to treat them
# all uniformly on each instance.

declare -r DISK="/dev/disk/by-id/google-data"
declare -r MOUNT="/mnt/data"

declare -r SCRIPT_INSTALL="/home/$USER/$(basename $0)"

PREFIX=""
if [ -n "${DEBUG:-}" ]; then
  PREFIX="echo"
fi

# Silence is golden, unless it's actually important.
declare -r GCUTIL="gcutil --log_level=ERROR --library_log_level=ERROR"

# Runs this script on each instance with given command.
# Args:
#   $1: command to run
function ssh_run_command() {
  IDS="${IDS:-$(seq 0 4)}"
  for id in ${IDS}; do
    instance_name="ambari-agent-${id}"
    echo "Running command [$1] on instance ${instance_name} ..."
    # sudo requires a tty.
    # A single -t flag to ssh allocates a pseudo-tty; multiple -t flags allocate a tty.
    # see "man ssh" for more info.
    ${PREFIX} ${GCUTIL} ssh --ssh_arg=-t --ssh_arg=-t "${instance_name}" sudo "${SCRIPT_INSTALL}" "$1"
  done
}

declare -r COMMAND="${1:-}"
case "${COMMAND}" in

  mount)
    # Run this on a specific VM instance.
    mkdir -p "${MOUNT}"
    /usr/share/google/safe_format_and_mount -m "mkfs.ext4 -F" "${DISK}" "${MOUNT}"
    chmod a+w "${MOUNT}"
    ;;

  umount)
    # Run this on a specific VM instance.
    umount "${DISK}"
    ;;

  push_all)
    # Run this script remotely; will affect all instances.
    IDS="${IDS:-$(seq 0 4)}"
    for id in ${IDS}; do
      instance_name="ambari-agent-${id}"
      echo "Pushing $0 to instance ${instance_name} ..."
      ${GCUTIL} push "${instance_name}" "$0" "${SCRIPT_INSTALL}"
    done
    echo "Done."
    ;;

  mount_all)
    # Run this script remotely; will affect all instances.
    ssh_run_command mount
    ;;

  umount_all)
    # Run this script remotely; will affect all instances.
    ssh_run_command umount
    ;;

  *)
    echo "Invalid command: '${COMMAND}'; available options: mount, umount, push_all, mount_all, umount_all" >&2
    exit 1
    ;;

esac
