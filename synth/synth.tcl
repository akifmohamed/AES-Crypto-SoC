read_liberty -lib -ignore_miss_dir -setattr fold_super_clbs synth/sky130.lib

read_verilog rtl/crypto/aes_sbox.v
read_verilog rtl/crypto/aes_inv_sbox.v
read_verilog rtl/crypto/sub_bytes.v
read_verilog rtl/crypto/shift_rows.v
read_verilog rtl/crypto/gf_mult2.v
read_verilog rtl/crypto/gf_mult3.v
read_verilog rtl/crypto/mix_column.v
read_verilog rtl/crypto/mix_columns.v
read_verilog rtl/crypto/add_round_key.v
read_verilog rtl/crypto/aes_enc_round.v
read_verilog rtl/crypto/key_expand.v
read_verilog rtl/crypto/aes_core.v
read_verilog rtl/peripheral/uart_rx.v
read_verilog rtl/peripheral/uart_tx.v
read_verilog rtl/top/aes_soc.v

hierarchy -check -top aes_soc
proc; opt; fsm; opt; memory; opt
techmap; opt
dfflibmap -liberty synth/sky130.lib
abc -liberty synth/sky130.lib
clean -purge
tee -o synth/synth_report.txt stat -liberty synth/sky130.lib
write_verilog -noattr synth/netlist/aes_soc_synth.v
