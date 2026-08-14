<<<<<<< HEAD
// ShiftRows module - Pure interconnect wiring (0 standard cells / 0 area!)
module shift_rows (
    input  wire [127:0] in,
    output wire [127:0] out
);
    // Row 0: No shift (bytes 0, 4, 8, 12)
    assign out[127:120] = in[127:120];
    assign out[95:88]   = in[95:88];
    assign out[63:56]   = in[63:56];
    assign out[31:24]   = in[31:24];

    // Row 1: Shift left by 1 (bytes 1, 5, 9, 13 -> 5, 9, 13, 1)
    assign out[119:112] = in[87:80];
    assign out[87:80]   = in[55:48];
    assign out[55:48]   = in[23:16];
    assign out[23:16]   = in[119:112];

    // Row 2: Shift left by 2 (bytes 2, 6, 10, 14 -> 10, 14, 2, 6)
    assign out[111:104] = in[47:40];
    assign out[79:72]   = in[15:8];
    assign out[47:40]   = in[111:104];
    assign out[15:8]    = in[79:72];

    // Row 3: Shift left by 3 (bytes 3, 7, 11, 15 -> 15, 3, 7, 11)
    assign out[103:96]  = in[7:0];
    assign out[71:64]   = in[103:96];
    assign out[39:32]   = in[71:64];
    assign out[7:0]     = in[39:32];
=======
// ─────────────────────────────────────────────────────────
// ShiftRows - Pure wiring, zero logic gates!
// Row0: shift 0, Row1: shift 1, Row2: shift 2, Row3: shift 3
// State representation: column-major, big-endian
// 128b = {s0,s1,s2,s3, s4,s5,s6,s7, s8,s9,s10,s11, s12,s13,s14,s15}
// s0 = byte[0][0], s1=[1][0], s2=[2][0], s3=[3][0] etc.
// ─────────────────────────────────────────────────────────
module shift_rows (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    wire [7:0] s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15;
    wire [7:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15;

    assign s0  = state_in[127:120];
    assign s1  = state_in[119:112];
    assign s2  = state_in[111:104];
    assign s3  = state_in[103:96];
    assign s4  = state_in[95:88];
    assign s5  = state_in[87:80];
    assign s6  = state_in[79:72];
    assign s7  = state_in[71:64];
    assign s8  = state_in[63:56];
    assign s9  = state_in[55:48];
    assign s10 = state_in[47:40];
    assign s11 = state_in[39:32];
    assign s12 = state_in[31:24];
    assign s13 = state_in[23:16];
    assign s14 = state_in[15:8];
    assign s15 = state_in[7:0];

    // Row shifts - this is the AES ShiftRows matrix
    assign d0  = s0;   // row0 col0 -> row0 col0
    assign d1  = s5;   // row1 col0 -> row1 col1
    assign d2  = s10;  // row2 col0 -> row2 col2
    assign d3  = s15;  // row3 col0 -> row3 col3
    assign d4  = s4;   // row0 col1
    assign d5  = s9;
    assign d6  = s14;
    assign d7  = s3;
    assign d8  = s8;   // row0 col2
    assign d9  = s13;
    assign d10 = s2;
    assign d11 = s7;
    assign d12 = s12;  // row0 col3
    assign d13 = s1;
    assign d14 = s6;
    assign d15 = s11;

    assign state_out = {d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15};
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
endmodule
