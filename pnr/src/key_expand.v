// Iterative 1-Round Key Expansion for AES-128
module key_expand (
    input  wire [127:0] prev_key,
    input  wire [3:0]   round_num,
    output wire [127:0] next_key
);
    wire [31:0] w0 = prev_key[127:96];
    wire [31:0] w1 = prev_key[95:64];
    wire [31:0] w2 = prev_key[63:32];
    wire [31:0] w3 = prev_key[31:0];

    wire [7:0] rcon;
    assign rcon = (round_num == 4'd1)  ? 8'h01 :
                  (round_num == 4'd2)  ? 8'h02 :
                  (round_num == 4'd3)  ? 8'h04 :
                  (round_num == 4'd4)  ? 8'h08 :
                  (round_num == 4'd5)  ? 8'h10 :
                  (round_num == 4'd6)  ? 8'h20 :
                  (round_num == 4'd7)  ? 8'h40 :
                  (round_num == 4'd8)  ? 8'h80 :
                  (round_num == 4'd9)  ? 8'h1B :
                  (round_num == 4'd10) ? 8'h36 : 8'h00;

    wire [31:0] sub_w;
    aes_sbox sb0 (.in(w3[23:16]), .out(sub_w[31:24]));
    aes_sbox sb1 (.in(w3[15:8]),  .out(sub_w[23:16]));
    aes_sbox sb2 (.in(w3[7:0]),   .out(sub_w[15:8]));
    aes_sbox sb3 (.in(w3[31:24]), .out(sub_w[7:0]));

    wire [31:0] w4 = w0 ^ sub_w ^ {rcon, 24'h000000};
    wire [31:0] w5 = w1 ^ w4;
    wire [31:0] w6 = w2 ^ w5;
    wire [31:0] w7 = w3 ^ w6;

    assign next_key = {w4, w5, w6, w7};
endmodule
