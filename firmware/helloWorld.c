#include "firmware.h"

unsigned char testBytes[] = {0xde, 0xad, 0xbe, 0xef};

void helloWorld (void)
{
    int count = 0;
    uint32_t random;
    int32_t time;
    int32_t timeLast = 0;
    char c;

    while (1)
    {
        print_str("\r\nHello world!\r\n");

        while (1) {
            c = inch();
            print_chr(c);
            if ((c == '\r') || (c == '\n')) {
                break;
            } 
            ledsOut(c);
        }
        
        print_str("\r\n");

        time = timer();
        print_hex(time, 8);

        print_str(" : ");
        print_hex(time - timeLast, 8);
        timeLast = time;

        print_str(" : ");
        random = prng();
        print_hex(random, 8);
        print_str("\r\n");

        ledsOut(random);

        fft_bench();
        print_str("\r\n");

        count++;

    }
}
