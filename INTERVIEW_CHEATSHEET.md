# AES SoC Interview Cheatsheet - Memorize This!

## 30-Second Pitch
"AES-128 hardware accelerator SoC in Verilog, 8.2K gates, 1mm2 in 180nm, 11 cycles @50MHz = 220ns per block vs 50,000ns software on MCU, 227x speedup, verified with NIST FIPS-197, full flow Genus/Innovus/Virtuoso to GDSII, FPGA demo via UART."

## Numbers to Rattle Off Instantly
- Gate count: 8,200
- Area: 1mm2, 45% util
- Frequency: 50MHz, 20ns period
- Latency: 11 cycles = 220ns
- SW: 50,000ns -> 227x speedup
- Slack: Setup +2.1ns, Hold +0.15ns, Skew 145ps
- DRC 0, LVS MATCH
- Tech: 180nm, 4-6 metals
- UART: 115200 baud
- Round keys: 11 * 128 = 1408 bits
- S-Box: 256 entries, 16 parallel

## Operation Explanations

**SubBytes:**
- Confusion, non-linear, S-Box lookup, 16 parallel in 1 cycle, generate loop, ~400 gates per S-Box. Case statement 256 entries.

**ShiftRows:**
- Inter-column diffusion, Row0 shift0, Row1 shift1, Row2 shift2, Row3 shift3, pure rewiring, ZERO GATES! assign statement.

**MixColumns:**
- Intra-column diffusion, matrix multiply in GF(2^8), xtime = {in[6:0],0} ^ (in[7]?0x1B:0), b0=2a0^3a1^a2^a3 etc, 4 mix_column parallel. Skip last round per FIPS.

**AddRoundKey:**
- 128-bit XOR, cheapest, state ^ round_key.

**Key Expansion:**
- Input 4 words W0-3, output 44 words W0-43 = 11 round keys.
- For i=4..43: temp=W[i-1], if i%4==0 temp=SubWord(RotWord(temp)) ^ Rcon[i/4], W[i]=W[i-4]^temp
- RotWord [a0,a1,a2,a3]->[a1,a2,a3,a0], SubWord S-Box each byte, Rcon 01,02,04,08,10,20,40,80,1B,36 as {rc,00,00,00}

## FSM
IDLE -> INIT (plaintext ^ RK0) -> ROUND 1-9 (Sub->Shift->Mix->Add) -> FINAL (no Mix) -> DONE -> cipher valid, done pulse, busy indicates encrypting.

Iterative reuses 1 round unit 10 times => area saving.

## UART Protocol
- Commands: 0xAE = encrypt (followed by 16B key + 16B plain -> returns 16B cipher), 0x55 = status -> 0xAA
- RX: 2-FF synchronizer for metastability, sample mid-bit, BAUD_DIV=434 @50MHz.
- TX: 8N1.

## Tools Talking Points
- Cadence Virtuoso licensed - BIG ADVANTAGE over other students.
- Xcelium for simulation, SimVision waves.
- Genus synthesis: read_hdl, elaborate, read_sdc (create_clock 20ns), syn_generic/map/opt, report_timing/area/power.
- Innovus: floorPlan 1000x1000, addRing/addStripe/sroute power, place_design, optDesign preCTS, ccopt_design (CTS skew 145ps), routeDesign, addFiller, verifyConnectivity/Geometry, streamOut GDS.
- Virtuoso: Import GDS, view layers, measure, show for video: full chip, std cell rows, Metal routing, power grid, clock tree.
- FPGA final: Basys3/W5 100MHz -> /2, UART pins A18/B18, LEDs U16/E19/U19 + data V19... etc. iCEstick 12MHz need BAUD_DIV 104.

## Why Iterative not Pipelined?
IoT target = area/power critical. Iterative 8.2K gates low power, 11 cycles acceptable because still 227x faster than SW. Pipelined is 80K gates high power, only needed for server high-throughput 1 block/cycle.

## Security
128-bit key = 2^128 attempts, brute-force longer than universe, no practical attack.

## NIST TV1 to Write From Memory
K=2B7E151628AED2A6ABF7158809CF4F3C
P=6BC1BEE22E409F96E93D7E117393172A
C=3AD77BB40D7A3660A89ECAF32466EF97

## Future Questions
- Power? report_power from Genus/Innovus
- Coverage? All NIST vectors
- Verification methodology? Self-checking TB compares expected
- Challenges? Timing closure, clock tree, metastability in UART -> 2-FF sync

## Resume Bullet
- Designed AES-128 SoC in Verilog (8.2K gates, 1mm², 50MHz, 11-cycle, 220ns) achieving 227x speedup over software, verified with NIST FIPS-197 vectors
- Completed full RTL-to-GDSII flow using Cadence Genus, Innovus, Virtuoso, Xcelium; 0 DRC, LVS MATCH, +2.1ns setup slack
- Demonstrated live encryption on FPGA via UART interface with Python host

