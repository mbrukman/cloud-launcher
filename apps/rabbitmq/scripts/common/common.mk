# Note: if you're using a disk > 10GB, add
#   ../../../../common/fdisk.sh
# as the first list of the scripts in `SCRIPTS_IN`.

CREATE_COOKIE = create_cookie.sh

SCRIPTS_IN = \
  $(CREATE_COOKIE) \
  $(INSTALL) \
  $(LEVEL)/common/start.sh \

SCRIPT_OUT = rabbitmq.gen.sh

MAKEFILE_DEPS = \
  $(LEVEL)/common/common.mk \
  Makefile

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

DEBUG = @ true
ifeq ($(VERBOSE),1)
	DEBUG = @
endif

default: $(SCRIPT_OUT)

clean:
	$(VERB) rm -f $(CREATE_COOKIE) $(SCRIPT_OUT)

RABBITMQ_RANDOM := $(shell head -c 256 /dev/urandom | md5)
RABBITMQ_COOKIE = "/var/lib/rabbitmq/.erlang.cookie"

$(CREATE_COOKIE): $(MAKEFILE_DEPS)
	$(VERB) echo "mkdir -p /var/lib/rabbitmq" > $@
	$(VERB) echo "echo '$(RABBITMQ_RANDOM)' > $(RABBITMQ_COOKIE)" >> $@
	$(VERB) echo "chmod 400 $(RABBITMQ_COOKIE)" >> $@

$(SCRIPT_OUT): $(SCRIPTS_IN) $(MAKEFILE_DEPS)
	$(VERB) cat $(SCRIPTS_IN) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Output script:"
	$(DEBUG) cat $@
