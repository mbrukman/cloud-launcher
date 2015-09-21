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
# Install and configure Docker.
################################################################################

# See https://docs.docker.com/installation/centos/ for details on the
# installation process. We are using the manual steps rather than running an
# opaque script as root.

yum update -q -y

# Note: rather than adding the `docker.repo` file as per instructions, we are
# installing Docker from the EPEL repo, since that's the only supported method
# for installing Docker on CentOS and Red Hat per:
#
#     https://github.com/docker/docker/pull/9918/files
#
# As of this writing (20 Sep 2015), this installs Docker 1.7 which is not
# sufficient for Flocker.
#
# Although one can install the latest version of Docker via their custom YUM
# repo, it appears to hang on CentOS when one runs the `docker` CLI tool.

echo "Adding EPEL repo..."
yum install -q -y epel-release
yum makecache
echo "Done adding EPEL repo."

echo "Installing docker..."
yum install -q -y docker
echo "Done installing docker."

# Start the Docker service immediately.
service docker start

# Ensure that Docker service runs on boot every time.
chkconfig docker on

# Note: the Docker installation instructions further recommend creating a
# `docker` group and adding users to it:
#
#     https://docs.docker.com/installation/centos/#create-a-docker-group
#
# but on Google Compute Engine VMs, each
# SSH user auto-created via `gcloud compute ssh` (i.e., users who have edit
# access) automatically get passwordless sudo access, so this is just extra
# overhead without any improved security.
#
# TODO(mbrukman): revisit this if/when Google Compute Engine changes its
# permission system for user accounts.
