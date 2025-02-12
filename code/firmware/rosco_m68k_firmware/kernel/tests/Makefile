ROSCO_M68K_DIR=../../../../..

-include $(ROSCO_M68K_DIR)/user.mk

SRC_DIR=..
R68K_DIR=$(ROSCO_M68K_DIR)/code/tools/r68k
SYSLIBROOT=$(ROSCO_M68K_DIR)/code/software/libs
SYSINCDIR?=$(SYSLIBROOT)/build/include
SYSLIBDIR?=$(SYSLIBROOT)/build/lib

CC=m68k-elf-rosco-gcc
CXX=m68k-elf-rosco-g++
AS=m68k-elf-rosco-as
NM=m68k-elf-rosco-nm
LD=m68k-elf-rosco-gcc
AR=m68k-elf-rosco-ar
RANLIB=m68k-elf-rosco-ranlib
OBJDUMP=m68k-elf-rosco-objdump
OBJCOPY=m68k-elf-rosco-objcopy
SIZE=m68k-elf-rosco-size
VASM=vasmm68k_mot
RM=rm -f

CPU?=68010
EXTRA_CFLAGS?=-g -O1 -fomit-frame-pointer
DEFINES=-DROSCO_M68K -DROSCO_M68K_KERNEL_BUILD -DUNIT_TESTS
FLAGS=-ffreestanding -ffunction-sections -fdata-sections							\
				-Wall -Wextra -Wno-unused-function 									\
				-Wno-unused-parameter -Wno-format -pedantic 						\
				-I../include -Iinclude												\
				-mcpu=$(CPU) -march=$(CPU) -mtune=$(CPU) $(DEFINES)
CFLAGS=-std=c11 $(FLAGS)
ASFLAGS=-mcpu=$(CPU) -march=$(CPU)
VASMFLAGS=-Felf -m$(CPU) -quiet -Lnf $(DEFINES)
ARFLAGS=
LIBS=
LDSCRIPT?=$(SYSLIBDIR)/ld/serial/hugerom_rosco_m68k_program.ld
LDFLAGS=-Wl,--gc-sections -Wl,--oformat=elf32-m68k

.PHONY: clean test

test: units.bin $(R68K_DIR)/r68k
	$(R68K_DIR)/r68k $<

$(SYSINCDIR)/stdio.h: $(SYSLIBROOT)/Makefile
	$(MAKE) -C $(SYSLIBROOT) clean install

__test_%.o: $(SRC_DIR)/%.asm
	$(VASM) $(VASMFLAGS) $(EXTRA_VASMFLAGS) -o $@ $<

__test_%.o: $(SRC_DIR)/%.c
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) -o $@ $<

%.o : %.c $(SYSINCDIR)/stdio.h
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) -o $@ $<

list.bin: list.elf
	$(OBJCOPY) -O binary $< $@

list.elf: list.o __test_list.o
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)
	$(SIZE) $@
	-chmod a-x $@

pmm.bin: pmm.elf
	$(OBJCOPY) -O binary $< $@

pmm.elf: pmm.o __test_kmachine.o __test_list.o __test_pmm.o
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)
	$(SIZE) $@
	-chmod a-x $@

bitmap.bin: bitmap.elf
	$(OBJCOPY) -O binary $< $@

bitmap.elf: bitmap.o __test_bitmap.o
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)
	$(SIZE) $@
	-chmod a-x $@

slab.bin: slab.elf
	$(OBJCOPY) -O binary $< $@

slab.elf: slab.o __test_kmachine.o __test_list.o __test_pmm.o __test_slab.o
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)
	$(SIZE) $@
	-chmod a-x $@

units.bin: units.elf
	$(OBJCOPY) -O binary $< $@

ALLTEST_OBJS=rtest/suite.o							\
			 rtest/list.o 							\
			 rtest/pmm.o							\
			 rtest/bitmap.o							\
			 rtest/slab.o							\
			 rtest/interrupts.o						\
			 __test_list.o							\
			 __test_pmm.o							\
			 __test_bitmap.o						\
			 __test_slab.o							\
			 __test_kmachine.o

units.elf: $(ALLTEST_OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)
	$(SIZE) $@
	-chmod a-x $@

$(R68K_DIR)/r68k: $(R68K_DIR)/Makefile
	$(MAKE) -C $(R68K_DIR) all

clean:
	$(RM) *.o *.bin *.elf *.lst rtest/*.o rtest/*.bin rtest/*.elf rtest/*.lst
