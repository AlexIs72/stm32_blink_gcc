TOOLCHAIN_DIR   =   /opt/gcc-arm-none-eabi-7-2017-q4-major
CROSS_COMPILER  =   $(TOOLCHAIN_DIR)/bin/arm-none-eabi-

GCC             =   $(CROSS_COMPILER)gcc 
AS              =   $(CROSS_COMPILER)gcc

COMMON_FLAGS    =   -mcpu=cortex-m3 -mthumb -Wall
CFLAGS          =   -Os -MD -I src/system -I src/core -I src/perlib/inc
CFLAGS          +=  -DSTM32F10X_MD
DEBUG_FLAGS     =   -g -O0

TARGET          =   stm32_blink

SOURCES         =   src/main.c
SOURCES         +=  $(wildcard src/core/*.c)
SOURCES         +=  $(wildcard src/perlib/*.c)
SOURCES         +=  $(wildcard src/system/*c)
STARTUP         =   $(wildcard src/startup/*.s)

OBJECTS         =   $(SOURCES:.c=.o)
OBJECTS         +=  $(STARTUP:.s=.o)

DEPS            =   $(OBJECTS:.o=.d)

LINKER_SCRIPT   =   src/stm32_flash.ld


all: $(TARGET)

$(TARGET): $(OBJECTS)
	echo "====> Do link"

%.o: %.c
	$(GCC) $(COMMON_FLAGS) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(COMMON_FLAGS) -c $< -o $@


clean:
	rm -f $(OBJECTS)


-include $(DEPS)
