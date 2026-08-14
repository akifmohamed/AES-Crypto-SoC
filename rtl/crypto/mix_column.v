<<<<<<< HEAD
// Single column MixColumns matrix multiplication in GF(2^8)
module mix_column (
    input  wire [31:0] in,
    output wire [31:0] out
);
    wire [7:0] b0 = in[31:24];
    wire [7:0] b1 = in[23:16];
    wire [7:0] b2 = in[15:8];
    wire [7:0] b3 = in[7:0];

    wire [7:0] mb0_2, mb1_2, mb2_2, mb3_2;
    wire [7:0] mb0_3, mb1_3, mb2_3, mb3_3;

    gf_mult2 m02 (.in(b0), .out(mb0_2));
    gf_mult2 m12 (.in(b1), .out(mb1_2));
    gf_mult2 m22 (.in(b2), .out(mb2_2));
    gf_mult2 m32 (.in(b3), .out(mb3_2));

    gf_mult3 m03 (.in(b0), .out(mb0_3));
    gf_mult3 m13 (.in(b1), .out(mb1_3));
    gf_mult3 m23 (.in(b2), .out(mb2_3));
    gf_mult3 m33 (.in(b3), .out(mb3_3));

    assign out[31:24] = mb0_2 ^ mb1_3 ^ b2    ^ b3;
    assign out[23:16] = b0    ^ mb1_2 ^ mb2_3 ^ b3;
    assign out[15:8]  = b0    ^ b1    ^ mb2_2 ^ mb3_3;
    assign out[7:0]   = mb0_3 ^ b1    ^ b2    ^ mb3_2;
=======
// Single column MixColumn
// Matrix multiply per FIPS-197:
// [b0]   [2 3 1 1] [a0]
// [b1] = [1 2 3 1] [a1]
// [b2]   [1 1 2 3] [a2]
// [b3]   [3 1 1 2] [a3]
module mix_column (
    input  wire [31:0] col_in,   // {a0,a1,a2,a3}
    output wire [31:0] col_out   // {b0,b1,b2,b3}
);
    wire [7:0] a0 = col_in[31:24];
    wire [7:0] a1 = col_in[23:16];
    wire [7:0] a2 = col_in[15:8];
    wire [7:0] a3 = col_in[7:0];

    wire [7:0] a0_x2, a1_x2, a2_x2, a3_x2;
    wire [7:0] a0_x3, a1_x3, a2_x3, a3_x3;

    gf_mult2 u_m2_0 (.in(a0), .out(a0_x2));
    gf_mult2 u_m2_1 (.in(a1), .out(a1_x2));
    gf_mult2 u_m2_2 (.in(a2), .out(a2_x2));
    gf_mult2 u_m2_3 (.in(a3), .out(a3_x2));

    gf_mult3 u_m3_0 (.in(a0), .out(a0_x3));
    gf_mult3 u_m3_1 (.in(a1), .out(a1_x3));
    gf_mult3 u_m3_2 (.in(a2), .out(a2_x3));
    gf_mult3 u_m3_3 (.in(a3), .out(a3_x3));

    wire [7:0] b0 = a0_x2 ^ a1_x3 ^ a2 ^ a3;
    wire [7:0] b1 = a0 ^ a1_x2 ^ a2_x3 ^ a3;
    wire [7:0] b2 = a0 ^ a1 ^ a2_x2 ^ a3_x3;
    wire [7:0] b3 = a0_x3 ^ a1 ^ a2 ^ a3_x2;

    assign col_out = {b0, b1, b2, b3};
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
