#include "firmware.h"


void helloWorld (void)
{
    int count = 0;
    uint32_t random;
    int32_t time;
    int32_t timeLast = 0;
    char c = 0;
    int errorCount = 0;
    const char* message = "Now is the time for all good men to come to the aid of the party";
    const char* msgPtr = message;

    while (1)
    {
        print_str(message);
        print_str("\r\n");

        while (1) {
            c = inch();
	    if (c == *msgPtr)
	    {
		if (c == 0)
		{
		    print_str("RX error count: ");
		    print_hex(errorCount, 8);
		    print_str("\r\n");
		    msgPtr = message;
		}
		else
		{
	          msgPtr++;
		}
            }
	    else
	    {
                errorCount++;
		msgPtr = message;
		print_str("RX error count: ");
		print_hex(errorCount, 8);
		print_str("\r\n");
                ledsOut(errorCount);
	    }
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
