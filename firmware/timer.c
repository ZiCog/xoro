// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

#define TIMER_PORT 0xffff0030

volatile int n;

int32_t timer(void)
{
    return *((volatile uint32_t*)TIMER_PORT);
}
