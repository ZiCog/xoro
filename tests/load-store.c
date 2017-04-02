#include <stdint.h>

int main(int argc, char* argv[])
{
start:
    *(uint8_t*) 0x100 = 0x10;
    *(uint8_t*) 0x101 = 0x11;
    *(uint8_t*) 0x102 = 0x12;
    *(uint8_t*) 0x103 = 0x13;

    *(uint32_t*) 0x100 = 0x00000000;

    *(uint16_t*) 0x100 = 0x1110;
    *(uint16_t*) 0x102 = 0x1312;

    int32_t count = 0;
loop:
    *(uint32_t*) 0xffff0060 = count >> 8;
    count = count + 1;
    goto loop;

    return 0;
}
