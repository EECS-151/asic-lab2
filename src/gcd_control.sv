`default_nettype none

//=========================================================================
// RTL Model of GCD Unit Control
//-------------------------------------------------------------------------
//

module gcd_control
(
    input  logic       clk,
    input  logic       reset,
    input  logic       operands_val,
    input  logic       result_rdy,
    input  logic       B_zero,
    input  logic       A_lt_B,
    output logic       result_val,
    output logic       operands_rdy,
    output logic [1:0] A_mux_sel,
    output logic       B_mux_sel,
    output logic       A_en,
    output logic       B_en
);

// Describe the control part as a stage machine

// Define state bits
localparam logic [1:0] CALC = 2'b00;
localparam logic [1:0] IDLE = 2'b10;
localparam logic [1:0] DONE = 2'b11;

// Note that the only flip flop in the design is "state"
logic [1:0] state;
logic [1:0] nextstate;

// Combinational logic decides what the next stage should be
always_comb begin

    // Start by defining default values
    nextstate     = state; // Stay in the same state by default
    // Only want to allow A/B registers to take new values when
    // we are sure the data on their inputs is valid
    A_en          = 1'b0;
    B_en          = 1'b0;
    result_val    = 1'b0;
    operands_rdy  = 1'b0;
    B_mux_sel     = 1'b0;
    A_mux_sel     = 2'b00;

    case (state)

        // IDLE STATE
        IDLE: begin
            operands_rdy = 1'b1;
            if (operands_val == 1'b1) begin
                nextstate = CALC;
                A_en      = 1'b1;
                B_en      = 1'b1;
            end else begin
                nextstate = IDLE;
            end
        end

        // CALC STATE
        CALC: begin
            if (A_lt_B == 1'b1) begin
                // SWAP
                B_mux_sel = 1'b1;
                A_mux_sel = 2'b01;
                A_en      = 1'b1;
                B_en      = 1'b1;
                nextstate = CALC;
            end else if (B_zero == 1'b0) begin
                // SUBTRACT
                A_mux_sel = 2'b10;
                A_en      = 1'b1;
                nextstate = CALC;
            end else begin
                // DONE
                nextstate = DONE;
            end
        end

        // DONE STATE
        DONE: begin
            // see if outside is ready to take the result
            // if so, send it, and say that operands are ready
            // to take new values
            result_val = 1'b1;
            if (result_rdy == 1'b1) begin
                nextstate = IDLE;
            // if not, stay in this state until the outside is ready for the result
            end else begin
                nextstate = DONE;
            end
        end

        default: begin
            nextstate = IDLE;
        end

    endcase

end

// State register (explicit instantiation per EECS151 policy)
REGISTER_R #(.N(2), .INIT(IDLE)) state_machine (
    .q  (state),
    .d  (nextstate),
    .rst(reset),
    .clk(clk)
);

endmodule
