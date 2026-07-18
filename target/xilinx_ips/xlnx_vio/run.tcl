# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name xlnx_vio
set_property -dict [list CONFIG.C_NUM_PROBE_OUT {1} \
                         CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT0_WIDTH {1} \
                         CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
                         CONFIG.C_NUM_PROBE_IN {0} \
                   ] [get_ips xlnx_vio]
