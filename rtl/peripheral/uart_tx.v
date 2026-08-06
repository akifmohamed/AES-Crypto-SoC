// UART Transmitter - 8N1, 115200 @50MHz
// BAUD_DIV = 434
module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx_busy,
    output reg        tx_pin
);
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    reg [1:0] state;
    reg [12:0] baud_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            baud_cnt <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            tx_busy <= 0;
            tx_pin <= 1'b1; // idle high
        end else begin
            case (state)
                IDLE: begin
                    tx_pin <= 1'b1;
                    baud_cnt <= 0;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        tx_busy <= 1'b1;
                        state <= START;
                    end
                end
                START: begin
                    tx_pin <= 1'b0; // start bit
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        state <= DATA;
                        bit_cnt <= 0;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                DATA: begin
                    tx_pin <= shift_reg[0];
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        if (bit_cnt == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    tx_pin <= 1'b1; // stop bit
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        tx_busy <= 1'b0;
                        state <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
