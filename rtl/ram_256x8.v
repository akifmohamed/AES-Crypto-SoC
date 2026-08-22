// ram_256x8.v — synchronous single-port SRAM, 256 x 8 bits (v2: fault-injection port)
// Fault port models a stuck-at fault on one cell: when fault_en is set,
// reads of mem[fault_addr] return the data with bit0 forced to 0
// (stuck-at-0). This is a faithful fault model and works in any simulator.
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
    end

    always @(*) begin
        if (fault_en && addr == fault_addr)
            dout = mem[addr] & ~fault_mask;   // stuck-at-0 on masked bits
        else
            dout = mem[addr];
    end
endmodule
