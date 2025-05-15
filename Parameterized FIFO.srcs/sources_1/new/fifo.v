module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 64,
    parameter ADDR_WIDTH = 6  // log2(64) = 6
)(
    input clk, rst,
    input [DATA_WIDTH-1:0] buf_in,
    input wr_en, rd_en,
    output reg [DATA_WIDTH-1:0] buf_out,
    output buf_empty, buf_full,
    output reg [ADDR_WIDTH:0] fifo_counter  // Can count from 0 to DEPTH
);

    reg [DATA_WIDTH-1:0] buf_mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] rd_ptr, wr_ptr;

    // === Synchronizers for Debounce ===
    reg [1:0] wr_sync, rd_sync;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_sync <= 2'b00;
            rd_sync <= 2'b00;
        end else begin
            wr_sync <= {wr_sync[0], wr_en};
            rd_sync <= {rd_sync[0], rd_en};
        end
    end

    // === Edge Detection ===
    wire wr_pulse = (wr_sync == 2'b01);
    wire rd_pulse = (rd_sync == 2'b01);

    assign buf_empty = (fifo_counter == 0);
    assign buf_full  = (fifo_counter == DEPTH);

    // === FIFO Counter ===
    always @(posedge clk or posedge rst) begin
        if (rst)
            fifo_counter <= 0;
        else if (wr_pulse && !buf_full && !(rd_pulse && !buf_empty))
            fifo_counter <= fifo_counter + 1;
        else if (rd_pulse && !buf_empty && !(wr_pulse && !buf_full))
            fifo_counter <= fifo_counter - 1;
    end

    // === Data Output ===
    always @(posedge clk or posedge rst) begin
        if (rst)
            buf_out <= {DATA_WIDTH{1'b0}};
        else if (rd_pulse && !buf_empty)
            buf_out <= buf_mem[rd_ptr];
    end

    // === Write Memory ===
    always @(posedge clk) begin
        if (wr_pulse && !buf_full)
            buf_mem[wr_ptr] <= buf_in;
    end

    // === Pointer Logic ===
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_pulse && !buf_full)
                wr_ptr <= wr_ptr + 1;
            if (rd_pulse && !buf_empty)
                rd_ptr <= rd_ptr + 1;
        end
    end

endmodule
