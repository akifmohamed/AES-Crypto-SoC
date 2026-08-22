// Full SoC testbench - UART protocol level
// v2.1 FIX (22 Aug 2026, verified in sim on iverilog 11.0 & 12.0):
//   BUG in v2: "wait (led_busy == 1)" executed AFTER the ~220ns busy pulse had
//   already passed (TB still in stop-bit + #1000 gap of the 33rd byte while the
//   DUT had already encrypted). wait() missed the pulse deterministically and
//   the TB hung forever. The SoC itself completed the full transaction.
//   FIX: (1) busy pulse captured by a background monitor armed at t=0,
//        (2) TX byte capture forked BEFORE the last plaintext byte is sent.
//   SoC RTL is UNCHANGED - this is a testbench-only fix.
`timescale 1ns/1ps

module tb_aes_soc;

    reg clk, rst_n;
    reg uart_rx_pin;
    wire uart_tx_pin;
    wire led_busy, led_done, led_error;
    wire [7:0] led_data;

    aes_soc dut (
        .clk(clk), .rst_n(rst_n),
        .uart_rx_pin(uart_rx_pin), .uart_tx_pin(uart_tx_pin),
        .led_busy(led_busy), .led_done(led_done),
        .led_error(led_error), .led_data(led_data)
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
            // v2.1 FIX: do NOT add an extra full stop-bit delay here.
            // Loop already ends 1 bit-time after the d7 sample (t0+9.5 bit
            // periods). The DUT starts the next byte at ~t0+10.02 (435-clock
            // bits + ~2-clock inter-byte gap). An extra #BIT_PERIOD would
            // re-arm at t0+10.5 = AFTER the next start edge -> misframe.
        end
    endtask

    reg [7:0] rx_buffer[0:31];
    integer rx_cnt;
    integer i;
    time t_busy_rise, t_busy_fall;   // for cycle measurement
    reg   busy_seen;

    // ---- FIX 1: background monitor for the aes_busy pulse (armed at t=0) ----
    initial begin
        busy_seen    = 1'b0;
        t_busy_rise  = 0;
        t_busy_fall  = 0;
        forever begin
            @(posedge led_busy);
            t_busy_rise = $time;
            busy_seen   = 1'b1;
            @(negedge led_busy);
            t_busy_fall = $time;
        end
    end

    // ---- FIX 3: led_done is a PULSE (cleared when FSM returns to IDLE), ----
    // ---- so catch it in the background too, sampling led_data with it. ----
    reg done_seen;
    reg [7:0] led_data_at_done;
    initial begin
        done_seen       = 1'b0;
        led_data_at_done = 8'd0;
        forever begin
            @(posedge led_done);
            done_seen        = 1'b1;
            led_data_at_done = led_data;
        end
    end

    // ---- FIX 2: TX capture thread (forked before last plaintext byte) ----
    reg tx_capture_done;
    initial tx_capture_done = 1'b0;

    // Global watchdog (safety net - test should finish near 4.5 ms)
    initial begin
        #8_000_000; // 8 ms
        $display("WATCHDOG: test did not finish in 8 ms - FAIL");
        $finish;
    end

    initial begin
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

        // Send 0xAE + key(16) + plaintext(15 of 16) - MSB first
        uart_send_byte(8'hAE);
        uart_send_byte(8'h2b); uart_send_byte(8'h7e); uart_send_byte(8'h15); uart_send_byte(8'h16);
        uart_send_byte(8'h28); uart_send_byte(8'hae); uart_send_byte(8'hd2); uart_send_byte(8'ha6);
        uart_send_byte(8'hab); uart_send_byte(8'hf7); uart_send_byte(8'h15); uart_send_byte(8'h88);
        uart_send_byte(8'h09); uart_send_byte(8'hcf); uart_send_byte(8'h4f); uart_send_byte(8'h3c);
        uart_send_byte(8'h6b); uart_send_byte(8'hc1); uart_send_byte(8'hbe); uart_send_byte(8'he2);
        uart_send_byte(8'h2e); uart_send_byte(8'h40); uart_send_byte(8'h9f); uart_send_byte(8'h96);
        uart_send_byte(8'he9); uart_send_byte(8'h3d); uart_send_byte(8'h7e); uart_send_byte(8'h11);
        uart_send_byte(8'h73); uart_send_byte(8'h93); uart_send_byte(8'h17);

        // Fork the TX capture BEFORE sending the last plaintext byte,
        // so no TX byte can ever be missed.
        fork
            begin : tx_capture
                uart_receive_byte(rx_buffer[16]);  // 0xAA status byte
                for (i=0;i<16;i=i+1) begin
                    uart_receive_byte(rx_buffer[i]);
                end
                tx_capture_done = 1'b1;
            end
            uart_send_byte(8'h2a); // 16th/last plaintext byte
        join

        $display("Waiting for encryption (11 cycles ~220ns + UART TX 16 bytes)");
        // Measure the AES-core busy window using the background monitor
        wait (busy_seen == 1'b1);
        $display("Encryption cycles (aes_busy): %0d (expect 11 -> 220 ns @ 50 MHz)", (t_busy_fall - t_busy_rise)/20);
        // led_done is a short pulse - use the captured flag + sampled data
        wait (done_seen == 1'b1);
        $display("Encryption done! LED data (last byte): %h (expected 97)", led_data_at_done);
        if (led_data_at_done == 8'h97) $display("PASS cipher last byte matches!");
        else $display("FAIL last byte mismatch - check logic");

        // Make sure all 17 TX bytes were captured
        wait (tx_capture_done == 1'b1);
        $display("DUT TX complete (0xAA status + 16 ciphertext bytes)");
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

        $display("Full transaction complete.");
        $finish;
    end

endmodule
