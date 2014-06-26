AMBARI_AGENT_INPUTS = \
  ../../../../../common/fdisk.sh \
  ambari-repo-init.sh \
  ambari-agent-install.sh \
  ambari-agent-setup.sh \
  ambari-agent-start.sh
AMBARI_AGENT_OUTPUT = ambari-agent-init.gen.sh

AMBARI_SERVER_INPUTS = \
  ambari-repo-init.sh \
  ambari-server-install.sh \
  ambari-server-setup.sh \
  ambari-server-start.sh
AMBARI_SERVER_OUTPUT = ambari-server-init.gen.sh

VERB = @
ifeq (VERBOSE,1)
	VERB =
endif

DEBUG = @ true
ifeq (DEBUGGING,1)
	DEBUG = @
endif

all: ambari-agent ambari-server

clean:
	$(VERB) rm -f $(AMBARI_AGENT_OUTPUT) $(AMBARI_SERVER_OUTPUT)

ambari-agent: $(AMBARI_AGENT_OUTPUT)

$(AMBARI_AGENT_OUTPUT): $(AMBARI_AGENT_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Agent input scripts: $(AMBARI_AGENT_INPUTS)"
	$(VERB) cat $(AMBARI_AGENT_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Agent output script:"
	$(DEBUG) cat $@

ambari-server: $(AMBARI_SERVER_OUTPUT)

$(AMBARI_SERVER_OUTPUT): $(AMBARI_SERVER_INPUTS) Makefile
	$(DEBUG) echo "***************************"
	$(DEBUG) echo "Server input scripts: $(AMBARI_SERVER_INPUTS)"
	$(VERB) cat $(AMBARI_SERVER_INPUTS) | sed '/^[[:space:]]*#/d' > $@
	$(DEBUG) echo "Server output script:"
	$(DEBUG) cat $@
