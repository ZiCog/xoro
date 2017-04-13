`timescale 1 ns / 1 ps

// Use this with non-blocking delays if desired.
// e.g. q <= `D d;
// See http://www.sunburst-design.com/papers/CummingsSNUG2002Boston_NBAwithDelays.pdf
//
`ifndef D
    `define D (#1)
`endif
