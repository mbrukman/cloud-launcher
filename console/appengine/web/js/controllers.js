// Copyright 2015 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

var consoleControllers = angular.module('consoleControllers', []);

/**
 * @param {string} ui
 * @return {string}
 */
function lastComponentOfUri(uri) {
  var uriParts = uri.split('/');
  return uriParts[uriParts.length - 1];
}

/**
 * @param {Object} a
 * @param {Object} b
 * @return {number} -1 if a < b, 0 if a == b, 1 if a > b
 */
function compareByName(a, b) {
  var compareValues = function(s1, s2) {
    return s1 > s2 ? 1 : (s1 < s2 ? -1 : 0);
  };
  var aMatch = a.name().match(/^(.*)-([0-9]+)$/);
  var bMatch = b.name().match(/^(.*)-([0-9]+)$/);
  if (aMatch && bMatch) {
    var first = compareValues(aMatch[1], bMatch[1]);
    if (first != 0) {
      return first;
    }

    return compareValues(parseInt(aMatch[2]), parseInt(bMatch[2]));
  }
  return compareValues(a.name(), b.name());
};

/**
 * @param {Object} json
 * @constructor
 */
function VMDisk(json) {
  /**
   * @type {Object}
   * @private
   */
  this.json_ = json;
}

/**
 * @return {string}
 */
VMDisk.prototype.name = function() {
  return lastComponentOfUri(this.json_.source);
};

/**
 * @param {Object} json
 * @constructor
 */
function VMInstance(json) {
  /**
   * @type {Object}
   * @private
   */
  this.json_ = json;

  /**
   * @type {boolean}
   */
  this.selected = false;
}

/**
 * @return {string}
 */
VMInstance.prototype.name = function() {
  return this.json_.name;
};

/**
 * @return {string}
 */
VMInstance.prototype.zone = function() {
  return lastComponentOfUri(this.json_.zone);
};

/**
 * return {Object}
 */
VMInstance.prototype.networkInterface = function() {
  if (!('networkInterfaces' in this.json_)) {
    return null;
  }
  var networkInterfaces = this.json_.networkInterfaces;
  switch (networkInterfaces.length) {
    case 0: return null;
    case 1: return networkInterfaces[0];
    default: {
      throw (networkInterfaces.length + ' network interfaces');
    }
  }
};

/**
 * @return {Object}
 */
VMInstance.prototype.networkAccessConfig = function() {
  var networkInterface = null;
  try {
    networkInterface = this.networkInterface();
    if (networkInterface == null) {
      return null;
    }
  } catch (e) {
    if (typeof e == 'string') {
      return e;
    }
  }

  if (!('accessConfigs' in networkInterface)) {
    return null;
  }
  var accessConfigs = networkInterface.accessConfigs;
  switch (accessConfigs.length) {
    case 0: return null;
    case 1: return accessConfigs[0];
    default: throw (accessConfigs.length + ' networks');
  }
};

/**
 * TODO(mbrukman): consider returning a higher-level status/error code here and
 * let the caller decide how to render that to a string.
 *
 * @return {string}
 */
VMInstance.prototype.externalIP = function() {
  var accessConfig = null;
  try {
    accessConfig = this.networkAccessConfig();
    if (accessConfig == null) {
      console.log('VMInstance#externalIP(): accessConfig is null');
      return '<error>';
    }
  } catch (e) {
    console.log('VMInstance#externalIP(): exception: ' + e);
    return '<error>';
  }

  if ((typeof accessConfig == 'object') &&
      ('type' in accessConfig) &&
      (accessConfig.type == 'ONE_TO_ONE_NAT') &&
      ('natIP' in accessConfig)) {
    return accessConfig.natIP;
  }

  return '-';
};

/**
 * @return {string}
 */
VMInstance.prototype.networkName = function() {
  var networkInterface = null;
  try {
    networkInterface = this.networkInterface();
    if (networkInterface == null) {
      return '';
    }
  } catch (e) {
    if (typeof e == 'string') {
      return e;
    }
  }

  if ((typeof networkInterface == 'object') &&
      ('network' in networkInterface)) {
    return lastComponentOfUri(networkInterface.network);
  }

  return '';
};

/**
 * @return {string}
 */
VMInstance.prototype.numDisks = function() {
  return this.json_.disks.length;
};

/**
 * @return {VMDisk}
 */
VMInstance.prototype.disk = function(index) {
  return new VMDisk(this.json_.disks[index]);
};

// The various status strings and transitions can be found here:
// https://cloud.google.com/compute/docs/instances/#checkmachinestatus
VMInstance.prototype.isStatusOneOf = function(statuses) {
  if (!('status' in this.json_)) {
    console.log('[error] instance has no "status" field');
    return false;
  }
  // For more info on statuses, see the docs:
  // https://developers.google.com/compute/docs/reference/latest/instances#resource
  for (var i = 0; i < statuses.length; ++i) {
    if (this.json_.status == statuses[i]) {
      return true;
    }
  }
  return false;
};

/**
 * @return {bolean}
 */
VMInstance.prototype.isStarting = function() {
  return this.isStatusOneOf(['PROVISIONING', 'STAGING']);
};

/**
 * @return {bolean}
 */
VMInstance.prototype.isRunning = function() {
  return this.isStatusOneOf(['RUNNING']);
};

