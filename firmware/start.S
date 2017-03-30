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

    // Clear word at 0x100
    li      a5,256
    sw      zero,0(a5)

    // Jump back and do it again
    j       start
