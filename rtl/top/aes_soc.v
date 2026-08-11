<<<<<<< HEAD
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
=======
// ─────────────────────────────────────────────────────────
// AES-128 Crypto SoC Top
// Laptop <-UART-> SoC: 0xAE + key(16B) + plaintext(16B) => ciphertext(16B)
//               STATUS: 0x55 => 0xAA
// LEDs: busy (yellow), done (green), error (red), last cipher byte
// Clock: 50MHz
// ─────────────────────────────────────────────────────────
module aes_soc (
    input  wire       clk,         // 50 MHz
    input  wire       rst_n,       // Active low
    input  wire       uart_rx_pin, // From laptop
    output wire       uart_tx_pin, // To laptop
    output reg        led_busy,    // Yellow - encrypting
    output reg        led_done,    // Green - done / success blink
    output reg        led_error,   // Red - error
    output reg  [7:0] led_data     // Last cipher byte for visual
);

    // UART wires
    wire [7:0] rx_data;
    wire       rx_valid;
    wire [7:0] tx_data;
    wire       tx_start;
    wire       tx_busy;

    uart_rx #(.CLK_FREQ(50_000_000), .BAUD_RATE(115_200)) u_rx (
        .clk(clk), .rst_n(rst_n),
        .rx_pin(uart_rx_pin),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    uart_tx #(.CLK_FREQ(50_000_000), .BAUD_RATE(115_200)) u_tx (
        .clk(clk), .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_pin(uart_tx_pin)
    );

    // AES core
    reg  [127:0] aes_key;
    reg          aes_key_valid;
    reg  [127:0] aes_plaintext;
    reg          aes_data_valid;
    wire [127:0] aes_ciphertext;
    wire         aes_done;
    wire         aes_busy;

    aes_core u_aes_core (
        .clk(clk),
        .rst_n(rst_n),
        .key(aes_key),
        .key_valid(aes_key_valid),
        .plaintext(aes_plaintext),
        .data_valid(aes_data_valid),
        .ciphertext(aes_ciphertext),
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
        .done(aes_done),
        .busy(aes_busy)
    );

