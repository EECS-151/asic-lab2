`default_nettype none

`timescale 1 ns / 1 ps

module fir_tb_file();

    logic signed [3:0]  In;
    logic signed [15:0] Out;
    logic               clk, rst;
    integer error_count = 0;

    logic [4:0] index_counter;
    initial index_counter = 0;

    logic signed [15:0] Out_correct;
    logic signed [15:0] Out_correct_array [25:0];
    logic signed [3:0]  input_array       [25:0];

    initial clk = 0;
    always #(`CLOCK_PERIOD/2) clk <= ~clk;

    fir dut (
        .In (In),
        .clk(clk),
        .rst(rst),
        .Out(Out)
    );

    initial begin
        $fsdbDumpvars;
        rst = 1'b1;
        @(negedge clk) rst = 1'b0;
        repeat (25) @(negedge clk);
        #1ps;
        if (error_count != 0)
            $fatal(1, "FIR test failed with %0d mismatches", error_count);
        $display("[ passed ] FIR: 26 samples");
        $finish;
    end

    initial begin
        $readmemb("../../src/data_b.txt", Out_correct_array);
        $readmemb("../../src/input.txt",  input_array);
    end

    assign Out_correct = (index_counter < 26) ? Out_correct_array[index_counter] : '0;
    assign In          = (index_counter < 26) ? input_array[index_counter] : '0;

    always @(negedge clk) begin
      if ($time > 0 && index_counter < 26) begin
        $display($time, ": Out should be %d, got %d", Out_correct, Out);
        if ((index_counter < 26) && (Out !== Out_correct))
            error_count = error_count + 1;
        index_counter <= index_counter + 1;
      end
    end

endmodule

`default_nettype wire
