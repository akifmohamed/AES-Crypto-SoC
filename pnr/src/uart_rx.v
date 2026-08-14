// UART Receiver - 2-FF Synchronizer, 115200 baud @ 50MHz (BAUD_DIV=434)
module uart_rx #(
    parameter BAUD_DIV = 434
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] data_out,
    output reg        valid
);
    reg rx_sync1, rx_sync2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    reg [15:0] baud_cnt;
    reg [3:0]  bit_cnt;
    reg [1:0]  state; // 0: IDLE, 1: START, 2: DATA, 3: STOP

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= 2'd0;
            baud_cnt <= 16'd0;
            bit_cnt  <= 4'd0;
            data_out <= 8'd0;
            valid    <= 1'b0;
        end else begin
            valid <= 1'b0;
            case (state)
                2'd0: begin // IDLE
                    if (!rx_sync2) begin
                        state    <= 2'd1;
                        baud_cnt <= BAUD_DIV / 2;
                    end
                end
                2'd1: begin // START
                    if (baud_cnt == 0) begin
                        if (!rx_sync2) begin
                            state    <= 2'd2;
                            baud_cnt <= BAUD_DIV;
                            bit_cnt  <= 0;
                        end else begin
                            state <= 2'd0;
                        end
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end
                2'd2: begin // DATA
                    if (baud_cnt == 0) begin
                        data_out[bit_cnt] <= rx_sync2;
                        baud_cnt          <= BAUD_DIV;
                        if (bit_cnt == 7) begin
                            state <= 2'd3;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end
                2'd3: begin // STOP
                    if (baud_cnt == 0) begin
                        valid <= 1'b1;
                        state <= 2'd0;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end
            endcase
        end
    end
endmodule
