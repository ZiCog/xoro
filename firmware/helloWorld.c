#include "firmware.h"

unsigned char testBytes[] = {0xde, 0xad, 0xbe, 0xef};

void helloWorld (void)
{
    int count = 0;
    uint32_t random;

    while (1)
    {
        print_str("Hello world!   ");

        random = prng();

        print_hex(random, 8);
        print_str("\r\n");

        ledsOut(random);
        
        count++;
    }
}
