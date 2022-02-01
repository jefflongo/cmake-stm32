MAIN_TARGET = blinky-l412

WARNINGS = \
	-Werror=all \
	-Werror=extra \
	-Werror=pedantic \
	-Wfatal-errors \
	-Wno-unused-parameter # thanks, ST...

GCC_PREFIX = arm-none-eabi-
CPU = -mcpu=cortex-m4
FPU = -mfpu=fpv4-sp-d16
FLOAT_ABI = -mfloat-abi=hard

# TODO: if you change these, you probably need `make clean` before building
DEBUG = 1
PROFILING = 0

OPT = -Og

LIBS = -lc -lm -lnosys
LD_SCRIPT = src/stm32l412.ld

DEFS = STM32L412xx USE_FULL_LL_DRIVER

SOURCES = \
	src/app \
	src/board/stm32l412 \
	STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/gcc/startup_stm32l412xx.s \
	STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c \
	STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_gpio.c \
	STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_pwr.c \
	STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_rcc.c \
	STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_utils.c \


INC_DIRS = \
	src/board/common/include \
	STM32CubeL4/Drivers/CMSIS/Core/Include \
	STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include \
	STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Inc \

BUILD_DIR ?= build/$(MAIN_TARGET)

# try to keep the rest of this more-or-less project independent:

CC = $(GCC_PREFIX)gcc
AS = $(GCC_PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PREFIX)objcopy
SZ = $(GCC_PREFIX)size

SRCS := $(shell find $(SOURCES) -name '*.[cs]' -print)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

MCU = $(CPU) -mthumb $(FPU) $(FLOAT_ABI)
INCLUDES := $(addprefix -I,$(INC_DIRS))
DEFS := $(addprefix -D,$(DEFS))
OPT ?=

AS_DEFS ?= $(DEFS)
AS_INC_DIRS ?= 
AS_INCLUDES := $(addprefix -I,$(AS_INC_DIRS)) $(INCLUDES)
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) $(WARNINGS) -fdata-sections -ffunction-sections

C_DEFS ?= $(DEFS)
C_INC_DIRS ?=
C_INCLUDES := $(addprefix -I,$(C_INC_DIRS)) $(INCLUDES)
CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) $(WARNINGS) -fdata-sections -ffunction-sections
CFLAGS += -MMD -MP

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif

LIB_DIRS ?= 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LD_SCRIPT) $(LIB_DIRS) $(LIBS) \
	-Wl,-Map=$(BUILD_DIR)/$(MAIN_TARGET).map,--cref -Wl,--gc-sections

MKDIR_P ?= mkdir -p

$(BUILD_DIR)/$(MAIN_TARGET).elf: $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)
	$(SZ) $@

$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

-include $(DEPS)
