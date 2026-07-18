# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

set SOC_TCK 20


####################
# Clock generators #
####################

# Do not optimize anything in 
# set_property DONT_TOUCH TRUE [get_cells gen_domain_clock_mux[*].i_clk_mux]

# TODO Check this
# set_false_path -from [get_pins gen_domain_clock_mux[*].i_clk_mux/gen_input_stages[*].clock_has_been_disabled_q_reg[*]/C] -to [get_pins gen_domain_clock_mux[*].i_clk_mux/gen_input_stages[*].clock_has_been_disabled_q_reg[*]/D]
# set_false_path -from [get_pins gen_domain_clock_mux[*].i_clk_mux/gen_input_stages[*].clock_has_been_disabled_q_reg[*]/C] -to [get_pins gen_domain_clock_mux[*].i_clk_mux/gen_input_stages[*].glitch_filter_q_reg[*][*]/D]

# Enable all clocks (clk_en register)
# set_property DONT_TOUCH TRUE [get_cells i_carfield_reg_top/u_*_clk_sel]
# set_property DONT_TOUCH TRUE [get_cells i_carfield_reg_top/u_*_clk_en]
set_case_analysis 1 [get_pins {i_carfield_reg_top/u_*_clk_en/q_reg[0]/Q}]



##########
# BUFG   #
##########

# tc_clk_mux2 are used for reset signals too, this makes Vivado flag them as clock trees and wasted precious routing ressources
set all_in_mux [get_nets -of [ get_pins -filter { DIRECTION == IN } -of [get_cells -hier -filter { ORIG_REF_NAME == tc_clk_mux2 || REF_NAME == tc_clk_mux2 }]]]
set_property CLOCK_DEDICATED_ROUTE FALSE $all_in_mux
set_property CLOCK_BUFFER_TYPE NONE $all_in_mux



####################
# Reset Generators #
####################

# No max delay on sw reset since clock can be gated anyways
set_property KEEP_HIERARCHY SOFT [get_cells -hier -filter {ORIG_REF_NAME=="rstgen" || REF_NAME=="rstgen"}]
set_false_path -through [get_pins -of_objects [get_cells -hier i_carfield_rstgen] -filter {DIRECTION==OUT}]
set_false_path -hold -through [get_pins -filter {DIRECTION==OUT} -of_objects [get_cells -hier -filter {REF_NAME == rstgen || ORIG_REF_NAME == rstgen}]]
set_false_path -setup -hold -from [get_pins -of_objects [get_cells -hier -filter {NAME=~*i_carfield_reg_top/u_*_rst/*}] -filter {IS_CLOCK}] -to [get_clocks *domain_clk]

# Go large on the isolation
set_max_delay -through [get_nets *isolat*] $SOC_TCK

# Host pwr_on_reset is resynch by the domains
set_max_delay -datapath -from [get_pins i_host_rstgen/i_rstgen_bypass/synch_regs_q_reg[3]/C] -through [get_pins -of_object [get_cells -hier -filter {REF_NAME==clk_mux_glitch_free || ORIG_REF_NAME==clk_mux_glitch_free}] -filter { NAME =~*async* }] $SOC_TCK




#################
#     CDCs      # (if any)
#################

# Note :
# For the 2 phases CDC we use max_delay and hold path as we grab everything grossly
# On the AXI CDC as we precisely select the Clk-to-Q path we use a unique set_max_delay -datapath
# All the delays are assumed to be SOC_TCK (host domain)

# Hold and max delay on 2 phases and 2 phases clearable
set_max_delay -through [get_nets -filter {NAME=~"*async*"} -of_objects [get_cells -hier -filter {REF_NAME =~ cdc_2phase_src* || ORIG_REF_NAME =~ cdc_2phase_src*}]] $SOC_TCK
set_false_path -hold -through [get_nets -filter {NAME=~"*async*"} -of_objects [get_cells -hier -filter {REF_NAME =~ cdc_2phase_src* || ORIG_REF_NAME =~ cdc_2phase_src*}]]

# Hold and max delay on 4 phases
set_max_delay -through [get_nets -filter {NAME=~"*async*"} -of_objects [get_cells -hier -filter {REF_NAME == cdc_4phase_src || ORIG_REF_NAME == cdc_4phase_src}]] $SOC_TCK
set_false_path -hold -through [get_nets -filter {NAME=~"*async*"} -of_objects [get_cells -hier -filter {REF_NAME == cdc_4phase_src || ORIG_REF_NAME == cdc_4phase_src}]]



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




set_false_path -through [get_pins -of_object [get_cells -hier -filter {REF_NAME =~ xlnx_vio || ORIG_REF_NAME =~ xlnx_vio}] -filter {NAME =~ *probe*}]


set SOC_RST_SRC [get_pins -filter {DIRECTION == OUT} -leaf -of_objects [get_nets rst_n]]
set_max_delay -through $SOC_RST_SRC $SOC_TCK
set_false_path -hold -through $SOC_RST_SRC