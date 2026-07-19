# HYPERBUS FPGA TEST PLATFORM

## Generate the bitstream

From the hyperbus directory launch:
```bash
make scripts-bender-fpga
```
Then in this directory launch:
```bash
vivado -mode tcl -source scripts/run.tcl
```
## Interact with the design

The design integrates two Jtag-to-AXI Xilinx IPs, addressing seperately the hyperbus regs and the Hyperram itself. The number of IPs used is motivated by the different datawidth of the two memory spaces.

The `scripts/jtagtoaxi.tcl` script can be used to interact with the IPs.

After launching the Vivado shell (gui or batch mode):
```bash
source scripts/jtagtoaxi.tcl
```
If the Vivado hw_manager is not open launch:
```bash
setup_hw
```
Now, several functions can be used: 
```bash
read_registers
```
```bash
hyper_init
```
```bash
hyperram_test
```