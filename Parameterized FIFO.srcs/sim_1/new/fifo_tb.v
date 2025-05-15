`timescale 1ns / 1ps

module fifo_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 64;
    parameter ADDR_WIDTH = 6;

    // Testbench signals
    reg clk, rst;
    reg [DATA_WIDTH-1:0] buf_in;
    reg wr_en, rd_en;
    wire [DATA_WIDTH-1:0] buf_out;
    wire buf_empty, buf_full;
    wire [ADDR_WIDTH:0] fifo_counter;

    // Instantiate FIFO
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .buf_in(buf_in),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .buf_out(buf_out),
        .buf_empty(buf_empty),
        .buf_full(buf_full),
        .fifo_counter(fifo_counter)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Monitor output
    initial begin
        $display("Time\tWR_EN\tRD_EN\tBUF_IN\tBUF_OUT\tCNT\tEMPTY\tFULL");
        $monitor("%0t\t%b\t%b\t%h\t%h\t%0d\t%b\t%b",
                 $time, wr_en, rd_en, buf_in, buf_out, fifo_counter, buf_empty, buf_full);
    end

    // Waveform dump for viewing the simulation in a waveform viewer
    initial begin
        $dumpfile("fifo_wave.vcd");
        $dumpvars(0, fifo_tb);
    end

    // Stimulus with glitchy signals and counter-based storing
    initial begin
        // Initialize
        clk = 0; rst = 1;
        wr_en = 0; rd_en = 0;
        buf_in = 8'h00;

        // Reset the FIFO
        #20 rst = 0;

        // Write data until counter reaches 7
        #20 buf_in = 8'hAA; wr_en = 1;   // Write AA
        #10 wr_en = 0;                  // End write

        #20 buf_in = 8'hBB; wr_en = 1;   // Write BB
        #10 wr_en = 0;                  // End write

        #20 buf_in = 8'hCC; wr_en = 1;   // Write CC
        #10 wr_en = 0;                  // End write

        #20 buf_in = 8'hDD; wr_en = 1;   // Write DD
        #10 wr_en = 0;                  // End write

        #20 buf_in = 8'hEE; wr_en = 1;   // Write EE
        #10 wr_en = 0;                  // End write

        #20 buf_in = 8'hFF; wr_en = 1;   // Write FF
        #10 wr_en = 0;                  // End write

        #20 buf_in = 8'h11; wr_en = 1;   // Write 11
        #10 wr_en = 0;                  // End write

        #20 buf_in = 8'h22; wr_en = 1;   // Write 22
        #10 wr_en = 0;                  // End write

        // Check debounce behavior by rapidly toggling wr_en
        #30 buf_in = 8'h33; wr_en = 1;   // Write 33
        #5  wr_en = 0;                  // Glitch 1
        #5  wr_en = 1;                  // Glitch 2
        #5  wr_en = 0;                  // Glitch 3
        #5  wr_en = 1;                  // Glitch 4
        #10 wr_en = 0;                  // End the pulse

        // Simultaneously toggle rd_en to check debounce behavior
        #30 rd_en = 1;                 // Start read
        #5  rd_en = 0;                 // Glitch 1
        #5  rd_en = 1;                 // Glitch 2
        #5  rd_en = 0;                 // Glitch 3
        #5  rd_en = 1;                 // Glitch 4
        #10 rd_en = 0;                 // End read

        // Start reading when counter reaches 7 and decrement back to 0
        #40 rd_en = 1;                 // Read AA
        #10 rd_en = 0;

        #40 rd_en = 1;                 // Read BB
        #10 rd_en = 0;

        #40 rd_en = 1;                 // Read CC
        #10 rd_en = 0;

        #40 rd_en = 1;                 // Read DD
        #10 rd_en = 0;

        #40 rd_en = 1;                 // Read EE
        #10 rd_en = 0;

        #40 rd_en = 1;                 // Read FF
        #10 rd_en = 0;

        #40 rd_en = 1;                 // Read 11
        #10 rd_en = 0;

        #40 rd_en = 1;                 // Read 22
        #10 rd_en = 0;

        // Final read
        #30 rd_en = 1;
        #10 rd_en = 0;

        #50 $finish;
    end

endmodule
