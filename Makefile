#TOOLCHAIN_DIR   =   /opt/gcc-arm-none-eabi-7-2017-q4-major
TOOLCHAIN_DIR   =   /opt/gcc-arm-none-eabi-7-2018-q2-update
CROSS_COMPILER  =   $(TOOLCHAIN_DIR)/bin/arm-none-eabi-

CWD				=	$(shell pwd)

GCC             =   $(CROSS_COMPILER)gcc 
AS              =   $(CROSS_COMPILER)gcc
OBJCOPY			= 	$(CROSS_COMPILER)objcopy

COMMON_FLAGS    =   -mcpu=cortex-m3 -mlittle-endian -mthumb -Wall
CFLAGS          =   -Os -MD -I$(CWD)/src/system -I$(CWD)/src/core -I$(CWD)/src/perlib/inc
CFLAGS          +=  -DSTM32F10X_MD  -DUSE_STDPERIPH_DRIVER
DEBUG_FLAGS     =   -g -O0

LD_FLAGS		= 	-T$(LINKER_SCRIPT) -Wl,--gc-sections 

TARGET          =   stm32_blink
TARGET_HEX		=	$(TARGET).hex

SOURCES         =   src/main.c
SOURCES         +=  $(wildcard src/core/*.c)
SOURCES         +=  $(wildcard src/perlib/src/*.c)
SOURCES         +=  $(wildcard src/system/*c)
STARTUP         =   $(wildcard src/startup/*.s)

OBJECTS         =   $(SOURCES:.c=.o)
OBJECTS         +=  $(STARTUP:.s=.o)

DEPS            =   $(OBJECTS:.o=.d)

LINKER_SCRIPT   =   src/stm32_flash.ld


all: $(TARGET_HEX)

$(TARGET_HEX):	$(TARGET)
	$(OBJCOPY) -Oihex $(TARGET) $(TARGET_HEX)

$(TARGET): $(OBJECTS)
	$(GCC) $(COMMON_FLAGS) $(LD_FLAGS) $^ -o $@

%.o: %.c
	$(GCC) $(COMMON_FLAGS) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(COMMON_FLAGS) -c $< -o $@


clean:
	rm -f $(OBJECTS) $(DEPS)


-include $(DEPS)
