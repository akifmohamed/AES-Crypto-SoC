# AES-128 Crypto SoC Architecture - Deep Dive

### SoC Block Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                  AES-128 CRYPTO SoC (aes_soc.v)              │
│                                                              │
│  Laptop                                                      │
│    ↕ USB-UART 115200                                         │
│  ┌────────────┐    ┌────────────┐    ┌────────────────────┐  │
│  │  UART RX   │───▶│  CTRL FSM  │───▶│    AES CORE        │  │
│  │  uart_rx.v │    │  (SoC FSM) │◀───│  aes_core.v        │  │
│  └────────────┘    └─────┬──────┘    │  ┌──────────────┐  │  │
│         ▲                │           │  │ Key Expansion│  │  │
│         │                ▼           │  │ 11 rnd keys  │  │  │
│  ┌────────────┐    ┌────────────┐    │  │ 1408 bits    │  │  │
│  │  UART TX   │◀───│  TX CTRL   │    │  ├──────────────┤  │  │
│  │  uart_tx.v │    │  16B send  │    │  │ Round Logic  │  │  │
│  └────────────┘    └────────────┘    │  │  ×11 iter    │  │  │
│                                      │  │  - SubBytes  │  │  │
│  ┌────────────────────────────┐        │  │  - ShiftRows │  │  │
│  │  STATUS LEDs               │        │  │  - MixCols   │  │  │
│  │  led_busy (yellow)         │        │  │  - AddRKey   │  │  │
│  │  led_done (green)          │        │  └──────────────┘  │  │
│  │  led_error (red)           │        └────────────────────┘  │
│  │  led_data[7:0] last byte   │                                │
│  └────────────────────────────┘                                │
└──────────────────────────────────────────────────────────────┘
```

### Module Hierarchy

**Level 0 - Top:** `aes_soc.v` (SoC integration)
**Level 1 - AES Core + UARTs:**
- `aes_core.v` - Iterative AES engine
- `uart_rx.v` / `uart_tx.v` - 115200 baud @50MHz, BAUD_DIV=434

**Level 2 - AES Round:**
- `aes_enc_round.v` - SubBytes -> ShiftRows -> MixColumns -> AddRoundKey (skip Mix on last round)
- `key_expand.v` - 128-bit -> 1408-bit (11 keys)

**Level 3 - Primitives:**
- `sub_bytes.v` - 16x `aes_sbox.v` parallel
- `shift_rows.v` - Pure wiring 0 gates
- `mix_columns.v` - 4x `mix_column.v` parallel
- `add_round_key.v` - 128-bit XOR

**Level 4 - GF Math + LUT:**
- `aes_sbox.v` - 256-entry case LUT (FIPS-197)
- `aes_inv_sbox.v` - Inverse (for future decrypt)
- `gf_mult2.v` - xtime: `{in[6:0],0} ^ (in[7]?8'h1B:0)`
- `gf_mult3.v` - mult2 ^ in

### Why Iterative? (Critical Interview Decision)

**Iterative (Chosen):**
- 1 round unit reused 10 times
- Latency: 10-cycle busy window = 200ns @50MHz (measured on FPGA)
- Area v1: 25,902 cells / 185,254 um2 (historical); v2: 67.6% utilization, 240,307 um2 die; DFT build 326,366 um2, 745 scan flops
- Reason: IoT target = area/power critical; 114-128x fewer cycles than published SW AES

**Pipelined (Not Chosen):**
- 10 round units in series
- Throughput: 1 block/cycle
- Area: ~80,000 gates, high power
- When to use: Server/high-throughput (Intel AES-NI style)

### Data Representation - Column Major (Big Endian)

State 128-bit = 16 bytes s0..s15
```
Input bits: [127:120]=s0, [119:112]=s1, [111:104]=s2, [103:96]=s3,
            [95:88]=s4, [87:80]=s5, [79:72]=s6, [71:64]=s7,
            [63:56]=s8, [55:48]=s9, [47:40]=s10, [39:32]=s11,
            [31:24]=s12, [23:16]=s13, [15:8]=s14, [7:0]=s15

Matrix view (column-major):
Col0: s0 s1 s2 s3
Col1: s4 s5 s6 s7
Col2: s8 s9 s10 s11
Col3: s12 s13 s14 s15

ShiftRows wiring:
Row0: s0 s4 s8 s12 -> s0 s4 s8 s12 (shift 0)
Row1: s1 s5 s9 s13 -> s5 s9 s13 s1 (shift 1)
Row2: s2 s6 s10 s14 -> s10 s14 s2 s6 (shift 2)
Row3: s3 s7 s11 s15 -> s15 s3 s7 s11 (shift 3)
```

### Key Expansion Flow

```
Key 128b = W0 W1 W2 W3 (4 words)

For i=4..43:
  temp = W[i-1]
  if i%4==0:
    temp = SubWord(RotWord(temp)) XOR Rcon[i/4]
  W[i] = W[i-4] XOR temp

RotWord: [a0,a1,a2,a3] -> [a1,a2,a3,a0]
SubWord: S-Box each byte
Rcon: 01,02,04,08,10,20,40,80,1B,36 as {Rcon,00,00,00}

Round Keys:
RK0 = W0 W1 W2 W3
RK1 = W4 W5 W6 W7
...
RK10 = W40 W41 W42 W43 = 1408 bits total
```

### UART Protocol (SoC Memory Map)

```
COMMAND 0xAE - ENCRYPT:
  Laptop -> FPGA: [0xAE][Key 16B MSB first][Plain 16B MSB first]
  FPGA -> Laptop: [Cipher 16B MSB first]
  LEDs: busy=1 during encryption, done=1 after, data=last cipher byte
  Timeline: RX 33 bytes @115200 = ~2.9ms, Core 200ns, TX 16 bytes = ~1.39ms

COMMAND 0x55 - STATUS:
  Laptop -> FPGA: [0x55]
  FPGA -> Laptop: [0xAA]
  Use for checking connection alive
```

### Clocking

- Main Clock: 50MHz (20ns period) from Basys3 100MHz /2 or iCEstick 12MHz via PLL (or adjust BAUD_DIV)
- Encryption Clock: Same 50MHz, 10-cycle busy window = 200ns
- UART Clock: Same 50MHz, BAUD_DIV=434 gives 115200 baud (50M/115200=434)
- For iCEstick 12MHz: BAUD_DIV=104 (12M/115200)

### Gate Count Breakdown (Measured)

- v1 synthesis (historical): 25,902 cells / 185,254 um2; v2 flow: 745 FFs (100% scan-mapped), 0.122 mW/MHz
- Sequential 8.3% of area; S-Box combinational dominates (91.7%)
- ShiftRows: 0 cells (pure wiring)

Why S-Box dominant? 256-entry LUT is large combinational.

Optimization future: Use composite-field S-Box (Canright) ~ 1/3 area.

### Timing Critical Path (measured post-PNR)

Path: `plaintext_reg -> SubBytes (S-Box LUT) -> ShiftRows (wire) -> MixColumn (xor tree) -> AddRoundKey (xor) -> state_reg`

Measured post-PNR: setup WNS +14.07 ns @ 20 ns period (fmax ≈ 168 MHz).

### Power Estimation

- Dynamic power ~ P = α*C*V^2*f
- For 8K gates @50MHz, Sky130 1.8V: Estimate ~5-10mW (vs software MCU ~50mW)
- Will be in final reports from OpenLane
