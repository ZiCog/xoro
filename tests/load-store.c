#include <stdint.h>

int main(int argc, char* argv[])
{
    *(uint8_t*) 0x100 = 0x10;
    *(uint8_t*) 0x101 = 0x11;
    *(uint8_t*) 0x102 = 0x12;
    *(uint8_t*) 0x103 = 0x13;

    *(uint32_t*) 0x100 = 0x00000000;

    *(uint16_t*) 0x100 = 0x1110;
    *(uint16_t*) 0x102 = 0x1312;

    return 0;
}
