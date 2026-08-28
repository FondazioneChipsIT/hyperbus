# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

##########################
#     CLK constraints    #
##########################

set HYPERBUS_PERIOD 10
set clk_rx_shift [expr $HYPERBUS_PERIOD/4]
set rwds_input_delay [expr $HYPERBUS_PERIOD/4]


# MAIN CLOCK
set CLK_HYP [get_clocks hype_clk_clk_wiz_0]

# PHY CLOCK
create_generated_clock -name CLK_PHY -source [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/clk_i}] -add -master_clock $CLK_HYP -edges {1 3 5} [get_pins */i_hyper_clk_gen/clk_phy_o_reg/Q]

# WRITE PROTOCOL
foreach phy {0 1} { 
    foreach del_mode {NEGEDGE DLINE} edges { {2 4 6} {1 3 5} } ff {clk_phy_90_by_clk_g_reg clk_phy_0_g_reg} {
        create_generated_clock -name CLK_PHY${phy}_CK_FF_${del_mode} \
        -add \
        -master_clock $CLK_HYP \
        -source [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/clk_i}] \
        -edges ${edges} \
        [get_pins i_hyperbus_wrap/i_hyperbus/i_phy/*${phy}*/i_trx/i_clock_diff_out/${ff}/Q]
        create_generated_clock -name CLK_PHY${phy}_CK_${del_mode} \
        -add \
        -master_clock [get_clocks CLK_PHY${phy}_CK_FF_${del_mode}] \
        -source [get_pins i_hyperbus_wrap/i_hyperbus/i_phy/*${phy}*/i_trx/i_clock_diff_out/${ff}/Q] \
        -edges {1 2 3} \
        [get_ports pad_hyper_ck[${phy}]]
        create_generated_clock -name CLK_PHY${phy}_CK_N_${del_mode} \
        -add \
        -master_clock [get_clocks CLK_PHY${phy}_CK_FF_${del_mode}] \
        -source [get_pins i_hyperbus_wrap/i_hyperbus/i_phy/*${phy}*/i_trx/i_clock_diff_out/${ff}/Q] \
        -edges {2 3 4} \
        [get_ports pad_hyper_ckn[${phy}]]
    }
}

# READ PROTOCOL
create_clock -period [expr $HYPERBUS_PERIOD*2] -name RWDS0_CLK [get_ports {pad_hyper_rwds[0]}]
create_clock -period [expr $HYPERBUS_PERIOD*2] -name RWDS1_CLK [get_ports {pad_hyper_rwds[1]}]


create_generated_clock [get_pins -hier -filter {NAME =~ *i_hyperbus/i_phy/phy_wrap.phy_unroll[0].i_phy/i_trx/i_delay_rx_rwds_90/out_o}] \
                       -name CLK_RWDS_0 -edges {1 2 3} -edge_shift "$rwds_input_delay $rwds_input_delay $rwds_input_delay" \
                       -source [get_ports pad_hyper_rwds[0]]

create_generated_clock [get_pins -hier -filter {NAME =~ *i_hyperbus/i_phy/phy_wrap.phy_unroll[1].i_phy/i_trx/i_delay_rx_rwds_90/out_o}] \
                       -name CLK_RWDS_1 -edges {1 2 3} -edge_shift "$rwds_input_delay $rwds_input_delay $rwds_input_delay" \
                       -source [get_ports pad_hyper_rwds[1]]


# CLOCK RELATIONSHIPS
set_clock_groups -name CLK_GROUP_1 -asynchronous \
  -group {hype_clk_clk_wiz_0 CLK_PHY*} \
  -group {CLK_RWDS_0 RWDS0_CLK} \
  -group {CLK_RWDS_1 RWDS1_CLK}

set_clock_groups -name CLK_GROUP_2 -logically_exclusive \
  -group {CLK_PHY*_CK*NEGEDGE} \
  -group {CLK_PHY*_CK*DLINE}



# INPUT/OUTPUT DELAY

# Data is sent in DDR, therefore we need to specify input delay for both the rising and the falling edge 
# (with -add_delay flag to not override the previous constraints)

# Ideally, the data signals would transition at exactly a 1/4 period after each transition of the 90 phase shifted output clock (CK & CKN). 
# This would translate to an output max delay of 1/4 period and a min output delay of 1/4 period.

