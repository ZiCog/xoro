#include "firmware.h"

#define DATA_PORT 0xffff0020
#define STATUS_PORT 0xffff0024

char inch(void)
{
    while (*((volatile uint32_t*)STATUS_PORT) == 0 )
    {
        // Spin waiting for UART Rx full.
    }
    return *((volatile uint32_t*)DATA_PORT);
}

