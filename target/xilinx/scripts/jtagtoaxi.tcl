# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Carlotta Chiarini

# This tcl file is used to configure the Hyperbus registers and to start the test

#**************************** CONFIGURATION REGISTERS *********************************#
set hyperbus_regs {
  {reg_t_latency_access 1000_0000}
  {reg_en_latency_additional 1000_0004}
  {reg_t_burst_max 1000_0008}
  {reg_t_read_write_recovery 1000_000C}
  {reg_rx_clk_delay 1000_0010}
  {reg_tx_clk_delay 1000_0014}
  {reg_address_mask_msb 1000_0018}
  {reg_address_space 1000_001C}
  {reg_phys_in_use 1000_0020}
  {reg_which_phy 1000_0024}
  {reg_t_csh_cycles 1000_0028}
  {reg_csn_to_ck_cycles 1000_002C}
  {reg_rwds_sample 1000_0030}
  {reg_t_pad_cfgn 1000_0034}
  {reg_chip0_base_addr 1000_0038}
  {reg_chip0_end_addr 1000_003c}
  {reg_chip1_base_addr 1000_0040}
  {reg_chip1_end_addr 1000_0044}
}


#************************************** SETUP JTAG **************************************#
proc setup_hw {{port 3122}} {
  open_hw_manager
  connect_hw_server -url $host
  open_hw_target [lindex [get_hw_targets] 0]
  current_hw_device [lindex [get_hw_devices] 0]
  refresh_hw_device [lindex [get_hw_devices] 0]
}



#********************************** READ&WRITE REGISTERS *********************************#
proc hyper_init {} {

  global hyperbus_regs
  foreach item $hyperbus_regs {
        lassign $item name address
        if {$name == "reg_chip0_base_addr"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_0000_0000
        } elseif {$name == "reg_chip0_end_addr"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_0800_0000
        } elseif {$name == "reg_chip1_base_addr"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_0800_0000
        } elseif {$name == "reg_chip1_end_addr"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_1000_0000
        }  elseif {$name == "reg_phys_in_use"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_0000_0001
        }  elseif {$name == "reg_which_phy"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_0000_0001
        } elseif {$name == "reg_t_latency_access"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_0000_0007
        } elseif {$name == "reg_t_read_write_recovery"} {
          create_hw_axi_txn wr [get_hw_axis hw_axi_1] -type write -address $address -data 0000_0000_0000_0007
        } else {
        # Do nothing
        }
        run_hw_axi wr
        delete_hw_axi_txn wr
  }
}


proc read_register {} {

  array set read_element {}
  global hyperbus_regs
  foreach item $hyperbus_regs {
        lassign $item name address
        create_hw_axi_txn rd [get_hw_axis hw_axi_1] -type read -address $address -quiet
        run_hw_axi [get_hw_axi_txns rd] -quiet
        set read_element($name) [get_property DATA [get_hw_axi_txns rd]]
        delete_hw_axi_txn rd
  }

  puts " "
  puts "-----------------HYPERBUS REGS-------------------"
  puts "LATENCY ACCESS 0x$read_element(reg_t_latency_access)"
  puts "EN_LATENCY_ADDITIONAL 0x$read_element(reg_en_latency_additional)"
  puts "BURST_MAX 0x$read_element(reg_t_burst_max)"
  puts "READ_WRITE_RECOVERY 0x$read_element(reg_t_read_write_recovery)"
  puts "RX_CLK_DELAY 0x$read_element(reg_rx_clk_delay)"
  puts "TX_CLK_DELAY 0x$read_element(reg_tx_clk_delay)"
  puts "ADDRESS_MASK_MSB 0x$read_element(reg_address_mask_msb)"
  puts "ADDRESS_SPACE 0x$read_element(reg_address_space)"
  puts "PHYS_IN_USE 0x$read_element(reg_phys_in_use)"
  puts "WHICH_PHY 0x$read_element(reg_which_phy)"
  puts "CSH_CYCLES 0x$read_element(reg_t_csh_cycles)"
  puts "CSN_TO_CK_CYCLES 0x$read_element(reg_csn_to_ck_cycles)"
  puts "RWDS_SAMPLE 0x$read_element(reg_rwds_sample)"
  puts "PAD_CFGN 0x$read_element(reg_t_pad_cfgn)"
  puts "CHIP0_START_ADDR 0x$read_element(reg_chip0_base_addr)"
  puts "CHIP0_END_ADDR 0x$read_element(reg_chip0_end_addr)"
  puts "CHIP1_START_ADDR 0x$read_element(reg_chip1_base_addr)"
  puts "CHIP1_END_ADDR 0x$read_element(reg_chip0_end_addr)"

  array unset read_element
}

