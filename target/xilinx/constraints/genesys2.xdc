# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51


#################
#     PINOUT    #
#################

# RESET
set_property -dict "PACKAGE_PIN R19 IOSTANDARD LVCMOS33" [get_ports cpu_reset]

# SYS CLOCK (200 MHz)
set_property -dict "PACKAGE_PIN AD11 IOSTANDARD LVDS" [get_ports sys_clk_n]
set_property -dict "PACKAGE_PIN AD12 IOSTANDARD LVDS" [get_ports sys_clk_p]

# HYPERBUS PHY0
set_property -dict "PACKAGE_PIN J17 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_csn[0][0]]
set_property -dict "PACKAGE_PIN H17 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_csn[0][1]]
set_property -dict "PACKAGE_PIN D27 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_ck[0]]
set_property -dict "PACKAGE_PIN C27 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_ckn[0]]
set_property -dict "PACKAGE_PIN F26 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_rwds[0]]
set_property -dict "PACKAGE_PIN D22 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_reset[0]]
set_property -dict "PACKAGE_PIN B29 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][0]]
set_property -dict "PACKAGE_PIN C29 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][1]]
set_property -dict "PACKAGE_PIN E30 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][2]]
set_property -dict "PACKAGE_PIN E29 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][3]]
set_property -dict "PACKAGE_PIN E23 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][4]]
set_property -dict "PACKAGE_PIN D23 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][5]]
set_property -dict "PACKAGE_PIN G22 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][6]]
set_property -dict "PACKAGE_PIN F22 IOSTANDARD LVCMOS12"   [get_ports pad_hyper_dq[0][7]]

# HYPERBUS PHY1
set_property -dict "PACKAGE_PIN F17 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_csn[1][0]]
set_property -dict "PACKAGE_PIN E21 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_csn[1][1]]
set_property -dict "PACKAGE_PIN D17 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_ck[1]]
set_property -dict "PACKAGE_PIN D18 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_ckn[1]]
set_property -dict "PACKAGE_PIN A20 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_rwds[1]]
set_property -dict "PACKAGE_PIN B24 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_reset[1]]
set_property -dict "PACKAGE_PIN B30 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][0]]
set_property -dict "PACKAGE_PIN A30 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][1]]
set_property -dict "PACKAGE_PIN B28 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][2]]
set_property -dict "PACKAGE_PIN A28 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][3]]
set_property -dict "PACKAGE_PIN D29 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][4]]
set_property -dict "PACKAGE_PIN C30 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][5]]
set_property -dict "PACKAGE_PIN B27 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][6]]
set_property -dict "PACKAGE_PIN A27 IOSTANDARD LVCMOS12"  [get_ports pad_hyper_dq[1][7]]