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
endmodule
