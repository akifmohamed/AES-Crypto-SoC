# Synthesis Script for AES-128 Crypto Accelerator SoC (Yosys + Sky130 PDK)
yosys -import

# 1. Read standard cell liberty file
read_liberty -lib -ignore_miss_dir -setattr fold_super_clbs synth/sky130.lib

# 2. Read Verilog RTL files (bottom-up hierarchy order)
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

# 3. Check hierarchy and set top module
hierarchy -check -top aes_soc

# 4. High-level synthesis & optimization
proc; opt; fsm; opt; memory; opt

# 5. Technology mapping to standard logic gates
techmap; opt

# 6. Map D-Flip Flops to Sky130 cells
dfflibmap -liberty synth/sky130.lib

# 7. Map combinational logic to Sky130 standard cells
abc -liberty synth/sky130.lib

# 8. Clean up and report statistics
clean -purge
stat -liberty synth/sky130.lib -tee synth/synth_report.txt

# 9. Write synthesized gate-level netlist
write_verilog -noattr synth/netlist/aes_soc_synth.v
