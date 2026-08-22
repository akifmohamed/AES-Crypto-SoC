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
