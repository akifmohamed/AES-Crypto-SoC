// Galois Field GF(2^8) multiplication by 2 (xtime)
module gf_mult2 (
    input  wire [7:0] in,
    output wire [7:0] out
);
    assign out = (in[7]) ? ((in << 1) ^ 8'h1B) : (in << 1);
endmodule
