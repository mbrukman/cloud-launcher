define TARGET_tpl = PACKER.$(1).$(2).out
endef

define SCRIPT_tpl =
$$(PACKER.$(1).$(2).out): $$(PACKER.$(1).$(2).in)
	echo $< > $@
endef

$(foreach script, agent server, $(foreach mode, build start, $(info $(eval $(call SCRIPT_tpl, $(script) $(mode))))))
#$(foreach script, agent server, $(foreach mode, build start, $(warning $(call SCRIPT_tpl, $(script) $(mode)))))

.PHONY: all
ALL = $(foreach script, agent server, $(foreach mode, build start, $(eval $(call TARGET_tpl, $(script) $(mode)))))

all: $(SCRIPT_tpl)
	$(VERB) echo all = $<
