# PERSON A TASKS - AES Crypto SoC
## RTL, Synthesis, STA - Same as PipeCore Person A

You are Person A. You mastered PipeCore Phases 2-4. Now do same for AES but bigger design.

### Your Skills from PipeCore (Reuse!)
- Verilog RTL + testbench
- Yosys synthesis (OSS CAD Suite)
- OpenSTA timing (setup/hold slack)
- SDC constraints
- Git workflow

### Phase 2: RTL Design - DONE ✅
You don't need to redo - all 15 Verilog files already written in `rtl/`:
- `rtl/crypto/aes_sbox.v` - 256-entry case statement (verify values vs FIPS)
- `sub_bytes.v` - generate loop 16 S-Boxes
- `shift_rows.v` - wiring only (0 gates) - explain interview free!
- `gf_mult2/3, mix_column/s` - GF(2^8) math
- `key_expand.v` - Rcon table + RotWord + SubWord
- `aes_core.v` - FSM IDLE->INIT->ROUNDx9->FINAL->DONE = 11 cycles
- `uart_rx/tx.v` - 2-FF sync, BAUD_DIV 434 @50MHz
- `aes_soc.v` - UART protocol 0xAE/0x55

Verification done via Python model (since iverilog may not be in this sandbox, but you have it):
- TV1: 3AD77BB40D7A3660A89ECAF32466EF97 MATCH

If you want to re-run simulation like PipeCore:
```bash
iverilog -g2012 -o /tmp/aes_sim rtl/crypto/*.v tb/tb_aes_core.v
vvp /tmp/aes_sim
gtkwave aes_sim.vcd
```
Should show PASS for 5 vectors.

### Phase 3: Synthesis - YOUR CURRENT TASK

**Goal:** Convert Verilog to gate netlist using Sky130 (same libs as PipeCore)

**Step 1: Get PDK lib (reuse PipeCore)**
```bash
cd aes-crypto-soc
# Option A - Copy from old project (fast)
cp ~/PipeCore-GDS/synth/sky130.lib synth/
cp ~/PipeCore-GDS/synth/sky130.lib timing/

# Option B - Download fresh
bash synth/get_pdk.sh
ls -lh synth/sky130.lib  # should be ~few MB
```

**Step 2: Run Yosys (same command as PipeCore Phase 3)**
```bash
yosys -s synth/synth.tcl
# Takes longer than PipeCore (168 cells) - AES is ~8-12K cells, maybe 2-5 mins
```

**Expected output:**
```
# In synth/synth_report.txt
Chip area: ~15000-20000 um2 (vs PipeCore 1513 um2)
Cell count: ~8000-12000 (vs 168)
Flip-flops: ~200-400 (vs 29)
Clock inverters: many
```

**Step 3: Check netlist exists**
```bash
ls -lh synth/netlist/aes_soc_synth.v
head -20 synth/netlist/aes_soc_synth.v  # should show sky130_fd_sc_hd__... cells
cat synth/synth_report.txt
```

**If Yosys fails (common errors you saw in PipeCore):**

| Error | Fix (you solved before) |
|-------|------------------------|
| `yosys: command not found` | Source OSS CAD Suite: `source ~/oss-cad-suite/environment` then add to ~/.bashrc |
| `sky130.lib not found` | Run get_pdk.sh or copy |
| `ERROR: Module not found` | Check hierarchy - we have top aes_soc |
| `Memory killed` | AES big - add swapfile 8GB like Person B did: `sudo fallocate -l 8G /swapfile` |

**Step 4: Commit**
```bash
git checkout -b feature/aes-rtl-synth-timing
git add rtl/ synth/ timing/ tb/
git commit -m "[AES][RTL+SYNTH][A] AES RTL + Yosys synth - NAND: ~12000 cells"
git push origin feature/aes-rtl-synth-timing
```

### Phase 4: STA - YOUR NEXT TASK (Same as PipeCore Phase 4)

**Goal:** Check timing - setup slack +ve, hold may be -ve pre-CTS normal

**Step 1: Run OpenSTA (same as PipeCore)**
```bash
cd aes-crypto-soc
# Ensure lib
cp synth/sky130.lib timing/
sta timing/sta.tcl
```

**Step 2: Read reports (you learned Cap/Slew/Delay in PipeCore)**
```bash
cat timing/reports/setup_report.txt
cat timing/reports/hold_report.txt
```

**Expected:**
- Setup slack: Large +ve (e.g., +15ns) because 20ns period easy for single AES round (~2-3ns critical path in Sky130? Maybe more due to S-Box)
- Hold slack: May be -ve like PipeCore -0.14ns (flop-to-flop fast). Normal pre-CTS. OpenLane will fix with delay buffers because we have `set_fix_hold [all_clocks]` in SDC.
- Critical path: Likely through S-Box -> MixColumns chain
- Clock skew: 0.00 pre-CTS ideal

**If setup negative:**
- Our 20ns is generous. If still negative, AES critical path >20ns means design too slow for 50MHz. We could increase period to 30ns (33MHz) in constraints.sdc and retry. But iterative AES should be fine at 20ns.

**Step 3: Update PROJECT_STATE.md**
- Fill Phase 3 and 4 numbers: cell count, area, setup slack, hold slack, critical path

**Step 4: Handover to Person B**
Person B needs:
- `synth/netlist/aes_soc_synth.v` (or they can use RTL directly - OpenLane can synth again)
- `timing/constraints.sdc` (real SDC - not fallback)
- `timing/reports/`

Share via git:
```bash
# Person B will do: git checkout origin/feature/aes-rtl-synth-timing -- timing/constraints.sdc
# Or just merge branch
```

### Phase 8: Help Person B + Interview Prep (Both)

After Person B completes PNR+GDS+Virtuoso:
- Help analyze final reports (area, power, timing)
- Prepare 10 interview questions like PipeCore doc
- Write project_summary.pdf
- Final GitHub README with screenshots

### Your Interview Talking Points (Person A focus)

- How you implemented 256-entry S-Box with case statement
- Why SubBytes uses generate loop for 16 parallel S-Boxes = 1 cycle for all bytes
- Why ShiftRows is free (pure wiring)
- Key expansion algorithm with Rcon, RotWord, SubWord
- Why you chose iterative vs pipelined (area/power critical for IoT)
- How you debugged synthesis - Yosys stat, cell count
- What setup/hold slack means, Cap/Slew/Delay terms (you learned in PipeCore)
- What critical path you saw in STA report

### Checklist Before Saying "Handover Complete"

- [ ] RTL all 15 files present and committed
- [ ] NIST TV1 memorized and verified PASS
- [ ] synth/sky130.lib exists (or copied)
- [ ] yosys -s synth/synth.tcl succeeded, netlist exists
- [ ] synth_report.txt shows cell count ~8-12K
- [ ] sta timing/sta.tcl succeeded, setup_report.txt +ve
- [ ] Files pushed to feature/aes-rtl-synth-timing branch
- [ ] PROJECT_STATE.md updated with Phase 3&4 numbers

You did this exact workflow for PipeCore (168 cells ALU). Now same but bigger AES SoC!

