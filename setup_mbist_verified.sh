#!/bin/bash
set -e
cat > rtl/ram_256x8.v << 'V1'
// ram_256x8.v — synchronous single-port SRAM, 256 x 8 bits (v3: registered read + fault port)
// - writes on rising edge when we=1
// - dout is REGISTERED (read on rising edge) — matches the MBIST controller's
//   pipelined read (rd_data <= m_dout)
// - fault port: when fault_en and addr==fault_addr, the read returns
//   data & ~fault_mask (stuck-at-0 on masked bits) — applied at the read,
//   so it is deterministic and synchronous.
`timescale 1ns/1ps

module ram_256x8 (
    input  wire        clk,
    input  wire        we,
    input  wire [7:0]  addr,
    input  wire [7:0]  din,
    output reg  [7:0]  dout,
    // fault injection (DFT verification only)
    input  wire        fault_en,
    input  wire [7:0]  fault_addr,
    input  wire [7:0]  fault_mask
);
    reg [7:0] mem [0:255];

    always @(posedge clk) begin
        if (we) mem[addr] <= din;
        if (fault_en && addr == fault_addr)
            dout <= mem[addr] & ~fault_mask;   // stuck-at-0 on masked bits
        else
            dout <= mem[addr];
    end
endmodule
V1
cat > rtl/ram_wrapper.v << 'V2'
// ram_wrapper.v — MBIST wrapper around ram_256x8 (v2: fault ports pass-through)
// test_mode=0: functional access (f_*)
// test_mode=1: MBIST access (m_*)
// fault_* ports pass through to the RAM (DFT fault injection)
`timescale 1ns/1ps

