.section .text

start:
    // Store 4 bytes at 0x100, 0x101, 0x102, 0x103,
    li      a5,256
    li      a4,16
    sb      a4,0(a5)

    li      a5,257
    li      a4,17
    sb      a4,0(a5)

    li      a5,258
    li      a4,18
    sb      a4,0(a5)

    li      a5,259
    li      a4,19
    sb      a4,0(a5)

    // Clear word at 0x100
    li      a5,256
    sw      zero,0(a5)

    // Store 2 half words at 0x100, 0x102,
    li      a5,256
    li      a4,4096
    add     a4,a4,272
    sh      a4,0(a5)

    li      a5,258
    li      a4,4096
    add     a4,a4,786
    sh      a4,0(a5)

    // Write 0x55555555 to 0xffff0006
    li      a5,-65536
    add     a5,a5,96
    li      a4,1431654400
    add     a4,a4,1365
    sw      a4,0(a5)

loop:
    li      a5,-65536
    add     a5,a5,96
    lw      a4,-20(s0)
    sra     a4,a4,16
    sw      a4,0(a5)
    lw      a5,-20(s0)
    add     a5,a5,1
    sw      a5,-20(s0)
    j       loop
