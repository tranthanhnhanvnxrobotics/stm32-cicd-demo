##########################################################
# Makefile for STM32F407VGTX
##########################################################

TARGET = CICD

# Build directory
BUILD_DIR = Debug

# Toolchain
PREFIX = arm-none-eabi-
CC      = $(PREFIX)gcc
AS      = $(PREFIX)gcc -x assembler-with-cpp
CP      = $(PREFIX)objcopy
SZ      = $(PREFIX)size
HEX     = $(CP) -O ihex
BIN     = $(CP) -O binary -S

######################################
# C Sources
######################################
C_SOURCES = \
Core/Src/main.c \
Core/Src/stm32f4xx_hal_msp.c \
Core/Src/stm32f4xx_it.c \
Core/Src/syscalls.c \
Core/Src/sysmem.c \
Core/Src/system_stm32f4xx.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c

######################################
# ASM Sources
######################################
ASM_SOURCES = Core/Startup/startup_stm32f407vgtx.s

######################################
# C Includes
######################################
C_INCLUDES = \
-ICore/Inc \
-IDrivers/STM32F4xx_HAL_Driver/Inc \
-IDrivers/STM32F4xx_HAL_Driver/Inc/Legacy \
-IDrivers/CMSIS/Device/ST/STM32F4xx/Include \
-IDrivers/CMSIS/Include

######################################
# C Defines
######################################
C_DEFS = \
-DUSE_HAL_DRIVER \
-DSTM32F407xx

######################################
# CPU / FPU flags
######################################
CPU    = -mcpu=cortex-m4
FPU    = -mfpu=fpv4-sp-d16
FLOAT  = -mfloat-abi=hard
MCU    = $(CPU) -mthumb $(FPU) $(FLOAT)

######################################
# Compile flags
######################################
CFLAGS  = $(MCU) $(C_DEFS) $(C_INCLUDES) -O0 -Wall -fdata-sections -ffunction-sections -g -gdwarf-2
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) -Wall -fdata-sections -ffunction-sections

######################################
# Linker
######################################
LDSCRIPT = STM32F407VGTX_FLASH.ld
LIBS     = -lc -lm -lnosys
LIBDIR   =
LDFLAGS  = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) \
           -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

######################################
# Build rules
######################################
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

# Object files list
OBJECTS  = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

# Compile C
$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

# Compile ASM
$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(ASFLAGS) $< -o $@

# Link
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

# Generate HEX & BIN
$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(BIN) $< $@

# Create build dir
$(BUILD_DIR):
	mkdir -p $@

# Clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean