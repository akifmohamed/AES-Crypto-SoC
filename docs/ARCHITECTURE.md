# AES-128 Crypto Accelerator SoC — Hardware Architecture

## 1. Top-Level Architecture
The **AES-128 Crypto Accelerator SoC** integrates an iterative 128-bit Advanced Encryption Standard (AES) cryptographic engine with a universal asynchronous receiver-transmitter (UART) peripheral and a top-level SoC system controller.

```
       +-------------------------------------------------------------+
       |                         AES_SOC TOP                         |
       |                                                             |
RX --->| [2-FF Sync] ---> [ UART_RX ] --+---> [ SoC CTRL FSM ]       |---> TX
       |                                |         |  ^               |
       |                                |   Key/  |  | Done/         |
       |                                |   Plain |  | Cipher        |
       |                                v         v  |               |
       |                                +-------------------------+  |
       |                                |       AES_CORE          |  |
       |                                |  (11 cycles @ 50 MHz)   |  |
       |                                +-------------------------+  |
       +-------------------------------------------------------------+
```

---

## 2. Cryptographic Core (`aes_core.v`)
- **Key Size:** 128 bits (16 bytes).
- **Block Size:** 128 bits (16 bytes).
- **Rounds:** 10 rounds total (1 initial `AddRoundKey` + 9 full rounds + 1 final round without `MixColumns`).
- **Iterative Reuse Design:** Reuses a single encryption round hardware block 10 times to save standard cell area (~8,200 gates vs. ~80,000 gates for a fully pipelined 10-stage architecture).
- **Execution Latency:** Exactly **11 clock cycles** per 128-bit block (**220 ns @ 50 MHz** clock).

---

## 3. Transformations & Hardware Implementation
1. **SubBytes (`sub_bytes.v`, `aes_sbox.v`):** Instantiates **16 parallel 256-entry S-Boxes**. This non-linear substitution step dominates ~70–80% of total cell area in the synthesized netlist.
2. **ShiftRows (`shift_rows.v`):** Pure interconnect byte-permutation. Costs **0 standard cells / 0 area / 0 delay** because it is hardwired during placement and routing.
3. **MixColumns (`mix_columns.v`, `mix_column.v`, `gf_mult2.v`, `gf_mult3.v`):** Galois Field $GF(2^8)$ matrix multiplication across 4 columns in parallel using XOR and `xtime` byte-shifting.
4. **AddRoundKey (`add_round_key.v`):** 128-bit bitwise XOR between the intermediate state and the current round key.
5. **Key Expansion (`key_expand.v`):** Expands the 128-bit cipher key into **11 round keys** (1,408 bits total) using Rcon constants (`01, 02, 04, 08, 10, 20, 40, 80, 1B, 36`), `RotWord`, and `SubWord` transformations.
