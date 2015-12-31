genrule(
    name = "compute_api_gen",
    srcs = ["compute_api.yaml"],
    outs = ["compute_api_gen.py"],
    cmd = "$(location compute_api.py) $(location compute_api.yaml) > \"$@\"",
    tools = ["compute_api.py"],
)

filegroup(
    name = "client_secrets",
    srcs = ["client_secrets.json"],
)

# TODO(mbrukman): add dependency on oauth2client
py_library(
    name = "oauth2helper",
    srcs = ["oauth2helper.py"],
    deps = [
        ":safe_memcache",
    ],
    data = [
        ":client_secrets"
    ],
)

# TODO(mbrukman): add dependency on google.appengine.api
py_library(
    name = "safe_memcache",
    srcs = ["safe_memcache.py"],
    deps = [],
)

py_library(
    name = "compute_api_base",
    srcs = ["compute_api_base.py"],
    deps = [
        ":oauth2helper",
        ":safe_memcache",
    ],
)

# This test doesn't quite work yet because our dependency on the Google Cloud
# SDK is implicit: it exists outside of this tree and is referenced via
# "$HOME/google-cloud-sdk", which doesn't work well with Bazel, which wants
# everything to be hermetic: even $HOME is not available there.
py_test(
    name = "compute_api_base_test",
    srcs = ["compute_api_base_test.py"],
    deps = [":compute_api_base"],
    size = "small",
    timeout = "short",
)
