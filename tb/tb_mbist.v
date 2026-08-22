// tb_mbist_v2.v — verifies mbist_ctrl (v2, sync-safe) on a 256x8 SRAM.
// Test 1: clean memory -> PASS.
// Test 2: stuck-at-0 fault injected at addr 42 bit0 (via a behavioral
//         read-override — NO `force`, works in iverilog) -> FAIL at addr 42.
`timescale 1ns/1ps

module tb_mbist;
    reg clk, rst_n, go, test_mode;
    wire done, pass, fail;
    wire [7:0] fault_addr;

    reg f_we;
    reg [7:0] f_addr, f_din;
    wire [7:0] f_dout;

    wire m_we;
    wire [7:0] m_addr, m_din;
    wire [7:0] m_dout;

    // fault injection control
    reg        fault_en;
    reg [7:0]  fault_addr_i;
    reg [7:0]  fault_bit;   // bitmask to corrupt on read

    mbist_ctrl u_mbist (
        .clk(clk), .rst_n(rst_n), .go(go),
        .m_we(m_we), .m_addr(m_addr), .m_din(m_din), .m_dout(m_dout),
        .done(done), .pass(pass), .fail(fail), .fault_addr(fault_addr)
    );

    ram_wrapper u_wrap (
        .clk(clk), .test_mode(test_mode),
        .f_we(f_we), .f_addr(f_addr), .f_din(f_din), .f_dout(f_dout),
        .m_we(m_we), .m_addr(m_addr), .m_din(m_din), .m_dout(m_dout)
    );

    // Behavioral stuck-at fault injection:
    // when fault_en and the memory is being read at fault_addr_i, corrupt the
    // data on the MBIST read path (AND-out bit0 -> stuck-at-0).
    reg [7:0] m_addr_d;
    always @(posedge clk) m_addr_d <= m_addr;
    assign m_dout = (fault_en && u_wrap.m_dout[0] == 1'b1 && m_addr_d == fault_addr_i)
                  ? (u_wrap.m_dout & ~fault_bit)
                  : u_wrap.m_dout;

    initial clk = 0;
    always #5 clk = ~clk;

    task run_bist;
        begin
            go <= 0; @(posedge clk);
            go <= 1; @(posedge clk);
            go <= 0;
            while (!done) @(posedge clk);
        end
    endtask

    initial begin
        clk = 0; rst_n = 0; go = 0; test_mode = 0;
        f_we = 0; f_addr = 0; f_din = 0;
        fault_en = 0; fault_addr_i = 0; fault_bit = 0;
        #20; rst_n = 1; #20;

        // ---- TEST 1: clean memory ----
        $display("=== TEST 1: clean memory ===");
        test_mode = 1;
        run_bist;
        $display("done=%b pass=%b fail=%b fault_addr=%0d", done, pass, fail, fault_addr);
        if (pass && !fail) $display("PASS: clean memory detected OK\n");
        else $display("FAIL: clean memory should pass\n");

        // ---- TEST 2: stuck-at-0 on addr 42 bit0 ----
        $display("=== TEST 2: fault injection (stuck-at-0, addr 42 bit0) ===");
        rst_n = 0; #20; rst_n = 1; #20;
        fault_en = 1; fault_addr_i = 42; fault_bit = 8'h01;
        test_mode = 1;
        run_bist;
        $display("done=%b pass=%b fail=%b fault_addr=%0d", done, pass, fail, fault_addr);
        if (fail) $display("PASS: fault at addr %0d detected", fault_addr);
        else $display("FAIL: fault should have been detected");
        fault_en = 0;

        $display("\n=== MBIST verification complete ===");
        $finish;
    end
endmodule
