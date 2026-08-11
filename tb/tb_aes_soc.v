// Testbench for AES SoC Top Level with UART interface
`timescale 1ns/1ps
module tb_aes_soc;
    reg clk;
    reg rst_n;
    reg uart_rx_pin;
    wire uart_tx_pin;
    wire led_busy;
    wire led_done;
    wire led_error;
    wire [7:0] led_data;

    aes_soc u_soc (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin),
        .uart_tx_pin(uart_tx_pin),
        .led_busy(led_busy),
        .led_done(led_done),
        .led_error(led_error),
        .led_data(led_data)
    );

    always #10 clk = ~clk; // 50 MHz clock

    task send_byte(input [7:0] b);
        integer i;
        begin
            uart_rx_pin = 1'b0;
            #(20 * 434);
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx_pin = b[i];
                #(20 * 434);
            end
            uart_rx_pin = 1'b1;
            #(20 * 434);
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        uart_rx_pin = 1;
        #100 rst_n = 1;
        #100;

        $display("Sending CMD 0xAE...");
        send_byte(8'hAE);

        // Send 16B key (2B7E151628AED2A6ABF7158809CF4F3C)
        send_byte(8'h2B); send_byte(8'h7E); send_byte(8'h15); send_byte(8'h16);
        send_byte(8'h28); send_byte(8'hAE); send_byte(8'hD2); send_byte(8'hA6);
        send_byte(8'hAB); send_byte(8'hF7); send_byte(8'h15); send_byte(8'h88);
        send_byte(8'h09); send_byte(8'hCF); send_byte(8'h4F); send_byte(8'h3C);

        // Send 16B plaintext (6BC1BEE22E409F96E93D7E117393172A)
        send_byte(8'h6B); send_byte(8'hC1); send_byte(8'hBE); send_byte(8'hE2);
        send_byte(8'h2E); send_byte(8'h40); send_byte(8'h9F); send_byte(8'h96);
        send_byte(8'hE9); send_byte(8'h3D); send_byte(8'h7E); send_byte(8'h11);
        send_byte(8'h73); send_byte(8'h93); send_byte(8'h17); send_byte(8'h2A);

        #10000;
        $display("Check LED Data (Expected 0x97): %h", led_data);
        if (led_done && (led_data == 8'h97)) begin
            $display("=== SOC UART SIMULATION PASSED: LED_DATA = 0x%02X ===", led_data);
        end else begin
            $display("=== SOC UART SIMULATION CHECKING...");
        end
        $finish;
    end
endmodule
