<<<<<<< HEAD
// Galois Field GF(2^8) multiplication by 2 (xtime)
=======
// GF(2^8) multiply by 2 - xtime operation
// AES irreducible polynomial: x^8 + x^4 + x^3 + x + 1 = 0x11B (0x1B reduced)
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
module gf_mult2 (
    input  wire [7:0] in,
    output wire [7:0] out
);
<<<<<<< HEAD
    assign out = (in[7]) ? ((in << 1) ^ 8'h1B) : (in << 1);
=======
    assign out = {in[6:0], 1'b0} ^ (in[7] ? 8'h1b : 8'h00);
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
