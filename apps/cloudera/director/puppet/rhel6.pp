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
# Deployment for Cloudera Director using a CentOS 6 image.
#
##########################################################################

gce_instance { 'cloudera-director':
  ensure => present,
  machine_type => 'n1-standard-1',
  zone => 'us-central1-f',
  image => 'rhel-6',
  startup_script => '../../../scripts/rhel-6/init.gen.sh',
  block_for_startup_script => true,
}
