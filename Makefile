#TOOLCHAIN_DIR   =   /opt/gcc-arm-none-eabi-7-2017-q4-major
TOOLCHAIN_DIR   =   /opt/gcc-arm-none-eabi-7-2018-q2-update
CROSS_COMPILER  =   $(TOOLCHAIN_DIR)/bin/arm-none-eabi-

CWD				=	$(shell pwd)

GCC             =   $(CROSS_COMPILER)gcc 
AS              =   $(CROSS_COMPILER)gcc
OBJCOPY			= 	$(CROSS_COMPILER)objcopy
OBJDUMP			= 	$(CROSS_COMPILER)objdump

INCLUDES += .
INCLUDES += src/system 
INCLUDES += src/core
INCLUDES += src/perlib/inc


COMMON_FLAGS    =   -mcpu=cortex-m3 -mlittle-endian -mthumb -Wall
CFLAGS          =   -Os -MD -fno-builtin
CFLAGS          +=  -DSTM32F10X_MD  -DUSE_STDPERIPH_DRIVER 
CFLAGS 			+= 	-std=gnu99 # стандарт языка С
CFLAGS 			+= 	-Wno-comment -Wall -pedantic  # Выводить все предупреждения
CFLAGS 			+= 	$(addprefix -I, $(INCLUDES))
DEBUG_FLAGS     =   -ggdb -O0

LD_FLAGS		= 	-T$(LINKER_SCRIPT) 
LD_FLAGS		+=	--static -nostartfiles -fno-exceptions
LD_FLAGS		+=	-Wl,--gc-sections 
LD_FLAGS		+= 	-Wl,-Map=$(*).map
LD_FLAGS		+= 	-Xlinker -Map=$(TARGET_MAP)

ASM_FLAGS		=	-D__START=main
#-ahls -mapcs-32

TARGET_DIR		=	bin
TARGET          =   stm32_blink
TARGET_ELF		=	$(TARGET_DIR)/$(TARGET).elf
TARGET_HEX		=	$(TARGET_DIR)/$(TARGET).hex
TARGET_LST		=	$(TARGET_DIR)/$(TARGET).lst
TARGET_MAP		=	$(TARGET_DIR)/$(TARGET).map
TARGET_BIN		=	$(TARGET_DIR)/$(TARGET).bin

SOURCES         =   src/main.c
SOURCES         +=  $(wildcard src/core/*.c)
SOURCES         +=  $(wildcard src/perlib/src/*.c)
SOURCES         +=  $(wildcard src/system/*c)
STARTUP         =   src/startup/startup_ARMCM3.S
#STARTUP         =   src/startup/startup_stm32f10x_md.s

OBJECTS         =  	$(STARTUP:.S=.o)
#OBJECTS         =  	$(STARTUP:.s=.o)
OBJECTS         +=  $(SOURCES:.c=.o)

DEPS            =   $(OBJECTS:.o=.d)

LINKER_SCRIPT   =   src/gcc.ld
#LINKER_SCRIPT   =   src/stm32_flash.ld
#LINKER_SCRIPT   =   src/stm32f103c8_flash.ld 


all: $(TARGET_DIR) $(TARGET_HEX) $(TARGET_BIN) 

$(TARGET_DIR):
	mkdir -p $(TARGET_DIR)

$(TARGET_BIN):	$(TARGET_ELF)
	$(OBJCOPY) -Obinary $(TARGET_ELF) $(TARGET_BIN)

$(TARGET_HEX):	$(TARGET_ELF)
	$(OBJCOPY) -Oihex $(TARGET_ELF) $(TARGET_HEX)

$(TARGET_ELF): $(OBJECTS)
	$(GCC) $(COMMON_FLAGS) $(LD_FLAGS) $^ -o $@
	$(OBJDUMP) -S $@ > $(TARGET_LST)

$(OBJECTS): $(SOURCES) $(STARTUP)

%.o: %.c
	$(GCC) $(COMMON_FLAGS) $(CFLAGS) -c $< -o $@

%.o: %.S 
	$(AS) $(COMMON_FLAGS) $(ASM_FLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(COMMON_FLAGS) $(ASM_FLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(DEPS) $(TARGET_ELF) $(TARGET_HEX) $(TARGET_LST) $(TARGET_MAP) $(TARGET_BIN)


-include $(DEPS)
