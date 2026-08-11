// AES Core - Iterative 11-cycle architecture (@50MHz = 220ns)
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
    wire [1407:0] round_keys;
    key_expand u_key_expand (.key(key), .round_keys(round_keys));

    reg [3:0] round_num;
    reg [127:0] current_state;
    reg [127:0] current_round_key;

    always @* begin
        case (round_num)
            4'd0: current_round_key = round_keys[1407:1280];
            4'd1: current_round_key = round_keys[1279:1152];
            4'd2: current_round_key = round_keys[1151:1024];
            4'd3: current_round_key = round_keys[1023:896];
            4'd4: current_round_key = round_keys[895:768];
            4'd5: current_round_key = round_keys[767:640];
            4'd6: current_round_key = round_keys[639:512];
            4'd7: current_round_key = round_keys[511:384];
            4'd8: current_round_key = round_keys[383:256];
            4'd9: current_round_key = round_keys[255:128];
            4'd10: current_round_key = round_keys[127:0];
            default: current_round_key = 128'd0;
        endcase
    end

    wire is_final_round = (round_num == 4'd10);
    wire [127:0] round_out;
    aes_enc_round u_enc_round (
        .state_in(current_state),
        .round_key(current_round_key),
        .is_final_round(is_final_round),
        .state_out(round_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_num     <= 4'd0;
            current_state <= 128'd0;
            ciphertext    <= 128'd0;
            done          <= 1'b0;
            busy          <= 1'b0;
        end else begin
            if (start && !busy) begin
                busy          <= 1'b1;
                done          <= 1'b0;
                round_num     <= 4'd1;
                current_state <= plaintext ^ round_keys[1407:1280]; // Round 0 AddRoundKey
            end else if (busy) begin
                if (round_num < 4'd10) begin
                    current_state <= round_out;
                    round_num     <= round_num + 4'd1;
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
