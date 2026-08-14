// AES Core - Iterative 11-cycle architecture (@50MHz = 220ns) with Pipelined Key Expansion
module aes_core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] plaintext,
    output reg  [127:0] ciphertext,
    output reg          done,
    output reg          busy
);
    reg [3:0]   round_num;
    reg [127:0] current_state;
    reg [127:0] current_round_key;

    wire [127:0] next_round_key;
    key_expand u_key_expand (
        .prev_key(current_round_key),
        .round_num(round_num),
        .next_key(next_round_key)
    );

    wire is_final_round = (round_num == 4'd10);
    wire [127:0] round_out;
    aes_enc_round u_enc_round (
        .state_in(current_state),
        .round_key(next_round_key),
        .is_final_round(is_final_round),
        .state_out(round_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_num         <= 4'd0;
            current_state     <= 128'd0;
            current_round_key <= 128'd0;
            ciphertext        <= 128'd0;
            done              <= 1'b0;
            busy              <= 1'b0;
        end else begin
            if (start && !busy) begin
                busy              <= 1'b1;
                done              <= 1'b0;
                round_num         <= 4'd1;
                current_state     <= plaintext ^ key; // Round 0 AddRoundKey
                current_round_key <= key;
            end else if (busy) begin
                if (round_num < 4'd10) begin
                    current_state     <= round_out;
                    current_round_key <= next_round_key;
                    round_num         <= round_num + 4'd1;
                end else if (round_num == 4'd10) begin
                    ciphertext <= round_out;
                    done       <= 1'b1;
                    busy       <= 1'b0;
                    round_num  <= 4'd0;
                end
            end else begin
                done <= 1'b0;
            end
        end
    end
endmodule
