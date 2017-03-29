    .section .text

start:
    // Store some bytes at 0x100
    li  a5,256
    li  a4,16
    sb  a4,0(a5)
    li  a5,257
    li  a4,17
    sb  a4,0(a5)
    li  a5,258
    li  a4,18
    sb  a4,0(a5)
    li  a5,259
    li  a4,19
    sb  a4,0(a5)

    j   start
