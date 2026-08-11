// Testbench for AES-128 Core against 5 NIST FIPS-197 Test Vectors
`timescale 1ns/1ps
module tb_aes_core;
    reg          clk;
    reg          rst_n;
    reg          start;
    reg  [127:0] key;
    reg  [127:0] plaintext;
    wire [127:0] ciphertext;
    wire         done;
    wire         busy;

    aes_core u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .key(key),
        .plaintext(plaintext),
        .ciphertext(ciphertext),
        .done(done),
        .busy(busy)
    );

    always #10 clk = ~clk; // 50 MHz clock (20ns period)

    reg [127:0] expected_cipher;
    integer pass_count;
    integer fail_count;

    task check_vector(
        input [127:0] t_key,
        input [127:0] t_plain,
        input [127:0] t_expect,
        input [31:0]  vec_num
    );
    begin
        key = t_key;
        plaintext = t_plain;
        expected_cipher = t_expect;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        @(posedge done);
        #1;
        if (ciphertext === expected_cipher) begin
            $display("[PASS] Vector %0d: Ciphertext match %h", vec_num, ciphertext);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Vector %0d: Expected %h, Got %h", vec_num, expected_cipher, ciphertext);
            fail_count = fail_count + 1;
        end
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        key = 0;
        plaintext = 0;
        pass_count = 0;
        fail_count = 0;

        #40 rst_n = 1;
        #20;

        $display("=== STARTING 5 NIST FIPS-197 TEST VECTORS ===");
        // TV1 (NIST Appendix B - Must Memorize)
        check_vector(128'h2B7E151628AED2A6ABF7158809CF4F3C, 128'h6BC1BEE22E409F96E93D7E117393172A, 128'h3AD77BB40D7A3660A89ECAF32466EF97, 1);
        // TV2 (NIST SP 800-38A F.1 ECB Block 2)
        check_vector(128'h2B7E151628AED2A6ABF7158809CF4F3C, 128'hAE2D8A571E03AC9C9EB76FAC45AF8E51, 128'hF5D3D58503B9699DE785895A96FDBAAF, 2);
        // TV3 (NIST SP 800-38A F.1 ECB Block 3)
        check_vector(128'h2B7E151628AED2A6ABF7158809CF4F3C, 128'h30C81C46A35CE411E5FBC1191A0A52EF, 128'h43B1CD7F598ECE23881B00E3ED030688, 3);
        // TV4 (NIST SP 800-38A F.1 ECB Block 4)
        check_vector(128'h2B7E151628AED2A6ABF7158809CF4F3C, 128'hF69F2445DF4F9B17AD2B417BE66C3710, 128'h7B0C785E27E8AD3F8223207104725DD4, 4);
        // TV5 (All Zeros)
        check_vector(128'h00000000000000000000000000000000, 128'h00000000000000000000000000000000, 128'h66E94BD4EF8A2C3B884CFA59CA342B2E, 5);

        $display("=== SUMMARY: %0d/5 PASS, %0d/5 FAIL ===", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("=== ALL NIST FIPS-197 VECTORS PASSED ===");
        end else begin
            $display("=== ERROR: SOME VECTORS FAILED ===");
        end
        $finish;
    end
endmodule
