`default_nettype none

//=========================================================================
// FIFO Template
//-------------------------------------------------------------------------
//
//`include "EECS151.sv"

module fifo #(
    parameter int WIDTH    = 8,
    parameter int LOGDEPTH = 3
) (
    input  logic             clk,
    input  logic             reset,

    input  logic             enq_val,
    input  logic [WIDTH-1:0] enq_data,
    output logic             enq_rdy,

    output logic             deq_val,
    output logic [WIDTH-1:0] deq_data,
    input  logic             deq_rdy
);

    localparam int DEPTH = (1 << LOGDEPTH);

    // the buffer itself. Take note of the 2D syntax.
    logic [WIDTH-1:0] buffer [DEPTH-1:0];
    // read pointer, write pointer
    logic [LOGDEPTH-1:0] rptr, wptr;
    // is the buffer full? This is needed for when rptr == wptr
    logic full;

    // Define any additional regs or wires you need (if any) here

    // use "fire" to indicate when a valid transaction has been made
    logic enq_fire;
    logic deq_fire;

    assign enq_fire = enq_val & enq_rdy;
    assign deq_fire = deq_val & deq_rdy;

    // Your code here (don't forget the reset!)

endmodule
