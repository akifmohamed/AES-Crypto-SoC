// UART Transmitter - 115200 baud @ 50MHz (BAUD_DIV=434)
module uart_tx #(
    parameter BAUD_DIV = 434
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        busy
);
    reg [15:0] baud_cnt;
    reg [3:0]  bit_cnt;
    reg [9:0]  shift_reg;
    reg        state; // 0: IDLE, 1: TX

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= 1'b0;
            baud_cnt  <= 16'd0;
            bit_cnt   <= 4'd0;
            shift_reg <= 10'h3FF;
            tx        <= 1'b1;
            busy      <= 1'b0;
        end else begin
            case (state)
                1'b0: begin // IDLE
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    if (start) begin
                        state     <= 1'b1;
                        shift_reg <= {1'b1, data_in, 1'b0}; // Stop, data, Start
                        baud_cnt  <= BAUD_DIV;
                        bit_cnt   <= 0;
                        busy      <= 1'b1;
                    end
                end
                1'b1: begin // TX
                    tx <= shift_reg[0];
                    if (baud_cnt == 0) begin
                        baud_cnt <= BAUD_DIV;
                        shift_reg <= {1'b1, shift_reg[9:1]};
                        if (bit_cnt == 9) begin
                            state <= 1'b0;
                            busy  <= 1'b0;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end
            endcase
        end
    end
endmodule
