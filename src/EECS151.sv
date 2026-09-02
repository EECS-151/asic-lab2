`default_nettype none

/* Standard include file for EECS151.

 The "no flip-flop inference" policy.  Instead of using flip-flop and
 register inference, all EECS151/251A Verilog specifications will use
 explicit instantiation of register modules (defined below).  This
 policy will apply to lecture, discussion, lab, project, and problem
 sets.  This way of specification matches our RTL model of circuit,
 i.e., all specifications are nothing but a set of interconnected
 combinational logic blocks and state elements.  The goal is to
 simplify the use of Verilog and avoid mistakes that arise from
 specifying sequential logic.  Also, we can eliminate the explicit use
 of the non-blocking assignment "<=", and the associated confusion
 about blocking versus non-blocking.

 Here is a draft set of standard registers for EECS151.  All are
 positive edge triggered.  R and CE represent synchronous reset and
 clock enable, respectively. Both are active high.

 REGISTER
 REGISTER_CE
 REGISTER_R
 REGISTER_R_CE
*/

// Register of D-Type Flip-flops
module REGISTER #(
   parameter int N = 1
) (
   output logic [N-1:0] q,
   input  logic [N-1:0] d,
   input  logic         clk
);
   always_ff @(posedge clk)
      q <= d;
endmodule // REGISTER

// Register with clock enable
module REGISTER_CE #(
   parameter int N = 1
) (
   output logic [N-1:0] q,
   input  logic [N-1:0] d,
   input  logic         ce,
   input  logic         clk
);
   always_ff @(posedge clk)
      if (ce) q <= d;
endmodule // REGISTER_CE

// Register with reset value
module REGISTER_R #(
   parameter int N = 1,
   parameter logic [N-1:0] INIT = {N{1'b0}}
) (
   output logic [N-1:0] q,
   input  logic [N-1:0] d,
   input  logic         rst,
   input  logic         clk
);
   always_ff @(posedge clk)
      if (rst) q <= INIT;
      else     q <= d;
endmodule // REGISTER_R

// Register with reset and clock enable
// Reset works independently of clock enable
module REGISTER_R_CE #(
   parameter int N = 1,
   parameter logic [N-1:0] INIT = {N{1'b0}}
) (
   output logic [N-1:0] q,
   input  logic [N-1:0] d,
   input  logic         rst,
   input  logic         ce,
   input  logic         clk
);
   always_ff @(posedge clk)
      if (rst)      q <= INIT;
      else if (ce)  q <= d;
endmodule // REGISTER_R_CE


/*
 Memory Blocks. These will simulate correctly and synthesize correctly
 to memory resources in the FPGA flow. Eventually, will need to make an
 ASIC version.
*/

// Single-ported RAM with asynchronous read
module RAM #(
   parameter int DWIDTH = 8,   // Data width
   parameter int AWIDTH = 8,   // Address width
   parameter int DEPTH  = 256  // Memory depth
) (
   output logic [DWIDTH-1:0] q,        // Data output (async read)
   input  logic [DWIDTH-1:0] d,        // Data input
   input  logic [AWIDTH-1:0] addr,     // Address input
   input  logic              we,
   input  logic              clk
);
   logic [DWIDTH-1:0] mem [0:DEPTH-1];

   always_ff @(posedge clk)
      if (we) mem[addr] <= d;

   assign q = mem[addr];
endmodule // RAM

/*
 To add: multiple ports, synchronous read, ASIC synthesis support.
 */

`default_nettype wire
