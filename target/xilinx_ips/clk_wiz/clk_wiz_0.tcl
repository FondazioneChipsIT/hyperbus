# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Carlotta Chiarini

set clk_wiz_0 [create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0]

set_property -dict { 
  CONFIG.PRIM_IN_FREQ {300.000}
  CONFIG.CLKIN1_JITTER_PS {33.330000000000005}
  CONFIG.CLKOUT2_USED {true}
  CONFIG.CLKOUT3_USED {true}
  CONFIG.NUM_OUT_CLKS {3}
  CONFIG.CLK_OUT1_PORT {clk_20}
  CONFIG.CLK_OUT2_PORT {clk_100}
  CONFIG.CLK_OUT3_PORT {clk_200}
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {10.000}
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200.000}
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin}
  CONFIG.USE_LOCKED {false}
  CONFIG.MMCM_CLKFBOUT_MULT_F {4.000}
  CONFIG.MMCM_CLKIN1_PERIOD {3.333}
  CONFIG.MMCM_CLKIN2_PERIOD {10.0}
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {60.000}
  CONFIG.MMCM_CLKOUT1_DIVIDE {12}
  CONFIG.MMCM_CLKOUT2_DIVIDE {6}
  CONFIG.CLKOUT1_JITTER {140.023}
  CONFIG.CLKOUT1_PHASE_ERROR {77.836}
  CONFIG.CLKOUT2_JITTER {101.475}
  CONFIG.CLKOUT2_PHASE_ERROR {77.836}
  CONFIG.CLKOUT3_JITTER {88.577}
  CONFIG.CLKOUT3_PHASE_ERROR {77.836}
} [get_ips clk_wiz_0]

##################################################################

