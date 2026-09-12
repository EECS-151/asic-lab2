`default_nettype none

//=========================================================================
// Template for GCD coprocessor
//-------------------------------------------------------------------------
//

module gcd_coprocessor #(
  parameter int W = 32
) (
  input  logic         clk,
  input  logic         reset,

  input  logic         operands_val,
  input  logic [W-1:0] operands_bits_A,
  input  logic [W-1:0] operands_bits_B,
  output logic         operands_rdy,

  output logic         result_val,
  output logic [W-1:0] result_bits,
  input  logic         result_rdy
);

  // You should be able to build this with only structural SystemVerilog!

  // TODO: Define wires

  // TODO: Instantiate gcd_datapath

  // TODO: Instantiate gcd_control

  // TODO: Instantiate request FIFO

  // TODO: Instantiate response FIFO

endmodule
