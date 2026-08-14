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
endmodule
