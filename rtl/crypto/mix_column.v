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
endmodule
