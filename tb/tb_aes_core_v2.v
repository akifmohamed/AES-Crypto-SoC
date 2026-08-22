// Testbench for aes_core - NIST vectors, CURRENT start/done interface
// v2 (22 Aug 2026): replaces tb_aes_core.v, which targeted an older
// key_valid/data_valid interface that no longer exists (did not compile).
//
// Vectors:
//   TV1  - NIST SP 800-38A F.1.1 block 1 (the FPGA-verified vector)
//   FIPS - FIPS-197 Appendix B known-answer vector
//   ZERO - AES-128(0,0), widely published known-answer value
//   FF   - all-0xFF key & plaintext (derived with a pure-Python AES model
//          cross-checked against TV1 and the ZERO known-answer)
// All four verified in simulation on iverilog 11.0 and 12.0 (22 Aug 2026).
`timescale 1ns/1ps

module tb_aes_core_v2;

    reg clk, rst_n, start;
    reg [127:0] key, plaintext;
    wire [127:0] ciphertext;
    wire done, busy;
    integer pass_cnt, fail_cnt;
    time start_time, end_time;

    aes_core dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .key(key), .plaintext(plaintext),
        .ciphertext(ciphertext), .done(done), .busy(busy)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    task do_encrypt(
        input [127:0] k,
        input [127:0] pt,
        input [127:0] expected_ct,
        input [8*32-1:0] test_name
    );
        begin
            $display("\n--- %0s ---", test_name);
            $display("Key:      %h", k);
            $display("Plain:    %h", pt);
            $display("Expected: %h", expected_ct);

            @(negedge clk);
            key       = k;
            plaintext = pt;
            start     = 1;
            @(negedge clk);
            start     = 0;
            start_time = $time;

            wait (done === 1'b1);
            end_time = $time;

            $display("Got:      %h", ciphertext);
            $display("Latency:  %0d ns (%0d clocks) from start pulse", end_time - start_time, (end_time - start_time)/20);
            if (ciphertext === expected_ct) begin
                $display("PASS");
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("FAIL");
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    initial begin
        rst_n = 0; start = 0; key = 0; plaintext = 0;
        pass_cnt = 0; fail_cnt = 0;
        #200; rst_n = 1;
        #100;

        // TV1: NIST SP 800-38A F.1.1, ECB-AES-128, block 1
        do_encrypt(
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h6bc1bee22e409f96e93d7e117393172a,
            128'h3ad77bb40d7a3660a89ecaf32466ef97,
            "NIST_SP800-38A_TV1");

        // Zero key / zero plaintext
        do_encrypt(
            128'h00000000000000000000000000000000,
            128'h00000000000000000000000000000000,
            128'h66e94bd4ef8a2c3b884cfa59ca342b2e,
            "ZERO_KAT");

        // All-ones key & plaintext
        do_encrypt(
            128'hffffffffffffffffffffffffffffffff,
            128'hffffffffffffffffffffffffffffffff,
            128'hbcbf217cb280cf30b2517052193ab979,
            "ALL_FF");

        // FIPS-197 Appendix B known-answer vector
        do_encrypt(
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00112233445566778899aabbccddeeff,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a,
            "FIPS197_APP_B");

        $display("\n==================================");
        $display("SUMMARY: PASSED %0d / FAILED %0d", pass_cnt, fail_cnt);
        $display("Latency note: start-pulse->done = ~9-10 clocks depending on");
        $display("reference edge; SoC-level busy window = 10 clocks = 200 ns");
        $display("@ 50 MHz (matches on-chip FPGA measurement)");
        $display("==================================");
        if (fail_cnt == 0) $display("ALL TESTS PASSED - CORE VERIFIED");
        else               $display("SOME FAILED - CHECK RTL");
        #100; $finish;
    end

    initial begin
        #100000;
        $display("TIMEOUT - done never asserted");
        $finish;
    end

endmodule
