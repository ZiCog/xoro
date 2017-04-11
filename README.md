# xoro

This is the picorv32 RISC-V processor in Verilog wrapped in some very simple
memory and peripherals. Enough to get it working on a Terasic DE-0 Nano
Cyclone IV FPGA board.

The name comes from the fact that this project grew out of a version of the
xoroshiro128+ pseudo random number generator in Verilog.

picorv32 is by Clifford Wolf : https://github.com/cliffordwolf/picorv32

## Building the firmware

The current firmware is very simple and only prints "Hello World!" repeatedly to the UART at 38400 baud. If you want to tinker with it it can be rebuild with:

    $ make firmware/firmware.hex

## Run on DE0 Nano board.

Just open the project file xoro.qpf in Quartus.

Hit the "Start compilation" button.

When it's done hit the "Programmer" button. Select the xoro.sof file from the out_put files directory and hit start.

To see the UART output I use a Parallax Prop Plug serial to USB adapter.See pin assignments to see where to plug it in to the header.

## Run under Icarus simulator

Build the top level test bench with iverilog:

    $   iverilog -o xoro_top_tb.vvp test_bench/xoro_top_tb.v rtl/xoro_top.v rtl/memory.v rtl/gpio.v rtl/prng.v  \
        rtl/uartTx.v rtl/xoroshiro128plus.v rtl/picorv32.v rtl/address_decoder.v rtl/timer.v

And run under the Icarus simulator:

    $ vvp xoro_top_tb.vvp
    
This produces a ton of output so maybe you want:

    $ vvp xoro_top_tb.vvp | less
    
Or redirect to a file:

    $ vvp xoro_top_tb.vvp > test.txt

In order to understand the output you will need to know what firmware it is executing. A disassembled listing can be obtained with objdump:

    $ riscv32-unknown-elf-objdump -d firmware/firmware.elf









    
