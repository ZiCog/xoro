#include "firmware.h"

unsigned char testBytes[] = {0xde, 0xad, 0xbe, 0xef};

void helloWorld (void)
{

    while (1)
    {
        print_str("Hello world!\r\n");

        print_hex(testBytes[0], 2);
        print_hex(testBytes[1], 2);
        print_hex(testBytes[2], 2);
        print_hex(testBytes[3], 2);
        print_str("\r\n");

        testBytes[0] = testBytes[0] + 1;
        testBytes[1] = testBytes[1] + 2;
        testBytes[2] = testBytes[2] + 3;
        testBytes[3] = testBytes[3] + 4;

    }
}