<<<<<<< HEAD
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
=======
    // SoC Controller FSM - UART protocol handler
    localparam S_IDLE          = 4'd0;
    localparam S_RECV_KEY      = 4'd1;
    localparam S_RECV_PLAIN    = 4'd2;
    localparam S_START_ENC     = 4'd3;
    localparam S_WAIT_ENC      = 4'd4;
    localparam S_SEND_CIPHER   = 4'd5;
    localparam S_SEND_STATUS   = 4'd6;
    localparam S_ERROR         = 4'd7;

    reg [3:0] state, next_state;
    reg [4:0] byte_cnt; // 0..16
    reg [127:0] key_buffer;
    reg [127:0] plain_buffer;
    reg [127:0] cipher_buffer;
    reg [4:0] tx_byte_cnt;

    // TX registers
    reg [7:0] tx_data_reg;
    reg       tx_start_reg;

    assign tx_data = tx_data_reg;
    assign tx_start = tx_start_reg;

    // FSM next state
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (rx_valid) begin
                    if (rx_data == 8'hAE) next_state = S_RECV_KEY;
                    else if (rx_data == 8'h55) next_state = S_SEND_STATUS;
                    else next_state = S_ERROR;
                end
            end
            S_RECV_KEY: begin
                if (rx_valid && byte_cnt == 5'd15) next_state = S_RECV_PLAIN;
            end
            S_RECV_PLAIN: begin
                if (rx_valid && byte_cnt == 5'd15) next_state = S_START_ENC;
            end
            S_START_ENC: begin
                next_state = S_WAIT_ENC;
            end
            S_WAIT_ENC: begin
                if (aes_done) next_state = S_SEND_CIPHER;
            end
            S_SEND_CIPHER: begin
                if (tx_byte_cnt == 5'd16 && !tx_busy) next_state = S_IDLE;
            end
            S_SEND_STATUS: begin
                if (!tx_busy && tx_start_reg == 0) begin
                    // after sending, go idle if done
                    // handled in seq logic
                end
            end
            S_ERROR: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            byte_cnt <= 0;
            key_buffer <= 0;
            plain_buffer <= 0;
            cipher_buffer <= 0;
            aes_key <= 0;
            aes_key_valid <= 0;
            aes_plaintext <= 0;
            aes_data_valid <= 0;
            tx_data_reg <= 0;
            tx_start_reg <= 0;
            tx_byte_cnt <= 0;
            led_busy <= 0;
            led_done <= 0;
            led_error <= 0;
            led_data <= 0;
        end else begin
            state <= next_state;
            aes_key_valid <= 1'b0;
            aes_data_valid <= 1'b0;
            tx_start_reg <= 1'b0;

            case (state)
                S_IDLE: begin
                    byte_cnt <= 0;
                    tx_byte_cnt <= 0;
                    led_busy <= 1'b0;
                    led_error <= 1'b0;
                    if (rx_valid) begin
                        if (rx_data == 8'hAE) begin
                            // start receiving key
                            byte_cnt <= 0;
                            led_busy <= 1'b1;
                        end else if (rx_data == 8'h55) begin
                            // status request, send 0xAA
                            tx_data_reg <= 8'hAA;
                            tx_start_reg <= 1'b1;
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
                        end else begin
                            led_error <= 1'b1;
                        end
                    end
                end
<<<<<<< HEAD
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
=======

                S_RECV_KEY: begin
                    if (rx_valid) begin
                        // Shift in: first byte = MSB
                        key_buffer <= {key_buffer[119:0], rx_data};
                        // Equivalent to building big-endian
                        // We'll implement as {prev[127-8 ...], new} but reversed? Let's do:
                        // Use byte position: key_buffer[127:0] where first received byte at [127:120]
                        // So we need to shift left 8 bits each time
                        if (byte_cnt == 5'd15) begin
                            byte_cnt <= 0;
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
                        end else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end
                end
<<<<<<< HEAD
            endcase
        end
    end
=======

                S_RECV_PLAIN: begin
                    if (rx_valid) begin
                        plain_buffer <= {plain_buffer[119:0], rx_data};
                        if (byte_cnt == 5'd15) begin
                            byte_cnt <= 0;
                        end else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end
                    // Latch key when moving from RECV_KEY to RECV_PLAIN - need to capture after last key byte
                    // We detect transition: when we entered this state, key_buffer still has previous shift
                    // So we should latch key_buffer into aes_key at first cycle of RECV_PLAIN?
                    // Instead we latch on entry using next_state detection: handled separately below
                end

                S_START_ENC: begin
                    aes_key <= key_buffer;
                    aes_key_valid <= 1'b1;
                    aes_plaintext <= plain_buffer;
                    // Data valid next cycle after key_valid? Our aes_core expects key_valid then data_valid
                    // We will assert data_valid for one cycle after key is latched
                    // To ensure key_expand sees same cycle, we assert both? Core stores key on key_valid edge.
                    // Let's sequence: assert key_valid now, data_valid next state but we also need core to have round_keys ready.
                    // Key_expand is combinational, round_keys_comb ready immediately, but core registers it on key_valid.
                    // So we need 1 cycle gap before data_valid. We will assert data_valid in WAIT? Actually we do two-phase
                    led_busy <= 1'b1;
                end

                S_WAIT_ENC: begin
                    // After 1 cycle, assert data_valid if not yet started
                    if (aes_busy == 1'b0 && aes_done == 1'b0 && byte_cnt == 0) begin
                        aes_data_valid <= 1'b1;
                        byte_cnt <= 5'd1; // mark as started
                    end
                    if (aes_done) begin
                        cipher_buffer <= aes_ciphertext;
                        led_data <= aes_ciphertext[7:0];
                        led_done <= 1'b1;
                        byte_cnt <= 0;
                        tx_byte_cnt <= 0;
                    end
                end

                S_SEND_CIPHER: begin
                    led_busy <= 1'b0;
                    if (!tx_busy && tx_byte_cnt < 16) begin
                        // Send MSB first: bytes from [127:120] down to [7:0]
                        case (tx_byte_cnt)
                            0:  tx_data_reg <= cipher_buffer[127:120];
                            1:  tx_data_reg <= cipher_buffer[119:112];
                            2:  tx_data_reg <= cipher_buffer[111:104];
                            3:  tx_data_reg <= cipher_buffer[103:96];
                            4:  tx_data_reg <= cipher_buffer[95:88];
                            5:  tx_data_reg <= cipher_buffer[87:80];
                            6:  tx_data_reg <= cipher_buffer[79:72];
                            7:  tx_data_reg <= cipher_buffer[71:64];
                            8:  tx_data_reg <= cipher_buffer[63:56];
                            9:  tx_data_reg <= cipher_buffer[55:48];
                            10: tx_data_reg <= cipher_buffer[47:40];
                            11: tx_data_reg <= cipher_buffer[39:32];
                            12: tx_data_reg <= cipher_buffer[31:24];
                            13: tx_data_reg <= cipher_buffer[23:16];
                            14: tx_data_reg <= cipher_buffer[15:8];
                            15: tx_data_reg <= cipher_buffer[7:0];
                            default: tx_data_reg <= 0;
                        endcase
                        tx_start_reg <= 1'b1;
                        tx_byte_cnt <= tx_byte_cnt + 1;
                    end
                end

                S_SEND_STATUS: begin
                    // Already triggered TX in IDLE, now wait for completion
                    if (!tx_busy && tx_start_reg == 0) begin
                        state <= S_IDLE;
                    end
                end

                S_ERROR: begin
                    led_error <= 1'b1;
                    // stay 1 cycle then idle
                end

            endcase

            // Special handling: accurately capture key_buffer after 16 bytes
            // The above shifting left works: {old[119:0], new_byte} where first byte ends up MSB after 16 shifts
            // So key_buffer after 16th byte is correct key.
            // Similarly plain_buffer

            // When transitioning from S_RECV_KEY to S_RECV_PLAIN on rx_valid last byte, key_buffer already updated above
            // So at S_RECV_PLAIN entry, key_buffer is valid. We already handle in S_START_ENC

        end
    end

    // Alternative simpler SHIFT approach: Reconstruct if previous method double-shifts? Check: we do {buffer[119:0], rx_data} each rx_valid
    // First byte: buffer = 0...0 + b0 => after 1 byte, b0 at LSB [7:0]? Wait we want MSB first.
    // If we shift left, b0 will move to MSB after 16 bytes: Let's verify:
    // start 0
    // after b0: {0..0, b0} = b0 at [7:0]
    // after b1: {(old[119:0]), b1} = old had b0 at [7:0]. After shift left 8, b0 moves to [15:8], b1 at [7:0]
    // After 16 bytes, first byte b0 will be at [127:120] = correct MSB first order.
    // So it's correct.

>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
