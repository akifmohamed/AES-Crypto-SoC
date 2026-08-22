# Software vs Hardware AES-128 Benchmark - Verified Basis (v2, 22 Aug 2026)

## Measured hardware
- 10 clock cycles per 128-bit block (counted by an in-design cycle counter on
  the FPGA; reproduced in simulation by tb/tb_aes_soc_v2_1.v).
- 200 ns at 50 MHz. 0.64 Gbps.

## Published software baselines (cited)
| Source | Platform | Cost | Per 128-bit block |
|---|---|---|---|
| mbed TLS measured benchmark (NUCLEO-446RE) | Cortex-M4 @ 180 MHz | 71 cycles/byte | ~1,136 cycles |
| Kim & Seo, ACM TECS 24(6), 2025 (fixslicing record) | Cortex-M4 | ~80 cycles/byte | ~1,280 cycles |
| Schwabe & Stoffelen, CHES 2017 (table-based CTR) | Cortex-M4 | 554.4 cycles/block | 554 cycles |

## Honest speedup
- Cycle count: 1,136 / 10 = ~114x (vs measured mbedTLS); 1,280 / 10 = 128x
  (vs fastest published software).
- At the software's own 168-180 MHz clock the wall-clock ratio is smaller
  (the MCU simply runs more cycles per second); the cycle-count ratio is the
  architecture-honest comparison.
- The OLD 50,000 cycles / 250x / 227x figures used an assumed app-note-class
  software time and are RETIRED. Do not quote them.
