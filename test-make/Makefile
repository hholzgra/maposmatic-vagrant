.DEFAULT_GOAL := all

-include settings.mk

-include .deps.mk

OC_OPT        = --config=$(OC_CONFIG) --bounding-box=$(OC_BBOX) --index=$(OC_INDEX) --language=$(OC_LANG) --orientation=$(OC_ORIENT)
OC_OPT_SINGLE = $(OC_OPT) --paper-format='$(OC_PAPER)' --layout=$(OC_LAYOUT)
OC_OPT_MULTI  = $(OC_OPT) --paper-format='Din A4' --layout="multi_page"

OC_CMD = timeout $(OC_TIMEOUT) /usr/bin/time -q -f "%E" -o $@.time ocitysmap

.PHONY: all
all: .deps.mk $(ALL_STYLES) $(ALL_OVERLAYS)


.PHONY: depend
depend: .deps.mk

.deps.mk: $(OC_CONFIG)
	@./gen-deps.py $(OC_CONFIG) > .deps.mk

clean::
	@rm -f .deps.mk
	@rm -rf styles/* overlays/*

styles/%.png:
	@echo "... building $@"
	@$(OC_CMD) --format=png \
                   --style=$$(basename $@ .png) \
		   --title="$$(basename $@ .png)" \
                   --prefix=styles/$$(basename $@ .png) \
                   $(OC_OPT_SINGLE) > $@.err 2>&1
	@if test -d "$(PREVIEW_DIR)"; then convert -resize  500x355 $@ $(PREVIEW_DIR)/styles/$$(basename $@ .png).jpg; fi
	@if test -d "$(PREVIEW_DIR)"; then convert -resize  750x533 $@ $(PREVIEW_DIR)/styles/$$(basename $@ .png)-1.5x.jpg; fi
	@if test -d "$(PREVIEW_DIR)"; then convert -resize 1000x710 $@ $(PREVIEW_DIR)/styles/$$(basename $@ .png)-2x.jpg; fi

styles/%.pdf:
	@echo "... building $@"
	@$(OC_CMD) --format=pdf \
                   --style=$$(basename $@ .pdf) \
		   --title="$$(basename $@ .pdf)" \
                   --prefix=styles/$$(basename $@ .pdf) \
                   $(OC_OPT_SINGLE) > $@.err 2>&1

styles/%.svgz:
	@echo "... building $@"
	@$(OC_CMD) --format=svgz \
                   --style=$$(basename $@ .svgz) \
		   --title="$$(basename $@ .svgz)" \
                   --prefix=styles/$$(basename $@ .svgz) \
                   $(OC_OPT_SINGLE) > $@.err 2>&1

styles/%.multi.pdf:
	@echo "... building $@"
	@$(OC_CMD) --format=pdf \
                   --style=$$(basename $@ .multi.pdf) \
		   --title="$$(basename $@ .multi.pdf)" \
                   --prefix=styles/$$(basename $@ .pdf) \
                   $(OC_OPT_MULTI) > $@.err 2>&1

overlays/%.png:
	@echo "... building $@"
	@$(OC_CMD) --format=png \
                   --style=$(OC_BASE) \
                   --overlay=$$(basename $@ .png) \
		   --title="$$(basename $@ .png)" \
                   --prefix=overlays/$$(basename $@ .png) \
                   $(OC_OPT_SINGLE) > $@.err 2>&1
	@if test -d "$(PREVIEW_DIR)"; then convert -resize  500x355 $@ $(PREVIEW_DIR)/overlays/$$(basename $@ .png).jpg; fi
	@if test -d "$(PREVIEW_DIR)"; then convert -resize  750x533 $@ $(PREVIEW_DIR)/overlays/$$(basename $@ .png)-1.5x.jpg; fi
	@if test -d "$(PREVIEW_DIR)"; then convert -resize 1000x710 $@ $(PREVIEW_DIR)/overlays/$$(basename $@ .png)-2x.jpg; fi

overlays/%.pdf:
	@echo "... building $@"
	@$(OC_CMD) --format=pdf \
                   --style=$(OC_BASE) \
                   --overlay=$$(basename $@ .pdf) \
		   --title="$$(basename $@ .pdf)" \
                   --prefix=overlays/$$(basename $@ .pdf) \
                   $(OC_OPT_SINGLE) > $@.err 2>&1

overlays/%.svgz:
	@echo "... building $@"
	@$(OC_CMD) --format=svgz \
                   --style=$(OC_BASE) \
                   --overlay=$$(basename $@ .svgz) \
		   --title="$$(basename $@ .svgz)" \
                   --prefix=overlays/$$(basename $@ .svgz) \
                   $(OC_OPT_SINGLE) > $@.err 2>&1

overlays/%.multi.pdf:
	@echo "... building $@"
	@$(OC_CMD) --format=pdf \
                   --style=$(OC_BASE) \
                   --overlay=$$(basename $@ .multi.pdf) \
		   --title="$$(basename $@ .multi.pdf)" \
                   --prefix=overlays/$$(basename $@ .pdf) \
                   $(OC_OPT_MULTI) > $@.err 2>&1
