######################################################################
#  Makefile adapted from Warren Gay and libopencm3 project.
#
#  https://github.com/ve3wwg/stm32f103c8t6
#  https://github.com/libopencm3/libopencm3-template
######################################################################

PREFIX		?= arm-none-eabi

OPENCM3_DIR 	:= $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/libopencm3)

DEFS		+= -DSTM32F1

# Redefine to the name of your project.
BINARY      =  myproject
SOURCE_DIR  =  myproject
OBJ_DIR     =  obj
BINARY_DIR   ?= bin
SRCFILES    =  $(shell find $(SOURCE_DIR) -name "*.c")
SRCFILES    +=  $(shell find $(SOURCE_DIR) -name "*.cpp")
SRCFILES    +=  $(shell find $(SOURCE_DIR) -name "*.asm")

FP_FLAGS	?= -msoft-float
ARCH_FLAGS	= -mthumb -mcpu=cortex-m3 $(FP_FLAGS) -mfix-cortex-m3-ldrd
ASFLAGS		= -mthumb -mcpu=cortex-m3

CC		:= $(PREFIX)-gcc
CXX		:= $(PREFIX)-g++
LD		:= $(PREFIX)-gcc
AR		:= $(PREFIX)-ar
AS		:= $(PREFIX)-as
OBJCOPY		:= $(PREFIX)-objcopy
SIZE		:= $(PREFIX)-size
OBJDUMP		:= $(PREFIX)-objdump
GDB		:= $(PREFIX)-gdb
STFLASH		= $(shell which st-flash)
OPT		:= -Os -g
CSTD		?= -std=c99

TEMP1 		= $(patsubst $(SOURCE_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCFILES))
TEMP2		= $(patsubst $(SOURCE_DIR)/%.asm,$(OBJ_DIR)/%.o,$(TEMP1))
OBJS 		= $(patsubst $(SOURCE_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(TEMP2))

LDSCRIPT	?= stm32f103c8t6.ld

TGT_CFLAGS	+= $(OPT) $(CSTD)
TGT_CFLAGS	+= $(ARCH_FLAGS)
TGT_CFLAGS	+= -Wextra -Wshadow -Wimplicit-function-declaration
TGT_CFLAGS	+= -Wredundant-decls -Wmissing-prototypes -Wstrict-prototypes
TGT_CFLAGS	+= -fno-common -ffunction-sections -fdata-sections
TGT_CFLAGS	+= -I$(OPENCM3_DIR)/include

TGT_CXXFLAGS	+= $(OPT) $(CXXSTD)
TGT_CXXFLAGS	+= $(ARCH_FLAGS)
TGT_CXXFLAGS	+= -Wextra -Wshadow -Wredundant-decls  -Weffc++
TGT_CXXFLAGS	+= -fno-common -ffunction-sections -fdata-sections

TGT_CPPFLAGS	+= -MD
TGT_CPPFLAGS	+= -Wall -Wundef
TGT_CPPFLAGS	+= $(DEFS)
TGT_CPPFLAGS	+= -I$(OPENCM3_DIR)/include

TGT_LDFLAGS	+= --static -nostartfiles
TGT_LDFLAGS	+= -T$(LDSCRIPT)
TGT_LDFLAGS	+= $(ARCH_FLAGS)
TGT_LDFLAGS	+= -Wl,-Map=$(BINARY_DIR)/$(BINARY).map
TGT_LDFLAGS	+= -Wl,--gc-sections

LDLIBS		+= -specs=nosys.specs
LDLIBS		+= -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group
LDLIBS		+= -L$(OPENCM3_DIR)/lib -lopencm3_stm32f1

.SUFFIXES:	.elf .bin .hex .srec .list .map 
.SECONDEXPANSION:
.SECONDARY:

all:    libopencm3 elf
elf:    $(BINARY_DIR)/$(BINARY).elf
bin:	$(BINARY_DIR)/$(BINARY).bin
hex:	$(BINARY_DIR)/$(BINARY).hex
srec:	$(BINARY_DIR)/$(BINARY).srec
list:	$(BINARY_DIR)/$(BINARY).list

%.bin: %.elf
	$(OBJCOPY) -Obinary $(*).elf $(*).bin

%.hex: %.elf
	$(OBJCOPY) -Oihex $(*).elf $(*).hex

%.srec: %.elf
	$(OBJCOPY) -Osrec $(*).elf $(*).srec

%.list: %.elf
	$(OBJDUMP) -S $(*).elf > $(*).list

%.elf %.map: $(OBJS) $(LDSCRIPT) libopencm3
	mkdir -p $(BINARY_DIR)
	$(LD) $(TGT_LDFLAGS) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(*).elf
	$(SIZE) $(*).elf

# Only build libopencm3 for the stm32f1 platform.
libopencm3: libopencm3/lib/libopencm3_stm32f1.a

libopencm3/lib/libopencm3_stm32f1.a:
	$(MAKE) -C libopencm3 TARGETS=stm32/f1

$(OBJ_DIR)/%.o: $(SOURCE_DIR)/%.c
	mkdir -p $(@D)
	$(CC) $(TGT_CFLAGS) $(CFLAGS) $(TGT_CPPFLAGS) $(CPPFLAGS) -o $@ -c $^

$(OBJ_DIR)/%.o: $(SOURCE_DIR)/%.cxx
	mkdir -p $(@D)
	$(CXX) $(TGT_CXXFLAGS) $(CXXFLAGS) $(TGT_CPPFLAGS) $(CPPFLAGS) -o $@ -c $^

$(OBJ_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	mkdir -p $(@D)
	$(CXX) $(TGT_CXXFLAGS) $(CXXFLAGS) $(TGT_CPPFLAGS) $(CPPFLAGS) -o $@ -c $^

$(OBJ_DIR)/%.o: $(SOURCE_DIR)/%.asm
	mkdir -p $(@D)
	$(AS) $(ASFLAGS) -o $@.o -c $<

clean:
	rm -vrf $(OBJ_DIR) $(BINARY_DIR)
	$(MAKE) -C libopencm3 clean

# Flash 64k Device
flash:	$(BINARY_DIR)/$(BINARY).bin
	$(STFLASH) $(FLASHSIZE) write $^ 0x8000000

# Flash 128k Device
bigflash:	$(BINARY_DIR)/$(BINARY).bin
	$(STFLASH) --flash=128k $(FLASHSIZE) write $^ 0x8000000

.PHONY: clean elf bin hex srec list all libopencm3

-include $(OBJS:.o=.d)

# End
