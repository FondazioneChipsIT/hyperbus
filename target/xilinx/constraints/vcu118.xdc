# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

#################
#     PINOUT    #
#################

# RESET
set_property PACKAGE_PIN L19 [get_ports cpu_reset]
set_property IOSTANDARD LVCMOS12 [get_ports cpu_reset]

# SYS CLOCK (300 MHz)
set_property PACKAGE_PIN F31            [get_ports "sys_clk_n"]
set_property IOSTANDARD  DIFF_SSTL12    [get_ports "sys_clk_n"]
set_property PACKAGE_PIN G31            [get_ports "sys_clk_p"]
set_property IOSTANDARD  DIFF_SSTL12    [get_ports "sys_clk_p"]

# HYPERBUS PHY0
set_property -dict "PACKAGE_PIN AW13 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_csn[0][0]]
set_property -dict "PACKAGE_PIN AY13 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_csn[0][1]]
set_property -dict "PACKAGE_PIN AY9 IOSTANDARD LVCMOS18"    [get_ports pad_hyper_ck[0]]
set_property -dict "PACKAGE_PIN BA9 IOSTANDARD LVCMOS18"    [get_ports pad_hyper_ckn[0]]
set_property -dict "PACKAGE_PIN BC14 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_rwds[0]]
set_property -dict "PACKAGE_PIN AT12 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_reset[0]]
set_property -dict "PACKAGE_PIN BF15 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_dq[0][0]]
set_property -dict "PACKAGE_PIN BE15 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_dq[0][1]]
set_property -dict "PACKAGE_PIN BE12 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_dq[0][2]]
set_property -dict "PACKAGE_PIN BD12 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_dq[0][3]]
set_property -dict "PACKAGE_PIN AV9 IOSTANDARD LVCMOS18"    [get_ports pad_hyper_dq[0][4]]
set_property -dict "PACKAGE_PIN AV8 IOSTANDARD LVCMOS18"    [get_ports pad_hyper_dq[0][5]]
set_property -dict "PACKAGE_PIN AW11 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_dq[0][6]]
set_property -dict "PACKAGE_PIN AY10 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_dq[0][7]]

# HYPERBUS PHY1
set_property -dict "PACKAGE_PIN AP16 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_csn[1][0]]
set_property -dict "PACKAGE_PIN AT14 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_csn[1][1]]
set_property -dict "PACKAGE_PIN AP12 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_ck[1]]
set_property -dict "PACKAGE_PIN AR12 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_ckn[1]]
set_property -dict "PACKAGE_PIN AL14 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_rwds[1]]
set_property -dict "PACKAGE_PIN AW7 IOSTANDARD LVCMOS18"   [get_ports pad_hyper_reset[1]]
set_property -dict "PACKAGE_PIN BE14 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][0]]
set_property -dict "PACKAGE_PIN BF14 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][1]]
set_property -dict "PACKAGE_PIN BA14 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][2]]
set_property -dict "PACKAGE_PIN BB14 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][3]]
set_property -dict "PACKAGE_PIN BD13 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][4]]
set_property -dict "PACKAGE_PIN BE13 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][5]]
set_property -dict "PACKAGE_PIN BB13 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][6]]
set_property -dict "PACKAGE_PIN BB12 IOSTANDARD LVCMOS18"  [get_ports pad_hyper_dq[1][7]]