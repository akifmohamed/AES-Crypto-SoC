<<<<<<< HEAD
// AddRoundKey - 128-bit bitwise XOR
=======
// AddRoundKey - simplest operation: 128-bit XOR
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
module add_round_key (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);
    assign state_out = state_in ^ round_key;
endmodule
