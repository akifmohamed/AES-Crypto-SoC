// tb_mbist.v — verifies mbist_ctrl on a 256x8 SRAM via ram_wrapper.
// Two cases:
//   1) clean memory -> PASS
//   2) fault injected (one bit flipped after a write) -> FAIL at that address
`timescale 1ns/1ps

module tb_mbist;
    reg clk, rst_n, go, test_mode;
    wire done, pass, fail;
    wire [7:0] fault_addr;

    // functional port (unused here, tie off)
    reg f_we;
    reg [7:0] f_addr, f_din;
    wire [7:0] f_dout;

    reg m_we;
    reg [7:0] m_addr, m_din;
    wire [7:0] m_dout;

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

    // fault injection hook (drive m_dout override in test)
    // In the wrapper, m_dout comes from the RAM; to inject a fault we use
    // a behavioral override below (m_dout_eff).

    initial clk = 0;
    always #5 clk = ~clk;

    integer faults;

    task run_bist;
        begin
            go <= 0;
            @(posedge clk);
            go <= 1;
            @(posedge clk);
            go <= 0;
            // wait for done
            while (!done) @(posedge clk);
        end
    endtask

    // fault injection: flip bit 0 of address 42's data during step where it holds 1
    // We do this by intercepting m_dout when addr==42 and m_we==0 and it should be 1.
    // Simple approach: corrupt memory via functional port before BIST (stuck-at-0 on bit0 of addr 42).
    reg [7:0] mem_corrupt_addr;
    reg mem_corrupt_en;

    initial begin
        clk = 0; rst_n = 0; go = 0; test_mode = 0;
        f_we = 0; f_addr = 0; f_din = 0; mem_corrupt_en = 0;
        #20;
        rst_n = 1;
        #20;

        // ---- TEST 1: clean memory -> PASS ----
        $display("=== TEST 1: clean memory ===");
        test_mode = 1;
        run_bist;
        $display("done=%b pass=%b fail=%b fault_addr=%0d", done, pass, fail, fault_addr);
        if (pass && !fail) $display("PASS: clean memory detected OK\n");
        else $display("FAIL: clean memory should pass\n");

        // ---- TEST 2: fault injection -> FAIL ----
        $display("=== TEST 2: fault injection (bit0 of addr 42 stuck) ===");
        // reset BIST
        rst_n = 0; #20; rst_n = 1; #20;
        // corrupt: write all 1s to addr 42 via functional port, then force bit0=0
        test_mode = 0;
        f_we = 1; f_addr = 42; f_din = 8'hFF; @(posedge clk); f_we = 0;
        // Now make the RAM cell at addr42 bit0 stuck-at-0 by overriding m_dout
        // when the MBIST reads addr 42 expecting 1s. (Model a stuck-at fault.)
        // We hook m_dout by a force on the net: in simulation we add
        //   force u_wrap.u_ram.mem[42][0] = 0;
        force u_wrap.u_ram.mem[42][0] = 0;
        test_mode = 1;
        run_bist;
        $display("done=%b pass=%b fail=%b fault_addr=%0d", done, pass, fail, fault_addr);
        if (fail) $display("PASS: fault at addr %0d detected", fault_addr);
        else $display("FAIL: fault should have been detected");
        release u_wrap.u_ram.mem[42][0];

        $display("\n=== MBIST verification complete ===");
        $finish;
    end
endmodule
