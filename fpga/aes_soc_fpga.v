// Basys3 wrapper: 100 MHz -> 50 MHz divider + power-on/button reset conditioning
// + LED latch (result stays visible until next UART command or reset)
module aes_soc_fpga (
    input  wire       clk,          // 100 MHz (W5)
    input  wire       btnC,         // press = reset (U18)
    input  wire       uart_rx_pin,  // B18 (from laptop FTDI)
    output wire       uart_tx_pin,  // A18
    output wire       led_busy,     // U16
    output wire       led_done,     // E19
    output wire       led_error,    // U19
    output wire [7:0] led_data      // V19..V15
);
    reg [1:0] div;
    wire clk50 = div[0];
    always @(posedge clk) div <= div + 1'b1;

    reg [3:0] pon;
    always @(posedge clk50) if (!pon[3]) pon <= pon + 1'b1;

    reg b1, b2;
    always @(posedge clk50) begin b1 <= btnC; b2 <= b1; end
    wire rst_n = pon[3] & ~b2;

    // internal SoC LED signals
    wire soc_led_busy, soc_led_done, soc_led_error;
    wire [7:0] soc_led_data;

    aes_soc u_soc (
        .clk(clk50), .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin), .uart_tx_pin(uart_tx_pin),
        .led_busy(soc_led_busy), .led_done(soc_led_done),
        .led_error(soc_led_error), .led_data(soc_led_data)
    );

    // --- LED latch: hold result visible until next UART command or reset ---
    wire uart_start = ~uart_rx_pin;              // RX low = start bit arrives
    reg [7:0] led_out;
    reg led_done_out, led_error_out;

    always @(posedge clk50 or negedge rst_n) begin
        if (!rst_n) begin
            led_out       <= 8'h00;
            led_done_out  <= 1'b0;
            led_error_out <= 1'b0;
        end else begin
            if (uart_start) begin                // new command → clear old result
                led_done_out  <= 1'b0;
                led_error_out <= 1'b0;
            end
            if (soc_led_done)  begin led_done_out  <= 1'b1; led_out <= soc_led_data; end
            if (soc_led_error) begin led_error_out <= 1'b1; led_out <= 8'hFF;        end
        end
    end

    assign led_busy  = soc_led_busy;
    assign led_done  = led_done_out;
    assign led_error = led_error_out;
    assign led_data  = led_out;
endmodule