set output_ports_phy0 {{pad_hyper_dq[0]*} pad_hyper_rwds[0]}
set_output_delay [expr $HYPERBUS_PERIOD/4] -clock CLK_PHY0_CK_NEGEDGE [get_ports $output_ports_phy0] -max
set_output_delay [expr $HYPERBUS_PERIOD/-4] -clock CLK_PHY0_CK_NEGEDGE [get_ports $output_ports_phy0] -min -add_delay
set_output_delay [expr $HYPERBUS_PERIOD/4] -clock CLK_PHY0_CK_NEGEDGE [get_ports $output_ports_phy0] -max -clock_fall -add_delay
set_output_delay [expr $HYPERBUS_PERIOD/-4] -clock CLK_PHY0_CK_NEGEDGE [get_ports $output_ports_phy0] -min -clock_fall -add_delay

set output_ports_phy1 {{pad_hyper_dq[1]*} pad_hyper_rwds[1]}
set_output_delay [expr $HYPERBUS_PERIOD/4] -clock CLK_PHY1_CK_NEGEDGE [get_ports $output_ports_phy1] -max
set_output_delay [expr $HYPERBUS_PERIOD/-4] -clock CLK_PHY1_CK_NEGEDGE [get_ports $output_ports_phy1] -min -add_delay
set_output_delay [expr $HYPERBUS_PERIOD/4] -clock CLK_PHY1_CK_NEGEDGE [get_ports $output_ports_phy1] -max -clock_fall -add_delay
set_output_delay [expr $HYPERBUS_PERIOD/-4] -clock CLK_PHY1_CK_NEGEDGE [get_ports $output_ports_phy1] -min -clock_fall -add_delay


set input_ports_phy0 {{pad_hyper_dq[0]*} pad_hyper_rwds[0]}
set_input_delay -max [expr $HYPERBUS_PERIOD/4] -clock RWDS0_CLK [get_ports $input_ports_phy0]
set_input_delay -min [expr $HYPERBUS_PERIOD/4] -clock RWDS0_CLK [get_ports $input_ports_phy0] -add_delay
set_input_delay -max [expr $HYPERBUS_PERIOD/4] -clock RWDS0_CLK [get_ports $input_ports_phy0] -add_delay -clock_fall
set_input_delay -min [expr $HYPERBUS_PERIOD/4] -clock RWDS0_CLK [get_ports $input_ports_phy0] -add_delay -clock_fall

set input_ports_phy1 {{pad_hyper_dq[1]*} pad_hyper_rwds[1]}
set_input_delay -max [expr $HYPERBUS_PERIOD/4] -clock RWDS1_CLK [get_ports $input_ports_phy1]
set_input_delay -min [expr $HYPERBUS_PERIOD/4] -clock RWDS1_CLK [get_ports $input_ports_phy1] -add_delay
set_input_delay -max [expr $HYPERBUS_PERIOD/4] -clock RWDS1_CLK [get_ports $input_ports_phy1] -add_delay -clock_fall
set_input_delay -min [expr $HYPERBUS_PERIOD/4] -clock RWDS1_CLK [get_ports $input_ports_phy1] -add_delay -clock_fall


# FALSE PATHS

# Let's false path all illegal timing paths. That is for setup we only need to check rising- to rising-edge and for hold only rise to fall or fall to rise
# timing paths. The other paths can be ignored.
foreach phy {0 1} { 
  set_false_path -setup -rise_from [get_clocks CLK_PHY] -fall_to [get_clocks CLK_PHY${phy}_CK_NEGEDGE]
  set_false_path -setup -fall_from [get_clocks CLK_PHY] -rise_to [get_clocks CLK_PHY${phy}_CK_NEGEDGE]
  set_false_path -hold -rise_from [get_clocks CLK_PHY] -rise_to [get_clocks CLK_PHY${phy}_CK_NEGEDGE]
  set_false_path -hold -fall_from [get_clocks CLK_PHY] -fall_to [get_clocks CLK_PHY${phy}_CK_NEGEDGE]
}

# MULTICYCLE PATH

# The tri-state enable/disable signal of IO pads in general is quite a bit slower than the data-pad timing arc and also suffers form large delay
# difference between max and min delay. Therefore, the RTL is written in a manner such that it always asserts/deasserts the tri-state disable (output
# enable of the IO pad) one cycle earlier than it starts sending/receing data over it. We can thus relax the timing constraints for this signal
# with a multi-cycle path.
set_multicycle_path -setup 2 -through [get_pins i_hyperbus_wrap/*padinst_hyper_dqio/iobuf_i/OBUFT/T] -start
set_multicycle_path -hold 1 -through [get_pins i_hyperbus_wrap/*padinst_hyper_dqio/iobuf_i/OBUFT/T] -start
set_multicycle_path -setup 2 -through [get_pins i_hyperbus_wrap/*padinst_hyper_rwds/iobuf_i/OBUFT/T] -start
set_multicycle_path -hold 1 -through [get_pins i_hyperbus_wrap/*padinst_hyper_rwds/iobuf_i/OBUFT/T] -start