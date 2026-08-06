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
endmodule
