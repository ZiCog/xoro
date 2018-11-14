RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32

FIRMWARE_OBJS = firmware/start.o firmware/irq.o firmware/print.o firmware/inch.o firmware/timer.o firmware/prng.o firmware/leds.o firmware/fftbench.o firmware/main.o 
GCC_WARNS  =  -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)im/bin/riscv32-unknown-elf-
COMPRESSED_ISA =

firmware/firmware.mif: firmware/firmware.bin firmware/makemif.py
	python3 firmware/makemif.py $< 16384 > $@

firmware/firmware.hex: firmware/firmware.bin firmware/makehex.py
	python3 firmware/makehex.py $< 16384 firmware > $@

firmware/firmware.bin: firmware/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

firmware/%.o: firmware/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

clean:
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS)   \
		firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex firmware/firmware.mif firmware/firmware.map

.PHONY:  clean
