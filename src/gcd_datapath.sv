`default_nettype none

//=========================================================================
// RTL Model of GCD Unit Datpath
//-------------------------------------------------------------------------
//

module gcd_datapath #(
    parameter int W = 16
) (

    // data inputs/outputs
    input  logic [W-1:0] operands_bits_A,
    input  logic [W-1:0] operands_bits_B,
    output logic [W-1:0] result_bits_data,

    // global inputs
    input  logic         clk,
    input  logic         reset,

    // control signal inputs and outputs
    input  logic         B_mux_sel,
    input  logic         A_en,
    input  logic         B_en,
    input  logic [1:0]   A_mux_sel,
    output logic         B_zero,
    output logic         A_lt_B
);

    logic [W-1:0] A_reg;
    logic [W-1:0] B_reg;
    logic [W-1:0] A_next;
    logic [W-1:0] B_next;
    logic [W-1:0] sub_out;

    // Combinational
    // ------------
    assign A_next
        = A_mux_sel == 2'd0 ? operands_bits_A
        : A_mux_sel == 2'd1 ? B_reg
        : A_mux_sel == 2'd2 ? sub_out
        : {W{1'bx}};

    assign B_next
        = B_mux_sel == 1'b0 ? operands_bits_B
        : B_mux_sel == 1'b1 ? A_reg
        : {W{1'bx}};

    // Subtract
    assign sub_out = A_reg - B_reg;

    // Zero?
    assign B_zero = (B_reg == '0) ? 1'b1 : 1'b0;

    // LT
    assign A_lt_B = (A_reg < B_reg) ? 1'b1 : 1'b0;

    // Assign output
    assign result_bits_data = A_reg;

    // Sequential (explicit instantiation per EECS151 policy)
    REGISTER_R_CE #(.N(W)) A_register (.q(A_reg), .d(A_next), .rst(reset), .ce(A_en), .clk(clk));
    REGISTER_R_CE #(.N(W)) B_register (.q(B_reg), .d(B_next), .rst(reset), .ce(B_en), .clk(clk));

endmodule
