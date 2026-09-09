`default_nettype none

`timescale 1 ns / 100 ps

module gcd_coprocessor_testbench;

  //--------------------------------------------------------------------
  // Define test vectors
  //--------------------------------------------------------------------
  logic [31:0] src_bits  [7:0];
  logic [15:0] sink_bits [7:0];
  assign src_bits[0] = { 16'd27,  16'd15  }; assign sink_bits[0] = 16'd3;
  assign src_bits[1] = { 16'd21,  16'd49  }; assign sink_bits[1] = 16'd7;
  assign src_bits[2] = { 16'd25,  16'd30  }; assign sink_bits[2] = 16'd5;
  assign src_bits[3] = { 16'd19,  16'd27  }; assign sink_bits[3] = 16'd1;
  assign src_bits[4] = { 16'd40,  16'd40  }; assign sink_bits[4] = 16'd40;
  assign src_bits[5] = { 16'd250, 16'd190 }; assign sink_bits[5] = 16'd10;
  assign src_bits[6] = { 16'd5,   16'd250 }; assign sink_bits[6] = 16'd5;
  assign src_bits[7] = { 16'd0,   16'd0   }; assign sink_bits[7] = 16'd0;

  //--------------------------------------------------------------------
  // Setup a clock
  //--------------------------------------------------------------------
  logic clk = 0;
  always #(`CLOCK_PERIOD/2) clk = ~clk;

  logic done = 0;

  //--------------------------------------------------------------------
  // Instantiate DUT and wire/reg the inputs and outputs
  //--------------------------------------------------------------------

  logic        reset;
  logic        operands_val;
  logic [31:0] operands_bits_A;
  logic [31:0] operands_bits_B;
  logic        operands_rdy;
  logic        result_val;
  logic [31:0] result_bits;
  logic        result_rdy;

  integer i = 0;
  localparam int num_tests = 7;

  logic [31:0] test_A       [num_tests-1:0];
  logic [31:0] test_B       [num_tests-1:0];
  logic [31:0] test_results [num_tests-1:0];

  gcd_coprocessor #(32) dut (
    .clk            (clk),
    .reset          (reset),
    .operands_val   (operands_val),
    .operands_bits_A(operands_bits_A),
    .operands_bits_B(operands_bits_B),
    .operands_rdy   (operands_rdy),
    .result_val     (result_val),
    .result_bits    (result_bits),
    .result_rdy     (result_rdy)
  );

  //--------------------------------------------------------------------
  // Define a sequential interface that steps through each test in
  // the src/sink array every time a valid ready/val handshake occurs
  //--------------------------------------------------------------------

  // Apply stimulus
  initial begin
    $fsdbDumpvars;
    // Initial values
    reset          = 0;
    operands_val   = 0;
    operands_bits_A= 32'd0;
    operands_bits_B= 32'd0;
    result_rdy     = 1;

    // Strobe reset
    repeat (5) @(negedge clk) reset = 1;
    @(negedge clk) reset = 0;
    @(negedge clk);

    for (i = 0; i < num_tests; i = i + 1) begin
      // wait if operands not ready
      while (~operands_rdy) begin
        @(negedge clk) reset = 0;
      end
      operands_val    = 1;
      operands_bits_A = test_A[i];
      operands_bits_B = test_B[i];
      @(negedge clk);
      operands_val    = 0;
      @(negedge clk);
    end

    @(posedge done);
    $display("[ passed ] All %0d GCD coprocessor tests", num_tests);
    $finish;
  end

  logic [3:0] test_idx = 0;

  // Observe results
  always @(posedge clk) begin
    if (~reset && result_val && result_rdy) begin
      if (result_bits == test_results[test_idx]) begin
        $display(" [ passed ] Test ( %d ), [ %d == %d ] (decimal)", test_idx, result_bits, test_results[test_idx]);
      end else begin
        $fatal(1, " [ failed ] Test ( %d ), [ %d == %d ] (decimal)", test_idx, result_bits, test_results[test_idx]);
      end
      test_idx <= test_idx + 1;
    end else if (test_idx >= num_tests) begin
      done <= 1;
    end
  end

  //--------------------------------------------------------------------
  // Timeout
  //--------------------------------------------------------------------
  // If something goes wrong, kill the simulation...
  logic [63:0] cycle_count = 0;
  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
    if (cycle_count >= 100000) begin
      $fatal(1, "TIMEOUT");
    end
  end

  // Put the test vectors down here for now
  initial begin
    test_A[0]       = 32'd7;
    test_B[0]       = 32'd7;
    test_results[0] = 32'd7;

    test_A[1]       = 32'd12;
    test_B[1]       = 32'd8;
    test_results[1] = 32'd4;

    test_A[2]       = 32'd200;
    test_B[2]       = 32'd35;
    test_results[2] = 32'd5;

    test_A[3]       = 32'd15;
    test_B[3]       = 32'd9;
    test_results[3] = 32'd3;

    test_A[4]       = 32'd99;
    test_B[4]       = 32'd36;
    test_results[4] = 32'd9;

    test_A[5]       = 32'd1;
    test_B[5]       = 32'd2;
    test_results[5] = 32'd1;

    test_A[6]       = 32'd144;
    test_B[6]       = 32'd168;
    test_results[6] = 32'd24;
  end

endmodule
