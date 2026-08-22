`timescale 1ns/1ps
module tb_probe;
    reg clk, rst_n, uart_rx_pin;
    wire uart_tx_pin;
    wire led_busy, led_done, led_error;
    wire [7:0] led_data;
    reg scan_en, scan_in;
    wire scan_out;

    aes_soc dut (
        .clk(clk), .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin), .uart_tx_pin(uart_tx_pin),
        .led_busy(led_busy), .led_done(led_done),
        .led_error(led_error), .led_data(led_data),
        .scan_en(scan_en), .scan_in(scan_in), .scan_out(scan_out)
    );

    parameter CLK_FREQ=50_000_000, BAUD=115200, DIV=CLK_FREQ/BAUD, BP=DIV*20;
    task send(input [7:0] b); integer j;
        begin
            uart_rx_pin=0; #BP;
            for (j=0;j<8;j=j+1) begin uart_rx_pin=b[j]; #BP; end
            uart_rx_pin=1; #BP; #1000;
        end
    endtask

    initial begin
        clk=0; rst_n=0; scan_en=0; scan_in=0; uart_rx_pin=1;
        #20; rst_n=1; #20;
        send(8'hAE);
        send(8'h2b); send(8'h7e); send(8'h15); send(8'h16);
        send(8'h28); send(8'hae); send(8'hd2); send(8'ha6);
        send(8'hab); send(8'hf7); send(8'h15); send(8'h88);
        send(8'h09); send(8'hcf); send(8'h4f); send(8'h3c);
        send(8'h6b); send(8'hc1); send(8'hbe); send(8'he2);
        send(8'h2e); send(8'h40); send(8'h9f); send(8'h96);
        send(8'he9); send(8'h3d); send(8'h7e); send(8'h11);
        send(8'h73); send(8'h93); send(8'h17); send(8'h2a);
        #6000000;  // wait 6ms
        $display("state=%0d aes_start=%b aes_done=%b led_done=%b led_data=%02h", dut.state, dut.aes_start, dut.aes_done, dut.led_done, dut.led_data);
        $finish;
    end
    always #5 clk = ~clk;
endmodule
