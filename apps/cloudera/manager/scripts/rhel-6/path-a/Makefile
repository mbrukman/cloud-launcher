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
# Building RHEL 6 images and startup scripts.
#
################################################################################

# RHEL 6 does not have automatic repartitioning on boot and hence needs to use
# the fdisk(1) script to resize the boot disk to utilize its full capacity.
ENABLE_FDISK = 1

DISABLE_FIREWALL = ../iptables-disable.sh

COMMON = ../../common

include $(COMMON)/path-a/common.mk
