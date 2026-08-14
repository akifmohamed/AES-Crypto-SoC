// MixColumns - 4 parallel columns
module mix_columns (
    input  wire [127:0] in,
    output wire [127:0] out
);
    mix_column col_0 (.in(in[127:96]), .out(out[127:96]));
    mix_column col_1 (.in(in[95:64]), .out(out[95:64]));
    mix_column col_2 (.in(in[63:32]), .out(out[63:32]));
    mix_column col_3 (.in(in[31:0]), .out(out[31:0]));
endmodule
