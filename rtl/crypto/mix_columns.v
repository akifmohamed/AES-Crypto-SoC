<<<<<<< HEAD
// MixColumns - 4 parallel columns
module mix_columns (
    input  wire [127:0] in,
    output wire [127:0] out
);
    mix_column col_0 (.in(in[127:96]), .out(out[127:96]));
    mix_column col_1 (.in(in[95:64]), .out(out[95:64]));
    mix_column col_2 (.in(in[63:32]), .out(out[63:32]));
    mix_column col_3 (.in(in[31:0]), .out(out[31:0]));
=======
// MixColumns - 4 columns in parallel
module mix_columns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    mix_column u_col0 (.col_in(state_in[127:96]), .col_out(state_out[127:96]));
    mix_column u_col1 (.col_in(state_in[95:64]),  .col_out(state_out[95:64]));
    mix_column u_col2 (.col_in(state_in[63:32]),  .col_out(state_out[63:32]));
    mix_column u_col3 (.col_in(state_in[31:0]),   .col_out(state_out[31:0]));
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
