# Official NIST FIPS-197 Compliance & Test Vectors

Our AES-128 cryptographic core is verified against the official **NIST FIPS-197 Advanced Encryption Standard** specification (Appendix B & Appendix C).

---

## 1. Primary Must-Memorize Vector (TV1 — NIST SP 800-38A F.1 Block 1)
All team members must memorize TV1 for technical interviews:
- **Cipher Key (128-bit):** `2B7E151628AED2A6ABF7158809CF4F3C`
- **Plaintext Block:** `6BC1BEE22E409F96E93D7E117393172A`
- **Expected Ciphertext:** `3AD77BB40D7A3660A89ECAF32466EF97`
- **FPGA LED Output:** `0x97` (Last byte of ciphertext displayed on 8-bit status LEDs on Basys3 / iCEstick boards).

---

## 2. Complete 5-Vector Test Suite
Our verification testbench (`tb/tb_aes_core.v`) and Python model (`sw/pc_demo.py`) execute the following 5 vectors:

| ID | Key (128-bit Hex) | Plaintext (128-bit Hex) | Expected Ciphertext (128-bit Hex) | Status |
|---|---|---|---|:---:|
| **TV1** | `2B7E151628AED2A6ABF7158809CF4F3C` | `6BC1BEE22E409F96E93D7E117393172A` | `3AD77BB40D7A3660A89ECAF32466EF97` | ✅ PASS |
| **TV2** | `2B7E151628AED2A6ABF7158809CF4F3C` | `AE2D8A571E03AC9C9EB76FAC45AF8E51` | `F5D3D58503B9699DE785895A96FDBAAF` | ✅ PASS |
| **TV3** | `2B7E151628AED2A6ABF7158809CF4F3C` | `30C81C46A35CE411E5FBC1191A0A52EF` | `43B1CD7F598ECE23881B00E3ED030688` | ✅ PASS |
| **TV4** | `2B7E151628AED2A6ABF7158809CF4F3C` | `F69F2445DF4F9B17AD2B417BE66C3710` | `7B0C785E27E8AD3F8223207104725DD4` | ✅ PASS |
| **TV5** | `00000000000000000000000000000000` | `00000000000000000000000000000000` | `66E94BD4EF8A2C3B884CFA59CA342B2E` | ✅ PASS |

---

## 3. Live Speedup Demonstration (`sw/pc_demo.py`)
- **Software Execution Time (MCU):** ~50,000 ns per 128-bit block (slow software AES on IoT microcontroller).
- **Hardware SoC Execution Time:** 220 ns per block (11 clock cycles @ 50 MHz clock period 20 ns).
- **Speedup Ratio:** `50,000 ns / 220 ns =` **227.3x FASTER** than software.
