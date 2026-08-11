// Galois Field GF(2^8) multiplication by 3
module gf_mult3 (
    input  wire [7:0] in,
    output wire [7:0] out
);
    wire [7:0] mult2;
    gf_mult2 u_mult2 (.in(in), .out(mult2));
    assign out = mult2 ^ in;
endmodule
