BIN := $(HOME)/.local/bin
SRC := $(CURDIR)/bb
NAMES := $(basename $(notdir $(wildcard $(SRC)/*.clj)))

.PHONY: install uninstall list

install:
	@mkdir -p $(BIN)
	@for n in $(NAMES); do \
		install -m 755 "$(SRC)/$$n.clj" "$(BIN)/$$n"; \
		echo "installed $$n"; \
	done

uninstall:
	@for n in $(NAMES); do \
		rm -f "$(BIN)/$$n"; \
		echo "removed $$n"; \
	done

list:
	@echo $(NAMES)
