Build verilog version with Icarus Verilog:

    $ cd xoroshiro128plus/
    $ iverilog -o xoroshiro128plus_tb.vvp xoroshiro128plus_tb.v xoroshiro128plus.v shuff.v


and run with the vvp simulator:

    $ vvp xoroshiro128plus_tb.vvp


