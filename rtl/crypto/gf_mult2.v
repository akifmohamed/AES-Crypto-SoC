// GF(2^8) multiply by 2 - xtime operation
// AES irreducible polynomial: x^8 + x^4 + x^3 + x + 1 = 0x11B (0x1B reduced)
module gf_mult2 (
    input  wire [7:0] in,
    output wire [7:0] out
);
    assign out = {in[6:0], 1'b0} ^ (in[7] ? 8'h1b : 8'h00);
endmodule
