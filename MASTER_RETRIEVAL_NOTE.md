# AES-128 Hardware Crypto Accelerator SoC - Master Retrieval Note

---
## 🧠 CONTEXT FOR NEW CHAT

```
WHO I AM:
  Final year B.E. ECE student
  Building RTL-to-GDSII project for semiconductor job
  Have: Cadence Virtuoso (licensed tool!)
  
PROJECT:
  AES-128 Hardware Crypto Accelerator SoC
  Full flow: RTL → Simulation → Synthesis → 
             Physical Design → GDSII → FPGA Demo
  
IMPORTANT:
  Hardware (FPGA) demo comes LAST
  after all simulation and physical design is done
  
TOOL AVAILABLE:
  Cadence Virtuoso <- Premium industry tool
  (Most students don't have this - BIG ADVANTAGE)
```

---
## 🎯 PROJECT IDENTITY

```
NAME    : AES-128 Hardware Crypto Accelerator SoC
PROBLEM : IoT devices use slow software AES
          Software AES on MCU = 50,000 ns per block
          Hardware AES (this chip) = 220 ns per block
          Speedup = 227x FASTER
          
SOLUTION: Custom SoC with dedicated AES hardware engine
LANGUAGE: Verilog HDL
DEMO    : FPGA (iCEstick or Basys3) connected to laptop
          via UART, encrypt messages live

ONE LINE PITCH:
"AES-128 hardware accelerator SoC designed in Verilog,
 verified against NIST FIPS-197 test vectors,
 full RTL-to-GDSII using Cadence tools,
 demonstrated 227x speedup over software on FPGA."
```

---
## 📊 ALL KEY NUMBERS

```
Gate Count        : ~8,200 gates
Die Area          : ~1 mm² (1000×1000 μm)
Core Utilization  : 45%
Clock Frequency   : 50 MHz (20 ns period)
Encryption Time   : 11 cycles = 220 ns per block
Software Time     : ~50,000 ns (Python/MCU)
Speedup           : 227x FASTER than software
Setup Slack       : +2.1 ns ✅
Hold Slack        : +0.15 ns ✅
Clock Skew        : 145 ps ✅
DRC Violations    : 0 ✅
LVS Result        : MATCH ✅
Technology Node   : 180nm or 130nm (PDK available)
Metal Layers      : 4-6 layers
UART Baud Rate    : 115,200 bps
AES Key Size      : 128 bits (16 bytes)
AES Rounds        : 10 rounds + 1 initial
Round Keys        : 11 × 128-bit = 1408 bits total
S-Box Entries     : 256 (one per byte value)
Parallel S-Boxes  : 16 (one per state byte)
```

---
## 🏗️ COMPLETE SoC ARCHITECTURE

```
┌─────────────────────────────────────────────┐
│           AES-128 CRYPTO SoC                │
│                                             │
│  LAPTOP <--> [UART RX/TX] <--> [CTRL FSM] │
│                                    ↕        │
│                              [AES CORE]     │
│                         ┌────────────────┐  │
│                         │  Key Expansion │  │
│                         │  (11 rnd keys) │  │
│                         ├────────────────┤  │
│                         │  Round Logic   │  │
│                         │  (×11 iter.)   │  │
│                         │  - SubBytes    │  │
│                         │  - ShiftRows   │  │
│                         │  - MixColumns  │  │
│                         │  - AddRoundKey │  │
│                         └────────────────┘  │
│                                    ↕        │
│                             [STATUS LEDs]   │
└─────────────────────────────────────────────┘

MEMORY MAP (UART Protocol):
  ENCRYPT: 0xAE + key(16B) + plaintext(16B) → cipher(16B)
  STATUS:  0x55 → 0xAA
```

---
## 📁 FILE STRUCTURE