module ram_wrapper #(
    parameter AW = 8,
    parameter DW = 8
)(
    input  wire        clk,
    input  wire        test_mode,
    // functional port
    input  wire        f_we,
    input  wire [AW-1:0] f_addr,
    input  wire [DW-1:0] f_din,
    output wire [DW-1:0] f_dout,
    // MBIST port
    input  wire        m_we,
    input  wire [AW-1:0] m_addr,
    input  wire [DW-1:0] m_din,
    output wire [DW-1:0] m_dout,
    // fault injection (DFT)
    input  wire        fault_en,
    input  wire [AW-1:0] fault_addr,
    input  wire [DW-1:0] fault_mask
);
    wire        we   = test_mode ? m_we   : f_we;
    wire [AW-1:0] addr = test_mode ? m_addr : f_addr;
    wire [DW-1:0] din  = test_mode ? m_din  : f_din;
    wire [DW-1:0] dout;

    ram_256x8 u_ram (
        .clk        (clk),
        .we         (we),
        .addr       (addr),
        .din        (din),
        .dout       (dout),
        .fault_en   (fault_en),
        .fault_addr (fault_addr),
        .fault_mask (fault_mask)
    );

    assign f_dout = test_mode ? {DW{1'b0}} : dout;
    assign m_dout = test_mode ? dout : {DW{1'b0}};
endmodule
V2
cat > rtl/mbist_ctrl.v << 'V3'
// mbist_ctrl.v — March C- BIST controller (VERIFIED in simulation)
// Read pipeline: sub=0 addr out -> sub=1 wait -> sub=2 wait -> sub=3 check+write
// (2 registers in read path: RAM dout + rd_data => need 2 wait cycles)
// March C-: up W0, up R0W1, up R1W0, down R0W1, down R1W0, down R0
`timescale 1ns/1ps

module mbist_ctrl #(
    parameter AW = 8,
    parameter DW = 8
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        go,
    output reg         m_we,
    output reg  [AW-1:0] m_addr,
    output reg  [DW-1:0] m_din,
    input  wire [DW-1:0] m_dout,
    output reg         done,
    output reg         pass,
    output reg         fail,
    output reg  [AW-1:0] fault_addr
);
    reg [2:0]  step;        // 0..5
    reg        down;
    reg [AW-1:0] addr;
    reg [1:0]  sub;         // 0=addr, 1=wait, 2=wait, 3=check
    reg [DW-1:0] rd_data;
    reg        running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            step <= 0; down <= 0; addr <= 0; sub <= 0;
            rd_data <= 0; running <= 0;
            m_we <= 0; m_addr <= 0; m_din <= 0;
            done <= 0; pass <= 0; fail <= 0; fault_addr <= 0;
        end else begin
            m_we <= 0;
            rd_data <= m_dout;
            if (!running) begin
                if (go) begin
                    running <= 1; done <= 0; pass <= 0; fail <= 0;
                    step <= 0; down <= 0; addr <= 0; sub <= 0;
                end
            end else begin
                case (step)
                    0: begin // up W0
                        m_we <= 1; m_addr <= addr; m_din <= 0;
                        if (addr == {AW{1'b1}}) begin step <= 1; addr <= 0; end
                        else addr <= addr + 1;
                    end
                    1,2,3,4: begin // R<exp> W<val>
                        case (sub)
                            0: begin m_we <= 0; m_addr <= addr; sub <= 1; end
                            1: begin sub <= 2; end
                            2: begin sub <= 3; end
                            3: begin
                                if (step == 1 || step == 3) begin // expect 0, write FF
                                    if (rd_data != {DW{1'b0}}) begin fail_state(addr); end
                                    m_din <= {DW{1'b1}};
                                end else begin // expect FF, write 0
                                    if (rd_data != {DW{1'b1}}) begin fail_state(addr); end
                                    m_din <= {DW{1'b0}};
                                end
                                m_we <= 1; m_addr <= addr;
                                sub <= 0;
                                if (!down) begin
                                    if (addr == {AW{1'b1}}) begin
                                        if (step == 2) begin step <= 3; down <= 1; addr <= {AW{1'b1}}; end
                                        else begin step <= step + 1; addr <= 0; end
                                    end else addr <= addr + 1;
                                end else begin
                                    if (addr == {AW{1'b0}}) begin
                                        if (step == 4) begin step <= 5; addr <= {AW{1'b1}}; end
                                        else begin step <= step + 1; addr <= {AW{1'b1}}; end
                                    end else addr <= addr - 1;
                                end
                            end
                        endcase
                    end
                    5: begin // down R0
                        case (sub)
                            0: begin m_we <= 0; m_addr <= addr; sub <= 1; end
                            1: begin sub <= 2; end
                            2: begin sub <= 3; end
                            3: begin
                                if (rd_data != {DW{1'b0}}) begin fail_state(addr); end
                                sub <= 0;
                                if (addr == {AW{1'b0}}) begin done <= 1; pass <= 1; running <= 0; end
                                else addr <= addr - 1;
                            end
                        endcase
                    end
                endcase
            end
        end
    end

    task fail_state(input [AW-1:0] a);
        begin
            fail <= 1; fault_addr <= a; done <= 1; running <= 0;
        end
    endtask

endmodule
V3
cat > tb/tb_mbist.v << 'V4'
// tb_mbist_v3.v — final MBIST testbench with guaranteed fault injection.
// Fault is modeled INSIDE the RAM (stuck-at-0 on addr 42 bit0) via the
// ram_256x8 fault port — no read-bus interception, no timing coupling.
// Test 1: clean (fault_en=0) -> PASS
// Test 2: fault (stuck-at-0 @42) -> FAIL at addr 42
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

    // fault injection control (to RAM)
    reg        fault_en;
    reg [7:0]  fault_addr_i;
    reg [7:0]  fault_mask;

    mbist_ctrl u_mbist (
        .clk(clk), .rst_n(rst_n), .go(go),
        .m_we(m_we), .m_addr(m_addr), .m_din(m_din), .m_dout(m_dout),
        .done(done), .pass(pass), .fail(fail), .fault_addr(fault_addr)
    );

    ram_wrapper u_wrap (
        .clk(clk), .test_mode(test_mode),
        .f_we(f_we), .f_addr(f_addr), .f_din(f_din), .f_dout(f_dout),
        .m_we(m_we), .m_addr(m_addr), .m_din(m_din), .m_dout(m_dout),
        .fault_en(fault_en), .fault_addr(fault_addr_i), .fault_mask(fault_mask)
    );

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
        fault_en = 0; fault_addr_i = 0; fault_mask = 0;
        #20; rst_n = 1; #20;

        // ---- TEST 1: clean memory ----
        $display("=== TEST 1: clean memory ===");
        test_mode = 1;
        run_bist;
        $display("done=%b pass=%b fail=%b fault_addr=%0d", done, pass, fail, fault_addr);
        if (pass && !fail) $display("PASS: clean memory detected OK\n");
        else $display("FAIL: clean memory should pass\n");

        // ---- TEST 2: stuck-at-0 on addr 42 bit0 (via RAM fault port) ----
        $display("=== TEST 2: fault injection (stuck-at-0, addr 42 bit0) ===");
        rst_n = 0; #20; rst_n = 1; #20;
        fault_en = 1; fault_addr_i = 42; fault_mask = 8'h01;
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
V4
echo "--- all 4 files written ---"
iverilog -o tb_mbist.vvp rtl/ram_256x8.v rtl/ram_wrapper.v rtl/mbist_ctrl.v tb/tb_mbist.v
vvp tb_mbist.vvp
