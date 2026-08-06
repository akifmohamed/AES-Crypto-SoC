// UART Receiver - 8N1, 115200 baud @50MHz
// BAUD_DIV = 50M/115200 = 434
// Samples at middle of bit for reliability
// 2-FF synchronizer for metastability
module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_pin,
    output reg  [7:0] rx_data,
    output reg        rx_valid
);
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE; // 434
    localparam HALF_DIV = BAUD_DIV / 2;

    // Synchronizer
    reg rx_sync_0, rx_sync_1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync_0 <= 1'b1;
            rx_sync_1 <= 1'b1;
        end else begin
            rx_sync_0 <= rx_pin;
            rx_sync_1 <= rx_sync_0;
        end
    end

    // FSM
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
            rx_data <= 0;
            rx_valid <= 0;
        end else begin
            rx_valid <= 1'b0;
            case (state)
                IDLE: begin
                    baud_cnt <= 0;
                    bit_cnt <= 0;
                    if (rx_sync_1 == 1'b0) begin // start bit detected
                        state <= START;
                    end
                end
                START: begin
                    if (baud_cnt == HALF_DIV) begin
                        if (rx_sync_1 == 1'b0) begin // still low, valid start
                            baud_cnt <= 0;
                            state <= DATA;
                        end else begin
                            state <= IDLE; // false start
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                DATA: begin
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        shift_reg <= {rx_sync_1, shift_reg[7:1]}; // LSB first, shift right
                        if (bit_cnt == 3'd7) begin
                            bit_cnt <= 0;
                            state <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    if (baud_cnt == BAUD_DIV-1) begin
                        baud_cnt <= 0;
                        rx_data <= shift_reg;
                        rx_valid <= 1'b1;
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
