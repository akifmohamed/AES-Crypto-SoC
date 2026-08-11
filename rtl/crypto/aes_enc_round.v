<<<<<<< HEAD
// AES Encryption Round (SubBytes -> ShiftRows -> MixColumns (optional) -> AddRoundKey)
module aes_enc_round (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    input  wire         is_final_round,
    output wire [127:0] state_out
);
    wire [127:0] sub_out;
    wire [127:0] shift_out;
    wire [127:0] mix_out;
    wire [127:0] add_in;

    sub_bytes   u_sub   (.in(state_in),  .out(sub_out));
    shift_rows  u_shift (.in(sub_out),   .out(shift_out));
    mix_columns u_mix   (.in(shift_out), .out(mix_out));

    assign add_in = is_final_round ? shift_out : mix_out;
    add_round_key u_add (.state_in(add_in), .round_key(round_key), .state_out(state_out));
=======
// Complete AES round: SubBytes -> ShiftRows -> MixColumns -> AddRoundKey
// last_round=1 skips MixColumns per FIPS-197
module aes_enc_round (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    input  wire         last_round,
    output wire [127:0] state_out
);
    wire [127:0] after_sub;
    wire [127:0] after_shift;
    wire [127:0] after_mix;

    sub_bytes   u_sub   (.state_in(state_in),   .state_out(after_sub));
    shift_rows  u_shift (.state_in(after_sub),  .state_out(after_shift));
    mix_columns u_mix   (.state_in(after_shift), .state_out(after_mix));

    // Mux: if last round, skip MixColumns
    wire [127:0] before_add = last_round ? after_shift : after_mix;

    add_round_key u_add (.state_in(before_add), .round_key(round_key), .state_out(state_out));
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
