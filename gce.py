#!/usr/bin/python
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
# Constructors for Resources suitable for making GCE API calls.

import common
import vm_images

# Allow users to write 'true' the way they write it in many common languages,
# particularly Javascript, which is quite relevant, since we're generating JSON
# as output.
true = True

class Dict(dict):
  """A dict-like class to allow referencing via x.y and x['y'].

  This class subclasses from `dict` to be easily serializable to JSON for the
  purposes of calling REST APIs with the data contained within.
  """

  def __init__(self, **kwargs):
    super(Dict, self).__init__()
    for name, value in kwargs.iteritems():
      self.__setattr__(name, value)

  def __setattr__(self, name, value):
    self.__setitem__(name, value)
    super(Dict, self).__setattr__(name, value)

  def __filterKey(self, key):
    return not key.startswith('_')

  def keys(self):
    return [key for key in super(Dict, self).keys() if self.__filterKey(key)]

  def items(self):
    return [(key, value) for key, value in super(Dict, self).items()
            if self.__filterKey(key)]

  def iteritems(self):
    for key, value in super(Dict, self).iteritems():
      if self.__filterKey(key):
        yield (key, value)


class GCE(object):
  class Settings(object):
    project = None
    zone = None

  default = Settings()

  @classmethod
  def setDefaults(cls, project=None, zone=None):
    if project is not None:
      GCE.default.project = project

    if zone is not None:
      GCE.default.zone = zone


class Util(object):

  @classmethod
  def updateResourceWithParams(cls, resource, params):
    resource = Dict(**resource)
    for key, val in params.iteritems():
      if val is not None:
        resource[key] = val

    return resource


class Image(object):

  @classmethod
  def resolve(cls, image, project=None):
    """
    Args:
      image (string): short name of the image
      project (string): (optional) project name

    Returns:
      string (URL pointing to the VM image)
    """
    if project is None:
      return vm_images.ImageShortNameToUrl(image)

    return common.ImageToUrl(project, image)

class Disk(object):

  def __init__(self):
    assert False, 'Do not create a Disk via instance ctor; use static factory method instead'

  @classmethod
  def initializeParams(
      cls, sourceImage, diskSizeGb=None, diskType=None):
    resources = {
        'sourceImage': Image.resolve(sourceImage),
        # TODO(mbrukman): do we need a default here? GCE defaults this to 10GB
        # already; avoiding this explicit default makes the output cleaner.
        #
        # 'diskSizeGb': 10,
    }

    # Ensure that the user specified this parameter correctly.
    if (diskType is not None) and (not common.IsUrl(diskType)):
      diskType = common.DiskTypeToUrl(
          GCE.default.project, GCE.default.zone, diskType)

    params = {
        'diskSizeGb':  diskSizeGb,
        'diskType': diskType,
    }
    return Util.updateResourceWithParams(resources, params)

  @classmethod
  def attachedDisk(
      cls, autoDelete=None, boot=None, initializeParams=None,
      mode=None, type=None):
    """Creates a `Disk` suitable for inline inclusion in a compute `Instance`.

    Args:
      See documentation for the API:
      https://developers.google.com/compute/docs/reference/latest/instances
      https://developers.google.com/compute/docs/reference/latest/instances/attachDisk

    Returns:
      dict suitable for conversion to JSON.
    """
    resource = {
        'kind': 'compute#attachedDisk',
        'mode': 'READ_WRITE',
        'type': 'PERSISTENT',
    }
    params = {
        'autoDelete': autoDelete,
        'boot': boot,
        'initializeParams': initializeParams,
        'mode': mode,
        'type': type,
    }
    return Util.updateResourceWithParams(resource, params)

  @classmethod
  def boot(cls, **kwargs):
    kwargs['boot'] = True
    return cls.attachedDisk(**kwargs)

  @classmethod
  def data(cls, **kwargs):
    return cls.attachedDisk(**kwargs)


class Network(object):

  @classmethod
  def externalNat(cls, name=None):
    resource = {
        'network': 'default',
        'accessConfigs': [
          {
            'type': 'ONE_TO_ONE_NAT',
            'name': 'External NAT',
          },
        ],
    }
    params = {
        'network': name,
    }
    return Util.updateResourceWithParams(resource, params)

  @classmethod
  def create(cls, name, gatewayIPv4=None, IPv4Range=None):
    resource = {
        'kind': 'cloud#network',
        'name': name,
    }
    params = {
        'gatewayIPv4': gatewayIPv4,
        'IPv4Range': IPv4Range,
    }
    return Util.updateResourceWithParams(resource, params)


class Metadata(object):

  @classmethod
  def create(cls, items=None):
    resource = {
        'kind': 'compute#metadata',
    }
    params = {
        'items': items,
    }
    return Util.updateResourceWithParams(resource, params)

  @classmethod
  def item(cls, key, value):
    return {
        'key': key,
        'value': value,
    }

  @classmethod
  def fileToString(cls, path):
    import traceback
    stack = traceback.extract_stack()
    current = None
    previous = None
    for (filename, line, function, text) in stack:
      if current is None:
        current = filename
        continue
      if current != filename:
        previous = filename
        break

    return common.ReadReferencedFileToString(previous, '%%file:%s' % path)

  @classmethod
  def startupScript(cls, path):
    return Metadata.item('startup-script', Metadata.fileToString(path))


class Compute(object):

  @classmethod
  def instance(
    cls, name, disks=None, machineType=None, metadata=None,
    networkInterfaces=None, tags=None, zone=None):
    """
    Args:
      See API documentation:
      https://developers.google.com/compute/docs/reference/latest/instances

    Returns:
      dict suitable for conversion to JSON, corresponding to "compute#instance"
      Resource kind in the GCE API
    """
    resource = {
        'kind': 'compute#instance',
        'name': name,
        'networkInterfaces': [Network.externalNat()],
        'serviceAccounts': [
          {
            'email': 'default',
            'scopes': [
              'https://www.googleapis.com/auth/devstorage.full_control',
              'https://www.googleapis.com/auth/compute'
            ],
          },
        ],
    }

    params = {
        'disks': disks,
        'machineType': machineType,
        'metadata': metadata,
        'networkInterfaces': networkInterfaces,
        'tags': tags,
        'zone': zone,
    }

    return Util.updateResourceWithParams(resource, params)
