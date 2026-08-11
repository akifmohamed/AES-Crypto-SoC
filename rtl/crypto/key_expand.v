// Key Expansion - Generates 11 Round Keys (1408 bits total) for AES-128
module key_expand (
    input  wire [127:0] key,
    output wire [1407:0] round_keys
);
    wire [31:0] w [0:43];
    // Round key 0 is original key
    assign w[0] = key[127:96];
    assign w[1] = key[95:64];
    assign w[2] = key[63:32];
    assign w[3] = key[31:0];

    // Round 1 key words (w[4]..w[7])
    wire [31:0] sub_w_4;
    aes_sbox sb_4_0 (.in(w[3][23:16]), .out(sub_w_4[31:24]));
    aes_sbox sb_4_1 (.in(w[3][15:8]),  .out(sub_w_4[23:16]));
    aes_sbox sb_4_2 (.in(w[3][7:0]),   .out(sub_w_4[15:8]));
    aes_sbox sb_4_3 (.in(w[3][31:24]), .out(sub_w_4[7:0]));
    assign w[4]   = w[0] ^ sub_w_4 ^ 32'h01000000;
    assign w[5] = w[1] ^ w[4];
    assign w[6] = w[2] ^ w[5];
    assign w[7] = w[3] ^ w[6];

    // Round 2 key words (w[8]..w[11])
    wire [31:0] sub_w_8;
    aes_sbox sb_8_0 (.in(w[7][23:16]), .out(sub_w_8[31:24]));
    aes_sbox sb_8_1 (.in(w[7][15:8]),  .out(sub_w_8[23:16]));
    aes_sbox sb_8_2 (.in(w[7][7:0]),   .out(sub_w_8[15:8]));
    aes_sbox sb_8_3 (.in(w[7][31:24]), .out(sub_w_8[7:0]));
    assign w[8]   = w[4] ^ sub_w_8 ^ 32'h02000000;
    assign w[9] = w[5] ^ w[8];
    assign w[10] = w[6] ^ w[9];
    assign w[11] = w[7] ^ w[10];

    // Round 3 key words (w[12]..w[15])
    wire [31:0] sub_w_12;
    aes_sbox sb_12_0 (.in(w[11][23:16]), .out(sub_w_12[31:24]));
    aes_sbox sb_12_1 (.in(w[11][15:8]),  .out(sub_w_12[23:16]));
    aes_sbox sb_12_2 (.in(w[11][7:0]),   .out(sub_w_12[15:8]));
    aes_sbox sb_12_3 (.in(w[11][31:24]), .out(sub_w_12[7:0]));
    assign w[12]   = w[8] ^ sub_w_12 ^ 32'h04000000;
    assign w[13] = w[9] ^ w[12];
    assign w[14] = w[10] ^ w[13];
    assign w[15] = w[11] ^ w[14];

    // Round 4 key words (w[16]..w[19])
    wire [31:0] sub_w_16;
    aes_sbox sb_16_0 (.in(w[15][23:16]), .out(sub_w_16[31:24]));
    aes_sbox sb_16_1 (.in(w[15][15:8]),  .out(sub_w_16[23:16]));
    aes_sbox sb_16_2 (.in(w[15][7:0]),   .out(sub_w_16[15:8]));
    aes_sbox sb_16_3 (.in(w[15][31:24]), .out(sub_w_16[7:0]));
    assign w[16]   = w[12] ^ sub_w_16 ^ 32'h08000000;
    assign w[17] = w[13] ^ w[16];
    assign w[18] = w[14] ^ w[17];
    assign w[19] = w[15] ^ w[18];

    // Round 5 key words (w[20]..w[23])
    wire [31:0] sub_w_20;
    aes_sbox sb_20_0 (.in(w[19][23:16]), .out(sub_w_20[31:24]));
    aes_sbox sb_20_1 (.in(w[19][15:8]),  .out(sub_w_20[23:16]));
    aes_sbox sb_20_2 (.in(w[19][7:0]),   .out(sub_w_20[15:8]));
    aes_sbox sb_20_3 (.in(w[19][31:24]), .out(sub_w_20[7:0]));
    assign w[20]   = w[16] ^ sub_w_20 ^ 32'h10000000;
    assign w[21] = w[17] ^ w[20];
    assign w[22] = w[18] ^ w[21];
    assign w[23] = w[19] ^ w[22];

    // Round 6 key words (w[24]..w[27])
    wire [31:0] sub_w_24;
    aes_sbox sb_24_0 (.in(w[23][23:16]), .out(sub_w_24[31:24]));
    aes_sbox sb_24_1 (.in(w[23][15:8]),  .out(sub_w_24[23:16]));
    aes_sbox sb_24_2 (.in(w[23][7:0]),   .out(sub_w_24[15:8]));
    aes_sbox sb_24_3 (.in(w[23][31:24]), .out(sub_w_24[7:0]));
    assign w[24]   = w[20] ^ sub_w_24 ^ 32'h20000000;
    assign w[25] = w[21] ^ w[24];
    assign w[26] = w[22] ^ w[25];
    assign w[27] = w[23] ^ w[26];

    // Round 7 key words (w[28]..w[31])
    wire [31:0] sub_w_28;
    aes_sbox sb_28_0 (.in(w[27][23:16]), .out(sub_w_28[31:24]));
    aes_sbox sb_28_1 (.in(w[27][15:8]),  .out(sub_w_28[23:16]));
    aes_sbox sb_28_2 (.in(w[27][7:0]),   .out(sub_w_28[15:8]));
    aes_sbox sb_28_3 (.in(w[27][31:24]), .out(sub_w_28[7:0]));
    assign w[28]   = w[24] ^ sub_w_28 ^ 32'h40000000;
    assign w[29] = w[25] ^ w[28];
    assign w[30] = w[26] ^ w[29];
    assign w[31] = w[27] ^ w[30];

    // Round 8 key words (w[32]..w[35])
    wire [31:0] sub_w_32;
    aes_sbox sb_32_0 (.in(w[31][23:16]), .out(sub_w_32[31:24]));
    aes_sbox sb_32_1 (.in(w[31][15:8]),  .out(sub_w_32[23:16]));
    aes_sbox sb_32_2 (.in(w[31][7:0]),   .out(sub_w_32[15:8]));
    aes_sbox sb_32_3 (.in(w[31][31:24]), .out(sub_w_32[7:0]));
    assign w[32]   = w[28] ^ sub_w_32 ^ 32'h80000000;
    assign w[33] = w[29] ^ w[32];
    assign w[34] = w[30] ^ w[33];
    assign w[35] = w[31] ^ w[34];

    // Round 9 key words (w[36]..w[39])
    wire [31:0] sub_w_36;
    aes_sbox sb_36_0 (.in(w[35][23:16]), .out(sub_w_36[31:24]));
    aes_sbox sb_36_1 (.in(w[35][15:8]),  .out(sub_w_36[23:16]));
    aes_sbox sb_36_2 (.in(w[35][7:0]),   .out(sub_w_36[15:8]));
    aes_sbox sb_36_3 (.in(w[35][31:24]), .out(sub_w_36[7:0]));
    assign w[36]   = w[32] ^ sub_w_36 ^ 32'h1B000000;
    assign w[37] = w[33] ^ w[36];
    assign w[38] = w[34] ^ w[37];
    assign w[39] = w[35] ^ w[38];

    // Round 10 key words (w[40]..w[43])
    wire [31:0] sub_w_40;
    aes_sbox sb_40_0 (.in(w[39][23:16]), .out(sub_w_40[31:24]));
    aes_sbox sb_40_1 (.in(w[39][15:8]),  .out(sub_w_40[23:16]));
    aes_sbox sb_40_2 (.in(w[39][7:0]),   .out(sub_w_40[15:8]));
    aes_sbox sb_40_3 (.in(w[39][31:24]), .out(sub_w_40[7:0]));
    assign w[40]   = w[36] ^ sub_w_40 ^ 32'h36000000;
    assign w[41] = w[37] ^ w[40];
    assign w[42] = w[38] ^ w[41];
    assign w[43] = w[39] ^ w[42];

    assign round_keys[1407:1280] = { w[0], w[1], w[2], w[3] };
    assign round_keys[1279:1152] = { w[4], w[5], w[6], w[7] };
    assign round_keys[1151:1024] = { w[8], w[9], w[10], w[11] };
    assign round_keys[1023:896] = { w[12], w[13], w[14], w[15] };
    assign round_keys[895:768] = { w[16], w[17], w[18], w[19] };
    assign round_keys[767:640] = { w[20], w[21], w[22], w[23] };
    assign round_keys[639:512] = { w[24], w[25], w[26], w[27] };
    assign round_keys[511:384] = { w[28], w[29], w[30], w[31] };
    assign round_keys[383:256] = { w[32], w[33], w[34], w[35] };
    assign round_keys[255:128] = { w[36], w[37], w[38], w[39] };
    assign round_keys[127:0] = { w[40], w[41], w[42], w[43] };
endmodule
