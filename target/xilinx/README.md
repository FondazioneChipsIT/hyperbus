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

## Measure Hyperbus BW

At the current development stage, the design integrates two timers (tx, rx) to measure the time spent during an AXI transaction. The two signals are passed to an ILA core.

At the moment, to increase the Hyperbus clock frequency, the `constraints/hyperbus.xdc` file and `../xilinx_ips/clk_wiz/clk_wiz_0.tcl` should be modified. In the first file, at the line 12, change the hyperbus clock period. In the second file, at the line 18, change the clock frequency accordingly.


## TODO
- Add clock multiplexer to change the hyperbus clock frequency via registers
- Automatically detect the clock of the nets to be debugged and generate accordingly the ila_cores