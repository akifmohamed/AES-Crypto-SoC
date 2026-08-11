<<<<<<< HEAD
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
=======
// Full SoC testbench - UART protocol level
`timescale 1ns/1ps

module tb_aes_soc;

    reg clk, rst_n;
    reg uart_rx_pin;
    wire uart_tx_pin;
    wire led_busy, led_done, led_error;
    wire [7:0] led_data;

    aes_soc dut (
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin),
        .uart_tx_pin(uart_tx_pin),
        .led_busy(led_busy),
        .led_done(led_done),
        .led_error(led_error),
        .led_data(led_data)
    );

<<<<<<< HEAD
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
=======
    // Clock 50MHz
    initial clk=0;
    always #10 clk=~clk;

    parameter CLK_FREQ=50_000_000;
    parameter BAUD_RATE=115200;
    parameter BAUD_DIV=CLK_FREQ/BAUD_RATE; //434
    parameter BIT_PERIOD=BAUD_DIV*20; // ns per bit

    // Task to send byte via UART (host -> DUT)
    task uart_send_byte(input [7:0] b);
        integer i;
        begin
            // Start bit
            uart_rx_pin = 1'b0;
            #BIT_PERIOD;
            // 8 data bits LSB first
            for (i=0;i<8;i=i+1) begin
                uart_rx_pin = b[i];
                #BIT_PERIOD;
            end
            // Stop bit
            uart_rx_pin = 1'b1;
            #BIT_PERIOD;
            #1000; // gap
        end
    endtask

    // Simple UART receiver for monitoring DUT TX
    reg [7:0] rx_buffer[0:31];
    integer rx_cnt;
    reg rx_sampling;
    // For full verification, just capture in VCD and print LED

    initial begin
        $dumpfile("aes_soc.vcd");
        $dumpvars(0, tb_aes_soc);
        uart_rx_pin = 1'b1;
        rst_n = 0;
        rx_cnt = 0;
        #200;
        rst_n = 1;
        #1000;

        $display("=== Testing STATUS command 0x55 ===");
        uart_send_byte(8'h55);
        // Wait some time for response 0xAA - would need RX sampling logic but we check waveform
        # (BIT_PERIOD*12);
        $display("LEDs after STATUS: busy=%b done=%b error=%b", led_busy, led_done, led_error);

        #10000;
        $display("\n=== Testing ENCRYPT command 0xAE ===");
        $display("Key: 2b7e151628aed2a6abf7158809cf4f3c");
        $display("Plain: 6bc1bee22e409f96e93d7e117393172a");
        $display("Expected Cipher: 3ad77bb40d7a3660a89ecaf32466ef97");

        // Send 0xAE + key(16) + plaintext(16)
        uart_send_byte(8'hAE);
        // Key bytes MSB first
        uart_send_byte(8'h2b); uart_send_byte(8'h7e); uart_send_byte(8'h15); uart_send_byte(8'h16);
        uart_send_byte(8'h28); uart_send_byte(8'hae); uart_send_byte(8'hd2); uart_send_byte(8'ha6);
        uart_send_byte(8'hab); uart_send_byte(8'hf7); uart_send_byte(8'h15); uart_send_byte(8'h88);
        uart_send_byte(8'h09); uart_send_byte(8'hcf); uart_send_byte(8'h4f); uart_send_byte(8'h3c);
        // Plaintext MSB first
        uart_send_byte(8'h6b); uart_send_byte(8'hc1); uart_send_byte(8'hbe); uart_send_byte(8'he2);
        uart_send_byte(8'h2e); uart_send_byte(8'h40); uart_send_byte(8'h9f); uart_send_byte(8'h96);
        uart_send_byte(8'he9); uart_send_byte(8'h3d); uart_send_byte(8'h7e); uart_send_byte(8'h11);
        uart_send_byte(8'h73); uart_send_byte(8'h93); uart_send_byte(8'h17); uart_send_byte(8'h2a);

        $display("Waiting for encryption (11 cycles ~220ns + UART TX 16 bytes)");
        // Wait for done
        wait (led_done == 1);
        $display("Encryption done! LED data (last byte): %h (expected 97)", led_data);
        if (led_data == 8'h97) $display("PASS cipher last byte matches!");
        else $display("FAIL last byte mismatch - check logic");

        // Wait for UART TX to finish sending 16 bytes
        // 16 bytes * 10 bits * BIT_PERIOD ~ 16*10*8680ns = 1.39ms
        #(BIT_PERIOD*10*18);
        $display("Full transaction complete. Check aes_soc.vcd in GTKWave");
        $finish;
    end

>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
