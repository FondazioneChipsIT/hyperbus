# Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

#################
#     PBLOCK    #
#################

create_pblock pblock_i_hyperbus_wrap
add_cells_to_pblock [get_pblocks pblock_i_hyperbus_wrap] [get_cells -quiet [list i_hyperbus_wrap]]
resize_pblock [get_pblocks pblock_i_hyperbus_wrap] -add {SLICE_X2Y305:SLICE_X166Y651}
resize_pblock [get_pblocks pblock_i_hyperbus_wrap] -add {DSP48E2_X0Y122:DSP48E2_X18Y259}
resize_pblock [get_pblocks pblock_i_hyperbus_wrap] -add {RAMB18_X0Y122:RAMB18_X11Y259}
resize_pblock [get_pblocks pblock_i_hyperbus_wrap] -add {RAMB36_X0Y61:RAMB36_X11Y129}
resize_pblock [get_pblocks pblock_i_hyperbus_wrap] -add {URAM288_X0Y84:URAM288_X3Y171}