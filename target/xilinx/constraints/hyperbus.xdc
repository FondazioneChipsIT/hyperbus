# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

set SOC_TCK 10
set HYPERBUS_PERIOD 10

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

set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_hyperbus_wrap/i_cdc_mem/*"}] $HYPERBUS_PERIOD
set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_hyperbus_wrap/i_cdc_reg*"}] $HYPERBUS_PERIOD
set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_rx_rwds_cdc_fifo*"}] [expr {$HYPERBUS_PERIOD * 2}]

set_false_path -hold -through [get_nets -hierarchical -filter {NAME=~"*async*" && NAME=~"*i_hyperbus_wrap*"}]


#################
#     OTHER     # 
#################

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports pad_hyper_ck]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports pad_hyper_ck]]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports pad_hyper_ckn]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports pad_hyper_ckn]]

set_property CLOCK_BUFFER_TYPE NONE [get_nets -hier -filter {NAME =~ *i_delay_rx_rwds_90/out_o}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier -filter {NAME =~ *i_delay_rx_rwds_90/out_o}]