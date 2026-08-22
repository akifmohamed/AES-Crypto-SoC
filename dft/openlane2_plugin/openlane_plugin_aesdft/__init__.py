# openlane_plugin_aesdft - OpenLane 2 plugin: netlist-level scan DFT for aes_soc
#
# Registers two custom steps that wrap OpenROAD's dft module
# (set_dft_config / scan_replace / report_dft_plan / execute_dft_plan)
# so scan insertion happens on the SYNTHESIZED NETLIST inside the flow -
# zero RTL changes (the approach decided after the hand-written scan-RTL
# attempt failed on 22 Aug 2026).
#
# Install: put this package's PARENT directory on PYTHONPATH, e.g.
#   export PYTHONPATH=/path/to/repo/dft/openlane2_plugin:$PYTHONPATH
# OpenLane auto-imports every importable module named openlane_plugin_*.
# (Verified against OL2 docs: usage/plugins.md + usage/writing_custom_steps.md;
#  env contract: _PNR_LIBS, CURRENT_NETLIST/SAVE_NETLIST, CURRENT_DEF/SAVE_DEF,
#  SCRIPTS_DIR/openroad/common/io.tcl from openlane/steps/tclstep.py and
#  openroad.py on the OL2 main branch.)
#
# Then run with pnr/config_scan.json, which inserts:
#   AesDFT.ScanReplace  after Yosys.Synthesis      (DFF -> scan-DFF swap)
#   AesDFT.ScanStitch   after OpenROAD.DetailedPlacement (architect + stitch)
import os

from openlane.config import Variable
from openlane.state.design_format import DesignFormat
from openlane.steps import OpenROADStep, Step

_dft_vars = OpenROADStep.config_vars + [
    Variable(
        "AES_DFT_MAX_LENGTH",
        int,
        "Maximum number of bits per scan chain (aes_soc has ~742 FFs; 800 => single chain)",
        default=800,
    ),
    Variable(
        "AES_DFT_CLOCK_MIXING",
        str,
        "OpenROAD clock mixing mode: no_mix (single-clock design) or clock_mix",
        default="no_mix",
    ),
]


@Step.factory.register()
class ScanReplace(OpenROADStep):
    id = "AesDFT.ScanReplace"
    name = "DFT Scan Replace"
    long_name = "Scan Cell Replacement (DFF -> scan-DFF) on the synthesized netlist"

    inputs = [DesignFormat.NETLIST]
    outputs = [DesignFormat.NETLIST]
    config_vars = _dft_vars

    def get_script_path(self) -> str:
        return os.path.join(os.path.dirname(__file__), "scan_replace.tcl")


@Step.factory.register()
class ScanStitch(OpenROADStep):
    id = "AesDFT.ScanStitch"
    name = "DFT Scan Stitch"
    long_name = "Scan Chain Architecture + Stitching (post detailed placement)"

    inputs = [DesignFormat.DEF]
    outputs = [DesignFormat.DEF]
    config_vars = _dft_vars

    def get_script_path(self) -> str:
        return os.path.join(os.path.dirname(__file__), "scan_stitch.tcl")
