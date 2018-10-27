Verilog Guidelines:
===================

These are some guidlines extracted from: Verilog Nonblocking Assignments With Delays,
Myths & Mysteries
http://www.sunburst-design.com/papers/CummingsSNUG2002Boston_NBAwithDelays.pdf


* 1 When modeling sequential logic, use nonblocking assignments.

* 2 When modeling latches, use nonblocking assignments.

* 3 When modeling combinational logic with an always block, use blocking
assignments.

* 4 When modeling both sequential and combinational logic within the same always
block, use nonblocking assignments.

* 5 Do not mix blocking and nonblocking assignments in the same always block.

* 6 Do not make assignments to the same variable from more than one always block.

* 7 Use $strobe to display values that have been assigned using nonblocking
assignments.

* 8 Do not make assignments using #0 delays.


