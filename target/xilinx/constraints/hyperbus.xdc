set SOC_TCK 10

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports pad_hyper_ck]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports pad_hyper_ck]]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports pad_hyper_ckn]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports pad_hyper_ckn]]

set_property CLOCK_BUFFER_TYPE NONE [get_nets -hier -filter {NAME =~ *i_delay_rx_rwds_90/out_o}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier -filter {NAME =~ *i_delay_rx_rwds_90/out_o}]

set period_hyperbus 10
set clk_rx_shift [expr $period_hyperbus/4]
set rwds_input_delay [expr $period_hyperbus/4]

set clk_tx_shift [expr $period_hyperbus/4] 

create_clock -period $period_hyperbus -name RWDS0_CLK [get_ports {pad_hyper_rwds[0]}]
create_clock -period $period_hyperbus -name RWDS1_CLK [get_ports {pad_hyper_rwds[1]}]

create_clock -name CLK_HYP -period $period_hyperbus [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/clk_i}]


# From Xilinx DOC: 
#-edges <arg> - (Optional) Specifies the edges of the master clock to use in defining transitions on the generated clock. 
# Specify transitions on the generated clock in a sequence of 1, 2, 3, by referencing the appropriate edge count from the master clock in numerical order,
# counting from the first edge. The sequence of transitions on the generated clock defines the period and duty cycle of the clock: position 1 is the
# first rising edge of the generated clock, position 2 is the first falling edge of the generated clock and so defines the duty cycle, position 3 is the 
# second rising edge of the generated clock and so defines the clock period. Enclose multiple edge numbers in braces {}. See the example below for specifying edge numbers.

# Divide by two; 90-degree-shifted
create_generated_clock -name CLK_PHY0_CK \ 
    -add \
    -master_clock [get_clocks CLK_HYP] \
    -source [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/clk_i}] \
    -edges {1 3 5} \
    -edge_shift "$clk_tx_shift $clk_tx_shift $clk_tx_shift" \
    [get_ports pad_hyper_ck[0]]

 # Divide by two and invert; 90-degree-shifted
create_generated_clock -name CLK_PHY0_CK_N \
    -add \
    -master_clock [get_clocks CLK_HYP] \
    -source [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/clk_i}] \
    -edges {2 4 6} \
    -edge_shift "$clk_tx_shift $clk_tx_shift $clk_tx_shift" \
    [get_ports pad_hyper_ckn[0]]

# Divide by two; 90-degree-shifted
create_generated_clock -name CLK_PHY1_CK \
    -add \
    -master_clock [get_clocks CLK_HYP] \
    -source [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/clk_i}] \
    -edges {1 3 5} \
    -edge_shift "$clk_tx_shift $clk_tx_shift $clk_tx_shift" \
    [get_ports pad_hyper_ck[1]]


# Divide by two and invert; 90-degree-shifted
create_generated_clock -name CLK_PHY1_CK_N \
    -add \
    -master_clock [get_clocks CLK_HYP] \
    -source [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/clk_i}] \
    -edges {2 4 6} \
    -edge_shift "$clk_tx_shift $clk_tx_shift $clk_tx_shift" \
    [get_ports pad_hyper_ckn[1]]
        

# RWDS clock
create_generated_clock [get_pins -hier -filter {NAME =~ *i_hyperbus/i_phy/phy_wrap.phy_unroll[0].i_phy/i_trx/i_delay_rx_rwds_90/in_i}] \
                       -name CLK_RWDS_0 -edges {1 2 3} -edge_shift "$rwds_input_delay $rwds_input_delay $rwds_input_delay" \
                       -source [get_ports pad_hyper_rwds[0]]
create_generated_clock [get_nets -hier -filter {NAME =~ *i_hyperbus_wrap/i_phy/phy_wrap.phy_unroll[0].i_phy/src_clk_i}] \
                        -name CLK_RWDS_SAMPLE_0 -invert  -divide_by 1  \ 
                        -source [get_pins -hier -filter {NAME =~ *i_hyperbus/i_phy/phy_wrap.phy_unroll[0].i_phy/i_trx/i_delay_rx_rwds_90/in_i}] 
                        
create_generated_clock [get_pins -hier -filter {NAME =~ *i_hyperbus/i_phy/phy_wrap.phy_unroll[1].i_phy/i_trx/i_delay_rx_rwds_90/in_i}] \
                       -name CLK_RWDS_1 -edges {1 2 3} -edge_shift "$rwds_input_delay $rwds_input_delay $rwds_input_delay" \
                       -source [get_ports pad_hyper_rwds[1]]
create_generated_clock [get_nets -hier -filter {NAME =~ *i_hyperbus_wrap/i_phy/phy_wrap.phy_unroll[1].i_phy/src_clk_i}] \
                        -name CLK_RWDS_SAMPLE_1 -invert  -divide_by 1  \ 
                        -source [get_pins -hier -filter {NAME =~ *i_hyperbus_wrap/i_hyperbus/i_phy/phy_wrap.phy_unroll[1].i_phy/i_trx/i_delay_rx_rwds_90/in_i}]
                        
                        
set_clock_groups -name CLK_GROUP_1 -asynchronous \
    -group {hype_clk_clk_wiz_0} \
    -group {CLK_HYP} \
    -group {CLK_PHY0_CK CLK_PHY1_CK CLK_PHY0_CK_N CLK_PHY1_CK_N} \
    -group {CLK_RWDS_0 CLK_RWDS_SAMPLE_0 RWDS0_CLK} \
    -group {CLK_RWDS_1 CLK_RWDS_SAMPLE_1 RWDS1_CLK}


# At the current development stage the input and output delay are treated in the following way. A more accurate evaluation is needed.
set output_ports {{pad_hyper_dq*} pad_hyper_rwds*}
set_output_delay [expr $period_hyperbus/2] -clock CLK_PHY0_CK [get_ports $output_ports] -max
set_output_delay [expr $period_hyperbus/-2] -clock CLK_PHY0_CK [get_ports $output_ports] -min -add_delay
set_output_delay [expr $period_hyperbus/2] -clock CLK_PHY0_CK [get_ports $output_ports] -max -clock_fall -add_delay
set_output_delay [expr $period_hyperbus/-2] -clock CLK_PHY0_CK [get_ports $output_ports] -min -clock_fall -add_delay


set input_ports {{pad_hyper_dq*} pad_hyper_rwds*}
set_input_delay -max [expr $period_hyperbus/2] -clock CLK_PHY0_CK [get_ports $input_ports]
set_input_delay -min [expr $period_hyperbus/2] -clock CLK_PHY0_CK [get_ports $input_ports] -add_delay
set_input_delay -max [expr $period_hyperbus/2] -clock CLK_PHY0_CK [get_ports $input_ports] -add_delay -clock_fall
set_input_delay -min [expr $period_hyperbus/2] -clock CLK_PHY0_CK [get_ports $input_ports] -add_delay -clock_fall