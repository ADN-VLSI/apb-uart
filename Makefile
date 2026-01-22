######################################################################################################
# Variables
######################################################################################################

TOP_MODULE := apb_uart_tb
GUI := 0
TEST := base_test
VRB := UVM_LOW

ifeq ($(GUI), 1)
	XSIM_ARGS += -gui
else
	XSIM_ARGS += -runall
endif

XSIM_ARGS += --testplusarg "UVM_TESTNAME=$(TEST)"
XSIM_ARGS += --testplusarg "UVM_VERBOSITY=$(VRB)"

####################################################################################################
# Directory Setup
####################################################################################################

ROOT_DIR  := ${CURDIR}
BUILD_DIR := ${ROOT_DIR}/build
LOG_DIR   := ${ROOT_DIR}/log
COV_DIR   := ${ROOT_DIR}/cov
INC_DIR   := ${ROOT_DIR}/inc
PKG_DIR   := ${ROOT_DIR}/pkg
RTL_DIR   := ${ROOT_DIR}/rtl
INTF_DIR  := ${ROOT_DIR}/intf
TB_DIR    := ${ROOT_DIR}/tb

####################################################################################################
# File Setup
####################################################################################################

FILE_LIST += -i ${INC_DIR}
FILE_LIST += -i ${TB_DIR}/include
FILE_LIST += -L uvm
FILE_LIST += ${PKG_DIR}/apb_uart_pkg.sv
FILE_LIST += ${PKG_DIR}/uart_tx_pkg.sv
FILE_LIST += ${PKG_DIR}/uart_rx_pkg.sv
FILE_LIST += $(INC_DIR)/common_defines.svh
FILE_LIST += $(shell find ${INTF_DIR}/ -name "*.sv")
FILE_LIST += $(shell find ${RTL_DIR}/ -name "*.sv")
FILE_LIST += ${TB_DIR}/apb_uart_sanity_check_tb.sv
FILE_LIST += ${TB_DIR}/apb_uart_tb.sv
	
####################################################################################################
# Tool Setup
####################################################################################################

XVLOG ?= xvlog
XVHDL ?= xvhdl
XELAB ?= xelab
XSIM  ?= xsim
XCRG  ?= xcrg

#####################################################################################################
# Commands
#####################################################################################################

HL_EW := | grep -iE "error:|warning:|" --color=auto

#####################################################################################################
# Targets
#####################################################################################################

${BUILD_DIR}:
	@echo "Creating build directory at ${BUILD_DIR}"
	@mkdir -p ${BUILD_DIR}
	@echo "*" > ${BUILD_DIR}/.gitignore

${LOG_DIR}:
	@echo "Creating log directory at ${LOG_DIR}"
	@mkdir -p ${LOG_DIR}
	@echo "*" > ${LOG_DIR}/.gitignore

${COV_DIR}:
	@echo "Creating log directory at ${COV_DIR}"
	@mkdir -p ${COV_DIR}
	@echo "*" > ${COV_DIR}/.gitignore

.PHONY: clean
clean:
	@echo "Cleaning build directory at ${BUILD_DIR}"
	@rm -rf ${BUILD_DIR}

.PHONY: clean_full
clean_full:
	@make -s clean
	@echo "Cleaning log directory at ${LOG_DIR}"
	@rm -rf ${LOG_DIR}
	@echo "Cleaning log directory at ${COV_DIR}"
	@rm -rf ${COV_DIR}

.PHONY: tools_chain
tools_chain:
	@echo "XVLOG := ${XVLOG}"
	@echo "XVHDL := ${XVHDL}"
	@echo "XELAB := ${XELAB}"
	@echo "XSIM  := ${XSIM}"

.PHONY: compile
compile:
	@make -s clean
	@make -s ${BUILD_DIR}
	@make -s ${LOG_DIR}
	@$(eval TIME := $(shell date +%Y%m%d_%H%M%S))
	@cd ${BUILD_DIR} && ${XVLOG} -sv ${FILE_LIST} --log ${LOG_DIR}/xvlog.log ${HL_EW}
	@cd ${BUILD_DIR} && ${XELAB} ${TOP_MODULE} -s ${TOP_MODULE} --log ${LOG_DIR}/xelab.log ${HL_EW}
	@echo "" > ${BUILD_DIR}/compile_done
	
${BUILD_DIR}/compile_done:
	@make -s compile

.PHONY: simulate
simulate:
	@make -s ${BUILD_DIR}
	@make -s ${BUILD_DIR}/compile_done
	@echo "${XSIM_ARGS}" > ${BUILD_DIR}/xsim_args
	@cd ${BUILD_DIR} && ${XSIM} ${TOP_MODULE} -f xsim_args --log ${LOG_DIR}/xsim_${TEST}.log --cov_db_name ${TEST} ${HL_EW}
	@make -s ${COV_DIR}
	@cd ${BUILD_DIR} && ${XCRG} -report_format html --cov_db_name ${TEST} --log ${LOG_DIR}/xcrg_${TEST}.log
	@rm -rf ${COV_DIR}/${TEST}_fc
	@mv ${BUILD_DIR}/xsim_coverage_report/functionalCoverageReport ${COV_DIR}/${TEST}_fc

.PHONY: all
all:
	@make -s clean_full
	@make -s compile
	@make -s all_tests
	@make -s all_reports

.PHONY: all_reports
all_reports:
	@cd ${BUILD_DIR} && ${XCRG} $(shell ls ${BUILD_DIR}/xsim.covdb | sed "s/^/ --cov_db_name /g") --log ${LOG_DIR}/xcrg_all.log
	@rm -rf ${COV_DIR}/all_fc
	@mv ${BUILD_DIR}/xsim_coverage_report/functionalCoverageReport ${COV_DIR}/all_fc

.PHONY: all_tests
all_tests:
	@make -s simulate TEST=base_test
	@make -s simulate TEST=basic_read_test
	@make -s simulate TEST=basic_write_test
	@make -s simulate TEST=all_reg_access_test
