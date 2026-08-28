# Copyright 2023 ETH Zurich, University of Bologna and Fondazione Chips-IT.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Carlotta Chiarini

set jtag_axi_32 [create_ip -name jtag_axi -vendor xilinx.com -library ip -version 1.2 -module_name jtag_axi_32]

set_property -dict { 
  CONFIG.M_AXI_DATA_WIDTH {32}
} [get_ips jtag_axi_32]

set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $jtag_axi_32

##################################################################

