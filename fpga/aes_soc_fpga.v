// Basys3 wrapper: 100 MHz -> 50 MHz divider + power-on/button reset conditioning
// + LED latch (result stays visible until next command/reset)
// + on-FPGA encryption cycle counter (transmitted as 2 extra bytes after the
//   SoC's 17-byte reply, so the host can measure the true encryption time)
module aes_soc_fpga (
    input  wire       clk,          // 100 MHz (W5)
    input  wire       btnC,         // press = reset (U18)
    input  wire       uart_rx_pin,  // B18 (from laptop FTDI)
    output wire       uart_tx_pin,  // A18
    output wire       led_busy,     // LD13
    output wire       led_done,     // LD15
    output wire       led_error,    // LD14
    output wire [7:0] led_data      // LD0..LD7
);
    // ---- 100 MHz -> 50 MHz divider ----
    reg [1:0] div;
    wire clk50 = div[0];
    always @(posedge clk) div <= div + 1'b1;

    // ---- power-on reset + button reset conditioning ----
    reg [3:0] pon;
    always @(posedge clk50) if (!pon[3]) pon <= pon + 1'b1;

    reg b1, b2;
    always @(posedge clk50) begin b1 <= btnC; b2 <= b1; end
    wire rst_n = pon[3] & ~b2;

    // ---- SoC ----
    wire soc_led_busy, soc_led_done, soc_led_error;
    wire [7:0] soc_led_data;
    wire       soc_tx;

    aes_soc u_soc (
        .clk(clk50), .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin), .uart_tx_pin(soc_tx),
        .led_busy(soc_led_busy), .led_done(soc_led_done),
        .led_error(soc_led_error), .led_data(soc_led_data)
    );

    // ---- LED latch: hold result visible until next UART command or reset ----
    wire uart_start = ~uart_rx_pin;              // RX low = start bit arrives
    reg [7:0] led_out;
    reg led_done_out, led_error_out;

    always @(posedge clk50 or negedge rst_n) begin
        if (!rst_n) begin
            led_out       <= 8'h00;
            led_done_out  <= 1'b0;
            led_error_out <= 1'b0;
        end else begin
            if (uart_start) begin                // new command -> clear old result
                led_done_out  <= 1'b0;
                led_error_out <= 1'b0;
            end
            if (soc_led_done)  begin led_done_out  <= 1'b1; led_out <= soc_led_data; end
            if (soc_led_error) begin led_error_out <= 1'b1; led_out <= 8'hFF;        end
        end
    end

    // ---- On-FPGA encryption cycle counter ----
    // Counts 50 MHz cycles while the SoC AES core is busy; when busy falls,
    // latch the count. After the SoC's 17-byte UART reply finishes, the wrapper
    // transmits the 16-bit count as 2 extra bytes (LSB first).
    reg [15:0] cyc_cnt, cyc_latched;
    reg        was_busy;
    reg [1:0]  cstate;            // 0:IDLE 1:WAIT_TX 2:TX_LO 3:TX_HI
    reg [16:0] wait_cnt;
    reg        tx_sel;            // 0 = SoC TX passes through, 1 = wrapper TX
    reg        wtx_start;
    reg  [7:0] wtx_data;
    reg        wtx_busy_d;
    wire       wtx_busy;
    wire       wtx_tx;

    uart_tx #(.BAUD_DIV(434)) u_wtx (
        .clk(clk50), .rst_n(rst_n),
        .start(wtx_start), .data_in(wtx_data),
        .tx(wtx_tx), .busy(wtx_busy)
    );

    always @(posedge clk50) wtx_busy_d <= wtx_busy;

    always @(posedge clk50 or negedge rst_n) begin
        if (!rst_n) begin
            cyc_cnt    <= 16'd0;
            cyc_latched <= 16'd0;
            was_busy   <= 1'b0;
            cstate     <= 2'd0;
            wait_cnt   <= 17'd0;
            tx_sel     <= 1'b0;
            wtx_start  <= 1'b0;
            wtx_data   <= 8'd0;
        end else begin
            wtx_start <= 1'b0;
            case (cstate)
                2'd0: begin // IDLE: count while SoC busy, latch on falling edge
                    if (soc_led_busy) begin
                        cyc_cnt  <= cyc_cnt + 1'b1;
                        was_busy <= 1'b1;
                    end else if (was_busy) begin
                        cyc_latched <= cyc_cnt;
                        cyc_cnt     <= 16'd0;
                        was_busy    <= 1'b0;
                        wait_cnt    <= 17'd0;
                        cstate      <= 2'd1;
                    end
                end
                2'd1: begin // WAIT: let SoC finish its 17-byte reply (~1.5 ms)
                    wait_cnt <= wait_cnt + 1'b1;
                    if (wait_cnt == 17'd120000) begin // 2.4 ms @ 50 MHz
                        tx_sel    <= 1'b1;
                        wtx_data  <= cyc_latched[7:0];
                        wtx_start <= 1'b1;
                        cstate    <= 2'd2;
                    end
                end
                2'd2: begin // TX_LO: wait for low-byte TX done, then send high byte
                    if (wtx_busy_d && !wtx_busy) begin
                        wtx_data  <= cyc_latched[15:8];
                        wtx_start <= 1'b1;
                        cstate    <= 2'd3;
                    end
                end
                2'd3: begin // TX_HI: high byte sent; hold (line stays idle-high)
                    // no further action
                end
            endcase
        end
    end

    assign uart_tx_pin = tx_sel ? wtx_tx : soc_tx;
    assign led_busy    = soc_led_busy;
    assign led_done    = led_done_out;
    assign led_error   = led_error_out;
    assign led_data    = led_out;
endmodule
