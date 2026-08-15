# Software vs Hardware AES-128 - Benchmark Basis

Hardware number from our signoff; software numbers from published, measured MCU
benchmarks. The representative 227.3x is a labeled assumption inside that range.

## Hardware (this project, signoff-derived)
- 11 cycles per 128-bit block (sim-verified, 5/5 NIST FIPS-197).
- 20 ns / 50 MHz timing-closed: setup +14.07 ns, hold +0.29 ns.
- 220 ns per block.

## Software baselines (published, per 128-bit block)
| Source | Platform | Cycles/block | Time | Speedup vs 220 ns |
|---|---|---|---|---|
| Schwabe-Stoffelen table-based (SAC 2017) | Cortex-M4 | 634.7 | 3.8 us @168 MHz | ~17x |
| mbed TLS v2.3.0 CTR (same study) | Cortex-M4 | 1247 | 7.4 us @168 MHz | ~34x |
| NXP AN11241 app note (same study) | Cortex-M | 4179 | 41.8 us @100 MHz | ~190x |
| Measured AES128-CTR (IoE endpoints, 2018) | Cortex-M4 | - | 55-97 us | 250-440x |
| Measured (same) | Cortex-M0 | - | ~390 us | ~1770x |

## Representative assumption
pc_demo.py / README use 50,000 ns (~5,000 cycles @100 MHz, app-note class),
inside the measured 44-97 us M4/M7 band -> 227.3x. Conservative bound ~17x;
low-end bound >1000x.

## References
1. P. Schwabe, K. Stoffelen, "All the AES You Need on Cortex-M3 and M4," SAC 2017; github.com/Ko-/aes-armcortexm
2. Adomnicai-Peyrin, "Fixslicing AES-like Ciphers," ePrint 2020/1123
3. "Performance Costs of Cryptography in Securing New-Generation Internet of Energy Endpoint Devices," 2018
4. NXP AN11241 (via [1])

Policy: HW measured/signoff-derived here; SW literature-derived and labeled;
no assumption presented as a measurement.
