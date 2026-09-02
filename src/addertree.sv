`default_nettype none

module addertree #(
    parameter int NUM_INPUT_BITS  = 4,
    parameter int NUM_OUTPUT_BITS = 16
) (
    input  logic signed [NUM_INPUT_BITS-1:0]  in0,
    input  logic signed [NUM_INPUT_BITS-1:0]  in1,
    input  logic signed [NUM_INPUT_BITS-1:0]  in2,
    input  logic signed [NUM_INPUT_BITS-1:0]  in3,
    input  logic signed [NUM_INPUT_BITS-1:0]  in4,
    output logic signed [NUM_OUTPUT_BITS-1:0] Out
);

    assign Out = in0 + in4 + (in1 <<< 2) + (in3 <<< 2) + (in2 <<< 4);

endmodule

`default_nettype wire
