DESIGN_NAME := pwm-generator
INC_DIRS := $(realpath inc/)
INC_FILES := $(realpath $(wildcard inc/*.vh))
HDL_FILES := $(realpath $(wildcard hdl/*.v) $(wildcard hdl/*.sv))
TB_FILES := $(realpath $(wildcard sim/*.v))
TOP_TB :=
TOP_GUI := gui_pwm_generator
WAVE_GUI := $(realpath $(wildcard sim/wave.do))
XSIM_WAVE_GUI := $(realpath $(wildcard sim/wave.wcfg))
DEPS :=
MODELSIM_COMPILE_OPTIONS := \
	-sv \
	+incdir+$(INC_DIRS)
XSIM_COMPILE_OPTIONS := \
	--include $(INC_DIRS) \
	-sv
XSIM_ELABORATE_OPTIONS := \
	--include $(INC_DIRS)

include $(PRJ_UTILITY)/Makefile.common
