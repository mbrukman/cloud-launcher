# Note: if you're using a disk > 10GB, add
#   ../../../../common/fdisk.sh
# as the first list of the scripts in `SCRIPTS_IN`.

SCRIPTS_IN = \
  install-postfix.sh \
  install-gitlab.sh
SCRIPT_OUT = install-gitlab.gen.sh

VERB = @
ifeq ($(VERBOSE),1)
	VERB =
endif

DEBUG = @ true
ifeq ($(VERBOSE),1)
	DEBUG = @
endif

all: script-gen

clean:
	$(VERB) rm -f $(SCRIPT_OUT)

script-gen: $(SCRIPT_OUT)

$(SCRIPT_OUT): $(SCRIPTS_IN) Makefile
	$(VERB) cat $(SCRIPTS_IN) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Output script:"
	$(DEBUG) cat $@
