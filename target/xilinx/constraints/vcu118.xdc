# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

set SOC_TCK 10
set HYPERBUS_TCK 10

##########
# BUFG   #
##########

# tc_clk_mux2 are used for reset signals too, this makes Vivado flag them as clock trees and wasted precious routing ressources
set all_in_mux [get_nets -of [ get_pins -filter { DIRECTION == IN } -of [get_cells -hier -filter { ORIG_REF_NAME == tc_clk_mux2 || REF_NAME == tc_clk_mux2 }]]]
set_property CLOCK_DEDICATED_ROUTE FALSE $all_in_mux
set_property CLOCK_BUFFER_TYPE NONE $all_in_mux


#############
#    VIO    #
#############

set_false_path -through [get_pins -of_object [get_cells -hier -filter {REF_NAME =~ xlnx_vio || ORIG_REF_NAME =~ xlnx_vio}] -filter {NAME =~ *probe*}]



####################
#       Reset      #
####################

set SOC_RST_SRC [get_pins -filter {DIRECTION == OUT} -leaf -of_objects [get_nets rst_n]]
set_max_delay -through $SOC_RST_SRC $SOC_TCK
set_false_path -hold -through $SOC_RST_SRC


# No max delay on sw reset since clock can be gated anyways
set_property KEEP_HIERARCHY SOFT [get_cells -hier -filter {ORIG_REF_NAME=="rstgen" || REF_NAME=="rstgen"}]
set_false_path -hold -through [get_pins -filter {DIRECTION==OUT} -of_objects [get_cells -hier -filter {REF_NAME == rstgen || ORIG_REF_NAME == rstgen}]]


#################
#     CDCs      # 
#################

set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_hyperbus_wrap/i_cdc_mem/*"}] $HYPERBUS_TCK
set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_hyperbus_wrap/i_cdc_reg*"}] $HYPERBUS_TCK
set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_rx_rwds_cdc_fifo*"}] [expr {$HYPERBUS_TCK * 2}]

set_false_path -hold -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_hyperbus_wrap*"}]



#################
#     PINOUT    #
#################

# RESET
set_property PACKAGE_PIN L19 [get_ports cpu_reset]
set_property IOSTANDARD LVCMOS12 [get_ports cpu_reset]

# SYS CLOCK
set_property PACKAGE_PIN D12      [get_ports "sys_clk_n"] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13N_T2L_N1_GC_QBC_47
set_property IOSTANDARD  DIFF_SSTL12 [get_ports "sys_clk_n"] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13N_T2L_N1_GC_QBC_47
set_property PACKAGE_PIN E12      [get_ports "sys_clk_p"] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13P_T2L_N0_GC_QBC_47
set_property IOSTANDARD  DIFF_SSTL12 [get_ports "sys_clk_p"] ;# Bank  47 VCCO - VCC1V2_FPGA - IO_L13P_T2L_N0_GC_QBC_47

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