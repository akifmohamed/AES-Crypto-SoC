// AES-128 Crypto Accelerator SoC Top Level
// UART Protocol: 0xAE (cmd) -> 16B key -> 16B plaintext -> 11-cycle encryption -> status 0x55 -> 0xAA -> 16B ciphertext
module aes_soc (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       uart_rx_pin,
    output wire       uart_tx_pin,
    output reg        led_busy,
    output reg        led_done,
    output reg        led_error,
    output reg  [7:0] led_data
);
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       tx_busy;
    reg        tx_start;
    reg  [7:0] tx_data;

    uart_rx #(434) u_rx (.clk(clk), .rst_n(rst_n), .rx(uart_rx_pin), .data_out(rx_data), .valid(rx_valid));
    uart_tx #(434) u_tx (.clk(clk), .rst_n(rst_n), .start(tx_start), .data_in(tx_data), .tx(uart_tx_pin), .busy(tx_busy));

    reg         aes_start;
    reg [127:0] aes_key;
    reg [127:0] aes_plain;
    wire [127:0] aes_cipher;
    wire        aes_done;
    wire        aes_busy;

    aes_core u_aes (
        .clk(clk),
        .rst_n(rst_n),
        .start(aes_start),
        .key(aes_key),
        .plaintext(aes_plain),
        .ciphertext(aes_cipher),
        .done(aes_done),
        .busy(aes_busy)
    );

    reg [3:0] state; // FSM
    reg [4:0] byte_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= 4'd0;
            byte_cnt  <= 5'd0;
            aes_start <= 1'b0;
            aes_key   <= 128'd0;
            aes_plain <= 128'd0;
            tx_start  <= 1'b0;
            tx_data   <= 8'd0;
            led_busy  <= 1'b0;
            led_done  <= 1'b0;
            led_error <= 1'b0;
            led_data  <= 8'd0;
        end else begin
            tx_start <= 1'b0;
            aes_start <= 1'b0;
            led_busy <= aes_busy;
            case (state)
                4'd0: begin // IDLE - wait for 0xAE
                    led_done <= 1'b0;
                    if (rx_valid) begin
                        if (rx_data == 8'hAE) begin
                            state    <= 4'd1;
                            byte_cnt <= 5'd0;
                            led_error <= 1'b0;
                        end else begin
                            led_error <= 1'b1;
                        end
                    end
                end
                4'd1: begin // LOAD KEY (16 bytes, MSB first)
                    if (rx_valid) begin
                        aes_key  <= {aes_key[119:0], rx_data};
                        byte_cnt <= byte_cnt + 1;
                        if (byte_cnt == 5'd15) begin
                            state    <= 4'd2;
                            byte_cnt <= 5'd0;
                        end
                    end
                end
                4'd2: begin // LOAD PLAINTEXT (16 bytes, MSB first)
                    if (rx_valid) begin
                        aes_plain <= {aes_plain[119:0], rx_data};
                        byte_cnt  <= byte_cnt + 1;
                        if (byte_cnt == 5'd15) begin
                            state     <= 4'd3;
                            aes_start <= 1'b1;
                        end
                    end
                end
                4'd3: begin // WAIT AES
                    if (aes_done) begin
                        state    <= 4'd4;
                        byte_cnt <= 5'd0;
                        led_done <= 1'b1;
                        led_data <= aes_cipher[7:0]; // Last byte of cipher on LEDs
                    end
                end
                4'd4: begin // SEND STATUS 0xAA
                    if (!tx_busy && !tx_start) begin
                        tx_data  <= 8'hAA;
                        tx_start <= 1'b1;
                        state    <= 4'd5;
                        byte_cnt <= 5'd0;
                    end
                end
                4'd5: begin // SEND CIPHERTEXT (16 bytes, MSB first)
                    if (!tx_busy && !tx_start) begin
                        case (byte_cnt)
                            5'd0:  tx_data <= aes_cipher[127:120];
                            5'd1:  tx_data <= aes_cipher[119:112];
                            5'd2:  tx_data <= aes_cipher[111:104];
                            5'd3:  tx_data <= aes_cipher[103:96];
                            5'd4:  tx_data <= aes_cipher[95:88];
                            5'd5:  tx_data <= aes_cipher[87:80];
                            5'd6:  tx_data <= aes_cipher[79:72];
                            5'd7:  tx_data <= aes_cipher[71:64];
                            5'd8:  tx_data <= aes_cipher[63:56];
                            5'd9:  tx_data <= aes_cipher[55:48];
                            5'd10: tx_data <= aes_cipher[47:40];
                            5'd11: tx_data <= aes_cipher[39:32];
                            5'd12: tx_data <= aes_cipher[31:24];
                            5'd13: tx_data <= aes_cipher[23:16];
                            5'd14: tx_data <= aes_cipher[15:8];
                            5'd15: tx_data <= aes_cipher[7:0];
                            default: tx_data <= 8'd0;
                        endcase
                        tx_start <= 1'b1;
                        if (byte_cnt == 5'd15) begin
                            state <= 4'd0;
                        end else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
