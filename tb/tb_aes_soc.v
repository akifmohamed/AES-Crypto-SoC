// Full SoC testbench - UART protocol level (v2: measures encryption cycles + single check)
`timescale 1ns/1ps

module tb_aes_soc;

    reg clk, rst_n;
    reg uart_rx_pin;
    wire uart_tx_pin;
    wire led_busy, led_done, led_error;
    wire [7:0] led_data;

    aes_soc dut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin),
        .uart_tx_pin(uart_tx_pin),
        .led_busy(led_busy),
        .led_done(led_done),
        .led_error(led_error),
        .led_data(led_data)
    );

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

    // Task to receive one byte from DUT TX (sample mid-bit, correct phase)
    task uart_receive_byte(output [7:0] b);
        integer i;
        begin
            @(negedge uart_tx_pin);   // wait for start bit (falling edge)
            #(BIT_PERIOD*3/2);        // move to the MIDDLE of data bit 0
            for (i=0;i<8;i=i+1) begin
                b[i] = uart_tx_pin;   // sample data bits d0..d7
                #BIT_PERIOD;
            end
            #BIT_PERIOD;              // skip stop bit
        end
    endtask

    reg [7:0] rx_buffer[0:31];
    integer rx_cnt;
    integer i;
    time t_start;   // for cycle measurement

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
        // Measure the AES-core busy window (true encryption time)
        wait (led_busy == 1);
        t_start = $time;
        wait (led_busy == 0);
        $display("Encryption cycles (aes_busy): %0d (expect 11 -> 220 ns @ 50 MHz)", ($time - t_start)/20);
        // Wait for done
        wait (led_done == 1);
        $display("Encryption done! LED data (last byte): %h (expected 97)", led_data);
        if (led_data == 8'h97) $display("PASS cipher last byte matches!");
        else $display("FAIL last byte mismatch - check logic");

        // DUT sends 0xAA status byte first, then 16 ciphertext bytes (aes_soc.v state 4'd4/4'd5)
        $display("DUT TX starts (0xAA status + 16 ciphertext bytes)");
        uart_receive_byte(rx_buffer[16]);  // discard the 0xAA status byte
        for (i=0;i<16;i=i+1) begin
            uart_receive_byte(rx_buffer[i]);
        end
        $display("Status byte: %02h", rx_buffer[16]);

        if (rx_buffer[0]==8'h3A && rx_buffer[1]==8'hD7 && rx_buffer[2]==8'h7B && rx_buffer[3]==8'hB4 &&
            rx_buffer[4]==8'h0D && rx_buffer[5]==8'h7A && rx_buffer[6]==8'h36 && rx_buffer[7]==8'h60 &&
            rx_buffer[8]==8'hA8 && rx_buffer[9]==8'h9E && rx_buffer[10]==8'hCA && rx_buffer[11]==8'hF3 &&
            rx_buffer[12]==8'h24 && rx_buffer[13]==8'h66 && rx_buffer[14]==8'hEF && rx_buffer[15]==8'h97)
            $display("PASS: full 16-byte ciphertext matches NIST TV1");
        else begin
            $display("FAIL: ciphertext mismatch");
            for (i=0;i<16;i=i+1) $display("  rx[%0d] = %02h", i, rx_buffer[i]);
        end

        $display("Full transaction complete. Check aes_soc.vcd in GTKWave");
        $finish;
    end

endmodule