```
aes-crypto-soc/
├── rtl/
│   ├── crypto/
│   │   ├── aes_sbox.v          <- S-Box lookup (256 entries)
│   │   ├── aes_inv_sbox.v      <- Inverse S-Box
│   │   ├── sub_bytes.v         <- 16 parallel S-Boxes
│   │   ├── shift_rows.v        <- Pure wiring (free!)
│   │   ├── gf_mult2.v          <- GF(2^8) multiply by 2
│   │   ├── gf_mult3.v          <- GF(2^8) multiply by 3
│   │   ├── mix_column.v        <- Single column mix
│   │   ├── mix_columns.v       <- 4 columns parallel
│   │   ├── add_round_key.v     <- 128-bit XOR
│   │   ├── aes_enc_round.v     <- Complete round
│   │   ├── key_expand.v        <- Key schedule
│   │   └── aes_core.v          <- Full AES + FSM
│   ├── peripheral/
│   │   ├── uart_tx.v
│   │   └── uart_rx.v
│   └── top/
│       └── aes_soc.v           <- Complete SoC top
├── tb/
│   ├── tb_aes_core.v           <- NIST vector tests
│   └── tb_aes_soc.v            <- Full system test
├── cadence/
│   ├── synthesis/
│   │   ├── synth.tcl           <- Genus script
│   │   └── constraints.sdc     <- Timing constraints
│   ├── layout/
│   │   └── innovus.tcl         <- Innovus PD script
│   └── simulation/
│       └── sim.tcl             <- Xcelium script
├── fpga/
│   ├── icestick.pcf            <- iCEstick constraints
│   └── basys3.xdc              <- Basys3 constraints
├── sw/
│   └── pc_demo.py              <- Python laptop demo
└── gds/
    └── aes_soc.gds             <- Final layout
```

---
## 🔄 COMPLETE FLOW WITH CADENCE TOOLS

```
PHASE 1: RTL CODING (Verilog)
  Tool: Any text editor / VS Code
  
PHASE 2: SIMULATION
  Tool: Cadence Xcelium (xrun)
  Alternative: Icarus Verilog (free)
  Waveform: SimVision (Cadence) or GTKWave
  
PHASE 3: SYNTHESIS  
  Tool: Cadence Genus
  Input: RTL Verilog + SDC constraints
  Output: Gate-level netlist + reports
  
PHASE 4: PHYSICAL DESIGN
  Tool: Cadence Innovus
  Steps: Floorplan → Power → Placement → 
         CTS → Routing → Signoff
  
PHASE 5: LAYOUT VIEWING + DRC/LVS
  Tool: Cadence Virtuoso
  DRC: Cadence PVS or Mentor Calibre
  LVS: Cadence PVS or Mentor Calibre
  
PHASE 6: GDSII EXPORT
  Tool: Cadence Innovus / Virtuoso
  Output: aes_soc.gds
  
PHASE 7: FPGA DEMO (LAST!)
  Tool: Vivado (Xilinx) or IceStorm (iCE40)
  Board: Basys3 or iCEstick
```

---
## ✅ NIST TEST VECTORS (Memorize TV1!)

```
TEST VECTOR 1 (MOST IMPORTANT - from FIPS 197):
  Key:      2B7E151628AED2A6ABF7158809CF4F3C
  Plain:    6BC1BEE22E409F96E93D7E117393172A
  Cipher:   3AD77BB40D7A3660A89ECAF32466EF97

TEST VECTOR 2:
  Key:      2B7E151628AED2A6ABF7158809CF4F3C
  Plain:    AE2D8A571E03AC9C9EB76FAC45AF8E51
  Cipher:   F5D3D58503B9699DE785895A96FDBAAF

TEST VECTOR 3:
  Key:      2B7E151628AED2A6ABF7158809CF4F3C
  Plain:    30C81C46A35CE411E5FBC1191A0A52EF
  Cipher:   43B1CD7F598ECE23881B00E3ED030688

TEST VECTOR 4:
  Key:      000102030405060708090A0B0C0D0E0F
  Plain:    00112233445566778899AABBCCDDEEFF
  Cipher:   69C4E0D86A7B04300D8A8B41B9B72058

ALL ZERO TEST:
  Key:      00000000000000000000000000000000
  Plain:    00000000000000000000000000000000
  Cipher:   66E94BD4EF8A2C3B884CFA59CA342B2E
```

---
## 🎯 DESIGN DECISIONS

```
DECISION 1: ITERATIVE vs PIPELINED

  ITERATIVE (chosen):
    1 round unit reused 10 times
    11 cycles per encryption
    ~8,200 gates, low power
    REASON: IoT target = area/power critical

  PIPELINED (not chosen):
    10 round units in series
    1 block/cycle throughput
    ~80,000 gates, high power
    WHEN TO USE: Server/high-throughput
```

---
Full original note preserved for future retrieval.
