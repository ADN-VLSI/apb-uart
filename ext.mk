HAS_SUBMODULES = 1

export APB_UART=$(CURDIR)
export REPO_NAME_EXP=APB_UART

export ADN_COMMON=$(REPO_ROOT)/submodule/adn_common
export ADN_APB=$(REPO_ROOT)/submodule/adn_apb
export ADN_CLK_RST=$(REPO_ROOT)/submodule/adn_clk_rst
export ADN_UART=$(REPO_ROOT)/submodule/adn_uart

UVM_INCLUDE := $(shell dirname $$(dirname $$(command -v xvlog)))/data/xsim/system_verilog/uvm_include
XVLOG ?= xvlog -L uvm -i $(UVM_INCLUDE) -i $(REPO_ROOT)/uvm
XELAB ?= xelab -L uvm

.PHONY: compile_all_submodules
compile_all_submodules:
	@make -s compile_submodule SUB=adn_common
	@make -s compile_submodule SUB=adn_apb
	@make -s compile_submodule SUB=adn_clk_rst
	@make -s compile_submodule SUB=adn_uart
