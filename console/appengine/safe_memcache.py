#!/usr/bin/python
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

"""
A "best-effort" wrapper around the standard Google App Engine memcache module
that silently ignores exceptions on values greater than 1MB such that:

* it does not require a try/except block around every use
* it can be used in libraries which don't handle this case and hence break
"""

from google.appengine.api import memcache


# Forward all the standard functions.
set_servers = memcache.set_servers
disconnect_all = memcache.disconnect_all
forget_dead_hosts = memcache.forget_dead_hosts
debuglog = memcache.debuglog
get = memcache.get
get_multi = memcache.get_multi


def set(key, value, time=0, min_compress_len=0, namespace=None):
    """Wrapper for memcache.set() to gracefully handle values of arbitrary size.

    This function is a silent no-op for values greater than the App Engine
    Memcache limit (1MB); for all other values it forwards the call to
    memcache.set().
    """
    if len(value) > memcache.MAX_VALUE_SIZE:
        return
    memcache.set(key, value, time, min_compress_len, namespace)


# More forwarding functions.
set_multi = memcache.set_multi
add = memcache.add
add_multi = memcache.add_multi
replace = memcache.replace
replace_multi = memcache.replace_multi
delete = memcache.delete
delete_multi = memcache.delete_multi
incr = memcache.incr
decr = memcache.decr
flush_all = memcache.flush_all
get_stats = memcache.get_stats
offset_multi = memcache.offset_multi
