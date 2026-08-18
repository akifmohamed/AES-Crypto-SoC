module de0_wrapper (
    input  wire clk,
    input  wire btn,
    output wire uart_tx,
    input  wire uart_rx,
    output wire [9:0] led
);
    reg [3:0] pon; always @(posedge clk) if (!pon[3]) pon <= pon + 1;
    reg b1, b2;  always @(posedge clk) begin b1 <= btn; b2 <= b1; end
    wire rst_n = pon[3] & ~b2;

    wire led_busy, led_done, led_error; wire [7:0] led_data;
    aes_soc u_soc (.clk(clk), .rst_n(rst_n),
        .uart_rx_pin(uart_rx), .uart_tx_pin(uart_tx),
        .led_busy(led_busy), .led_done(led_done),
        .led_error(led_error), .led_data(led_data));

    assign led = {led_done | led_error, led_busy, led_data};
endmodule