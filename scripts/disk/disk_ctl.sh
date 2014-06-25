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
# Provides utilities for controlling disks in GCP: listing, creating, attaching,
# and deleting.

declare -r SETTINGS="${SETTINGS:-settings.sh}"

source "${SETTINGS}" || exit 1

# If the user set the env var $DEBUG, prefix mutating commands with "echo" so
# that they have no effect.
PREFIX=""
if [ -n "${DEBUG:-}" ]; then
  PREFIX="echo"
fi

# Returns the instance name for a given id.
#
# Args:
#   $1: instance id
function instance_name() {
  echo "ambari-agent-$1"
}

# Returns the disk name to operate on for a given instance id.
#
# Args:
#   $1: instance id
function instance_disk_name() {
  echo "$(instance_name "$1")-disk-0"
}

declare -r IDS="${IDS:-$(seq 0 4)}"
declare -r COMMAND="${1:-}"
case "${COMMAND}" in
  list)
    gcutil --project="${PROJECT}" listdisks
    ;;

  get)
    gcutil --project="${PROJECT}" getdisk "$2"
    ;;

  create)
    declare -i SIZE_GB=500
    for id in ${IDS}; do
      disk_name="$(instance_disk_name "${id}")"
      echo "Creating disk ${disk_name} ..."
      ${PREFIX} gcutil --project="${PROJECT}" adddisk "${disk_name}" --zone="${ZONE}" --size_gb="${SIZE_GB}"
    done
    ;;

  attach)
    for id in ${IDS}; do
      instance_name="$(instance_name "${id}")"
      disk_name="$(instance_disk_name "${id}")"
      echo "Attaching disk ${disk_name} to ${instance_name} ..."
      ${PREFIX} gcutil --project="${PROJECT}" attachdisk \
        --zone="${ZONE}" \
        --disk="${disk_name},deviceName=data,mode=rw" \
        "${instance_name}"
    done
    ;;

  delete)
    PIDS=""
    for id in ${IDS}; do
      disk_name="$(instance_disk_name "${id}")"
      echo "Deleting disk ${disk_name} ..."
      ${PREFIX} gcutil --project="${PROJECT}" deletedisk "${disk_name}" --force &
      PIDS="${PIDS} $!"
    done
    echo "Waiting for pids: ${PIDS} ..."
    for pid in ${PIDS}; do
      ${PREFIX} wait $pid
    done
    ;;

  autodelete)
    for id in ${IDS}; do
      instance_name="$(instance_name "${id}")"
      disk_name="$(instance_disk_name "${id}")"
      ${PREFIX} gcutil --project="${PROJECT}" setinstancediskautodelete "${instance_name}" --device_name="${disk_name}" --zone="${ZONE}" --auto_delete
    done
    ;;

  noautodelete)
    for id in ${IDS}; do
      instance_name="$(instance_name "${id}")"
      disk_name="$(instance_disk_name "${id}")"
      ${PREFIX} gcutil --project="${PROJECT}" setinstancediskautodelete "${instance_name}" --device_name="${disk_name}" --noauto_delete
    done
    ;;

  addsnapshot)
    for id in ${IDS}; do
      instance_name="$(instance_name "${id}")"
      disk_name="$(instance_disk_name "${id}")"
      snapshot="${disk_name}-snapshot-${SNAPSHOT_ID:-0}"
      ${PREFIX} gcutil --project="${PROJECT}" addsnapshot "${snapshot}" --source_disk="${disk_name}"
    done
    ;;

  *)
    echo "Invalid command '${COMMAND}'; choose one of: list, get, create, attach, delete, autodelete, noautodelete, addsnapshot" >&2
    exit 1
esac
