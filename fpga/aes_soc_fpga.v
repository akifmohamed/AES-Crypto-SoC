// Basys3 wrapper: 100 MHz -> 50 MHz divider + power-on/button reset conditioning
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

    aes_soc u_soc (
        .clk(clk50), .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin), .uart_tx_pin(uart_tx_pin),
        .led_busy(led_busy), .led_done(led_done),
        .led_error(led_error), .led_data(led_data)
    );
endmodule
