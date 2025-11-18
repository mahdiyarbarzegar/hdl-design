export PRJ_ROOT := $(abspath $(CURDIR))
export PRJ_BUILD := $(PRJ_ROOT)/build
export PRJ_SRC := $(PRJ_ROOT)/src
export PRJ_UTILITY := $(PRJ_ROOT)/utility
export LIB_NAME := "lib_hdl"
export PRJ_LIB_PATH := $(PRJ_BUILD)/$(LIB_NAME)
MODELSIM_INI := $(PRJ_BUILD)/modelsim.ini
export MODELSIM = $(abspath $(MODELSIM_INI))
PRJ_LIST := $(notdir $(wildcard $(PRJ_SRC)/*))

.PHONY: help
help:
	@echo ""
	@echo "HDL Design Make System"
	@echo "========================"
	@echo ""
	@echo "Build Commands:"
	@echo "  make all            		- build all projects"
	@echo "  make <proj>         		- build a specific project"
	@echo "  make compile PROJECT=x  	- build project x"
	@echo ""
	@echo "Run Simulation:"
	@echo "  make run PROJECT=x      	- run x in CLI mode"
	@echo "  make run-gui PROJECT=x  	- run x in GUI mode"
	@echo "  make <proj>-run         	- same (pattern rule)"
	@echo "  make <proj>-gui         	- run GUI (pattern rule)"
	@echo ""
	@echo "Utility:"
	@echo "  make config 				- config the project"
	@echo "  make clean  				- clean all builds"
	@echo "  make list   				- list all projects"

.PHONY: config
config:
	@echo "[CONFIG] Creating modelsim.ini..."
	@mkdir -p $(PRJ_BUILD)
	@cd $(PRJ_BUILD) && vmap -c
	@echo "[CONFIG] Creating library..."
	@cd $(PRJ_BUILD) && vlib $(LIB_NAME)
	vmap $(LIB_NAME) $(PRJ_LIB_PATH)

.PHONY: clean
clean:
	@echo "Cleaning build directory..."
	@rm -rf $(PRJ_BUILD)

.PHONY: list
list:
	@echo "Available HDL projects:"
	@for p in $(PRJ_LIST); do echo "  - $$p"; done

.PHONY: all
all: $(PRJ_LIST)

.PHONY: compile
compile:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: use make compile PROJECT=<name>"; exit 1; \
	fi
	$(MAKE) -C src/$(PROJECT) compile

$(PRJ_LIST):
	@echo "=== Building $@ ==="
	$(MAKE) -C src/$@ compile

.PHONY: run
run:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: use make run PROJECT=<name>"; exit 1; \
	fi
	$(MAKE) -C src/$(PROJECT) run

.PHONY: run-gui
run-gui:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: use make run-gui PROJECT=<name>"; exit 1; \
	fi
	$(MAKE) -C src/$(PROJECT) run-gui

%-run:
	$(MAKE) -C src/$* run

%-gui:
	$(MAKE) -C src/$* run-gui