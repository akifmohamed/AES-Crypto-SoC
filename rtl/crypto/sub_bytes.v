<<<<<<< HEAD
// SubBytes module - 16 parallel AES S-Box instantiations
module sub_bytes (
    input  wire [127:0] in,
    output wire [127:0] out
);
    aes_sbox sbox_0 (.in(in[127:120]), .out(out[127:120]));
    aes_sbox sbox_1 (.in(in[119:112]), .out(out[119:112]));
    aes_sbox sbox_2 (.in(in[111:104]), .out(out[111:104]));
    aes_sbox sbox_3 (.in(in[103:96]), .out(out[103:96]));
    aes_sbox sbox_4 (.in(in[95:88]), .out(out[95:88]));
    aes_sbox sbox_5 (.in(in[87:80]), .out(out[87:80]));
    aes_sbox sbox_6 (.in(in[79:72]), .out(out[79:72]));
    aes_sbox sbox_7 (.in(in[71:64]), .out(out[71:64]));
    aes_sbox sbox_8 (.in(in[63:56]), .out(out[63:56]));
    aes_sbox sbox_9 (.in(in[55:48]), .out(out[55:48]));
    aes_sbox sbox_10 (.in(in[47:40]), .out(out[47:40]));
    aes_sbox sbox_11 (.in(in[39:32]), .out(out[39:32]));
    aes_sbox sbox_12 (.in(in[31:24]), .out(out[31:24]));
    aes_sbox sbox_13 (.in(in[23:16]), .out(out[23:16]));
    aes_sbox sbox_14 (.in(in[15:8]), .out(out[15:8]));
    aes_sbox sbox_15 (.in(in[7:0]), .out(out[7:0]));
=======
// ─────────────────────────────────────────────────────────
// SubBytes - 16 parallel S-Boxes
// All 16 state bytes substituted in ONE cycle
// HW cost: 16 * S-Box LUT (~400 gates each)
// ─────────────────────────────────────────────────────────
module sub_bytes (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sbox
            // Big-endian: byte 0 = bits [127:120]
            aes_sbox u_sbox (
                .in (state_in[127 - i*8 -: 8]),
                .out(state_out[127 - i*8 -: 8])
            );
        end
    endgenerate
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
