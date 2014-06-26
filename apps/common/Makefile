SH_TESTS = $(wildcard *_test.sh)

VERB = @

default:
	$(VERB) echo "Valid targets: test"

test:
	$(VERB) for test in $(SH_TESTS); do \
	  echo "Testing $$test ..."; \
	  bash $$test; \
	done
	$(VERB) echo "Done."
