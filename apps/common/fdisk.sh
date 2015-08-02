#!/bin/bash -u
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
# We're restoring a 10GB OS image onto a larger disk. That space will not be
# visible until we repartition the disk, which then also requires us to reboot
# the instance.
#
# We assume that there's a single disk at /dev/sda with a single root partition
# and we're extending it to fill the entire disk for simplicity.
#
# See detailed docs here:
# https://developers.google.com/compute/docs/disks#repartitionrootpd
#
################################################################################

# The ratio between the entire disk and the first partition in blocks or space
# that needs to be exceeded for us to repartition the disk or resize the
# filesystem.
#
# We are giving it some slack in case not all blocks or sectors are in use, and
# we would like to avoid both an infinite loop with reboot, or running resize2fs
# on every reboot.
declare -r THRESHOLD="1.1"

# Args:
#   $1: numerator
#   $2: denominator
#   $3: threshold (optional; defaults to $THRESHOLD)
#
# Returns:
#   1 if (numerator / denominator > threshold)
#   0 otherwise
function ratio_over_threshold() {
  local numer="${1}"
  local denom="${2}"
  local threshold="${3:-${THRESHOLD}}"

  if `which python > /dev/null 2>&1`; then
    python -c "print(1 if (1. * ${numer} / ${denom} > ${threshold}) else 0)"
  elif `which bc > /dev/null 2>&1`; then
    echo "${numer} / ${denom} > ${threshold}" | bc -l
  else
    echo "Neither python nor bc were found; calculation infeasible." >&2
    exit 1
  fi
}

# Repartitions the disk or resizes the file system, depending on the current
# state of the partition table.
function main() {
  # This gets us the size, in blocks, of the whole disk and the first partition.
  local dev_sda="$(fdisk -s /dev/sda)"
  local dev_sda1="$(fdisk -s /dev/sda1)"

  # If the ratio between the entire disk and the first partition is over
  # ${THRESHOLD}, then we haven't yet repartitioned the disk.
  #
  # Of interest is that fdisk(1) has opposite behavior on CentOS vs. Debian.
  # While the 'c' and 'u' commands can be used to toggle DOS compatibility mode
  # and cylinder (vs. sector) display, respectively, it turns out that fdisk(1)
  # starts in opposite modes on CentOS (both enabled) vs. Debian (both
  # disabled), so unconditionally using those commands has the opposite effect
  # on those two distributions.
  #
  # However, using the -c and -u flags disables them (as we want) on both
  # distributions, so we use them as flags instead of commands.
  #
  # fdisk(1) flags:
  # -c: disable DOS compatibility mode
  # -u: change display mode to sectors (from cylinders)
  #
  # fdisk(1) commands:
  # d: delete partition (automatically selects the first one)
  # n: new partition
  # p: primary
  # 1: partition number
  # <2 blank lines>: accept the defaults for start and end sectors
  # w: write partition table
  if [ $(ratio_over_threshold "${dev_sda}" "${dev_sda1}") -eq 1 ]; then
    cat <<EOF | fdisk -c -u /dev/sda
d
n
p
1


w
EOF
    # We've made the changes to the partition table, but they just haven't taken
    # effect, so we need to reboot. On the next reboot, the if statement will be
    # false and we'll fall into the else case which will reread the partition
    # table and automatically resize the partition for us.
    reboot
  else
    # After the repartitioning and reboot, we have the following:
    #
    #   fdisk -s /dev/sda  => 524288000
    #   fdisk -s /dev/sda1 => 524286976
    #
    # so the ratio no longer tells us anything. However, now we can examine the
    # actual usable space on disk to see the difference:
    #
    # Before (on CentOS):
    # % df -B 1K /dev/sda1
    # Filesystem           1K-blocks      Used Available Use% Mounted on
    # /dev/sda1             10319160   1020760   8774216  11% /
    #
    # After (on CentOS):
    # % df -B 1K /dev/sda1
    # Filesystem           1K-blocks      Used Available Use% Mounted on
    # /dev/sda1            516060600   1041548 488811080   1% /
    #
    # On Debian, the device behind the root filesystem is not /dev/sda1 but a
    # disk with random UUID, e.g.,
    #
    # % df -B 1K /
    # Filesystem              1K-blocks   Used Available Use% Mounted on
    # /dev/disk/by-uuid/{...}  10320184 680336   9115612   7% /
    #
    # % df -B 1K /dev/sda1
    # Filesystem     1K-blocks  Used Available Use% Mounted on
    # udev               10240     0     10240   0% /dev
    #
    # so we read the size of the root partition to work on both.
    local dev_sda1_df="$(df -B 1K / | grep ' /$' | awk '{ print $2 }')"
    if [ $(ratio_over_threshold "${dev_sda}" "${dev_sda1_df}") -eq 1 ]; then
      # For CentOS 7, we need to run a different command since it uses XFS, not
      # ext4 by default. See
      # https://cloud.google.com/compute/docs/disks/persistent-disks#manualrepartition
      # for more info.
      if [[ -e /etc/centos-release ]] &&
         [[ $(cat /etc/centos-release) =~ CentOS.Linux.release.7\..* ]]; then
        xfs_growfs /
      else
        # For earlier versions of CentOS and other distributions, we run resize2fs.
        resize2fs /dev/sda1
      fi
    fi
  fi
}

# Emulate Python's way of only executing the code if this file were invoked as
# the main one:
#
# if __name__ == '__main__':
#   ...
if [[ "$(basename $0)" != "fdisk_test.sh" ]]; then
  main
fi
