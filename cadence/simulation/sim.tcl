# Cadence Xcelium Simulation Script

# Compile options
# xrun -access +rwc -timescale 1ns/1ps -sv -top tb_aes_core -input sim.tcl

# Probe waves
probe -create -all -shm -depth all
database -open waves -shm

# Run
run

# Save waves
database -close

# Exit
exit
