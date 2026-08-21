// ram_256x8.v — synchronous single-port SRAM, 256 x 8 bits
// Purpose: UART RX packet buffer in the AES-128 SoC v2 (gives DFT/MBIST a
// memory target and makes the SoC's UART input realistic/buffered).
// Writes happen on the rising edge when we=1; reads are combinational
// (data_out = mem[addr]) — standard synchronous-write, async-read style,
// which is how OpenRAM-style macros behave in simulation.
// NOTE: for MBIST, the memory is wrapped (see mbist_ctrl.v + ram_wrapper.v).
`timescale 1ns/1ps

module ram_256x8 (
    input  wire        clk,
    input  wire        we,
    input  wire [7:0]  addr,
    input  wire [7:0]  din,
    output reg  [7:0]  dout
);
    reg [7:0] mem [0:255];

    always @(posedge clk) begin
        if (we) mem[addr] <= din;
    end

    always @(*) dout = mem[addr];
endmodule
