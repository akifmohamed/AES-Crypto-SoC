<<<<<<< HEAD
// Galois Field GF(2^8) multiplication by 3
=======
// GF(2^8) multiply by 3 = multiply by 2 xor original
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
module gf_mult3 (
    input  wire [7:0] in,
    output wire [7:0] out
);
    wire [7:0] mult2;
    gf_mult2 u_mult2 (.in(in), .out(mult2));
    assign out = mult2 ^ in;
endmodule