/**
 * @return {bolean}
 */
VMInstance.prototype.isStopping = function() {
  return this.isStatusOneOf(['STOPPING']);
};

/**
 * @return {bolean}
 */
VMInstance.prototype.isTerminated = function() {
  return this.isStatusOneOf(['TERMINATED']);
};

consoleControllers.controller('GceInstancesCtrl',
    ['$scope', '$http', '$route', '$routeParams',
    function($scope, $http, $route, $routeParams) {
  $scope.DEBUG = true;

  $scope.project = $routeParams.project;
  $scope.allInstances = [];
  $scope.instancesByZone = {};

  $scope.loadInstances = function(data) {
    var allInstances = [];
    var instancesByZone = {};
    if ('items' in data) {
      for (var zoneUri in data.items) {
        var value = data.items[zoneUri];
        if ('instances' in value) {
          // Format for zoneUri: "zones/<name-of-zone>".
          var zone = zoneUri.split('/')[1];
          if (!(zone in instancesByZone)) {
            instancesByZone[zone] = [];
          }
          for (var i in value.instances) {
            var instance = new VMInstance(value.instances[i]);
            allInstances.push(instance);
            instancesByZone[zone].push(instance);
          }
        }
      }
    }

    allInstances.sort(compareByName);
    for (var instance in allInstances) {
      instance.selected = false;
    }
    $scope.allInstances = allInstances;
    $scope.instancesByZone = instancesByZone;
  };

  $scope.updateInstances = function() {
    $http({
      method: 'GET',
      url: '/compute/v1/projects/' + $scope.project + '/instances/aggregated',
    })
      .success(function(data, status, headers, config) {
        if ($scope.DEBUG) {
          console.log('[instances]');
          console.log(data);
        }

        $scope.loadInstances(data);
      })
      .error(function(data, status, headers, config) {
        if ($scope.DEBUG) {
          console.log('[instances] error: ' + data);
        }
      });

    // TODO: periodic refresh of the data.
    // setInterval($scope.updateInstances, 5000);
  };

  $scope.updateInstances();

  /**
   * @return {boolean}
   */
  $scope.emptyInstanceSelection = function() {
    for (var i = 0; i < $scope.allInstances.length; ++i) {
      var instance = $scope.allInstances[i];
      if (instance.selected) {
        return false;
      }
    }
    return true;
  };

  $scope.applyToInstances = function(action) {
    var instances = [];
    for (var i = 0; i < $scope.allInstances.length; ++i) {
      var instance = $scope.allInstances[i];
      if (instance.selected) {
        instances.push(instance);
      }
    }

    if (instances.length == 0) {
      return;
    }

    var message = "Are you sure you would like to " + action + " "
        + instances.length + " instance" + (instances.length == 1 ? "" : "s") + "?";
    if (!confirm(message)) {
      return;
    }

    for (var i = 0; i < instances.length; ++i) {
      var instance = instances[i];

      $http({
        method: 'POST',
        url: '/compute/v1/projects/' + $scope.project + '/zones/' + instance.zone() + '/instances/' + instance.name() + '/' + action,
      })
        .success(function(data, status, headers, config) {
          setTimeout($scope.updateInstances, 500);
        })
        .error(function(data, status, headers, config) {
          if ($scope.DEBUG) {
            console.log('[' + action + 'Instances()] error')
            console.log(data);
          }
        });
    }
  };

  $scope.startInstances = function() {
    $scope.applyToInstances('start');
  };

  $scope.stopInstances = function() {
    $scope.applyToInstances('stop');
  };

  $scope.deleteInstances = function() {
    $scope.applyToInstances('delete');
  };
}]);

consoleControllers.controller('GceInstanceConsoleCtrl',
    ['$scope', '$http', '$route', '$routeParams',
    function($scope, $http, $route, $routeParams) {

  $scope.project = $routeParams.project;
  $scope.zone = $routeParams.zone;
  $scope.instance = $routeParams.instance;

  $scope.consoleOutput = '';

  $scope.updateConsoleOutput = function() {
    $http({
      method: 'GET',
      url: '/compute/v1/projects/' + $scope.project + '/zones/' + $scope.zone +
          '/instances/' + $scope.instance + '/serialPort',
    })
      .success(function(data, status, headers, config) {
        if ('kind' in data &&
            data.kind == 'compute#serialPortOutput' &&
            'contents' in data) {
          $scope.consoleOutput = data.contents;
        } else {
          $scope.consoleOutput = 'Received unexpected response from server.';
        }
      })
      .error(function(data, status, headers, config) {
        if ($scope.DEBUG) {
          console.log('[consoleOutput] error: ' + data);
        }
      });
  };

  $scope.updateConsoleOutput();
}]);

consoleControllers.controller(
    'ProjectSelectCtrl',
    ['$scope', '$location',
    function($scope, $location) {
  $scope.project = null;

  $scope.visitProject = function() {
    var newPath = '/project/' + $scope.project + '/compute/instances';
    $location.path(newPath).replace();
  };
}]);

consoleControllers.controller(
    'NotFoundCtrl',
    ['$scope', '$http', '$route', '$routeParams', '$location',
    function($scope, $http, $route, $routeParams, $location) {
}]);
