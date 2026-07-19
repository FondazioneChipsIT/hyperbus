// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Andrea Di Ruzza

`include "register_interface/typedef.svh"

module hyperbus_wrap
#(
  parameter int unsigned NumChips        = -1,
  parameter int unsigned NumPhys         = 2,
  parameter int unsigned AxiAddrWidth    = -1,
  parameter int unsigned AxiDataWidth    = -1,
  parameter int unsigned AxiIdWidth      = -1,
  parameter int unsigned AxiUserWidth    = -1,
  parameter int unsigned AxiMaxTrans     = 0 ,
  parameter type         axi_req_t       = logic,
  parameter type         axi_rsp_t       = logic,
  parameter type         axi_reg_req_t    = logic,
  parameter type         axi_reg_rsp_t    = logic,
  parameter type         axi_w_chan_t    = logic,
  parameter type         axi_b_chan_t    = logic,
  parameter type         axi_ar_chan_t   = logic,
  parameter type         axi_r_chan_t    = logic,
  parameter type         axi_aw_chan_t   = logic,
  parameter int unsigned RegAddrWidth    = -1,
  parameter int unsigned RegDataWidth    = -1,
  parameter int unsigned  MinFreqMHz     = 100,
  parameter type         reg_req_t       = logic,
  parameter type         reg_rsp_t       = logic,
  // The below have sensible defaults, but should be set on integration!
  parameter int unsigned RxFifoLogDepth  = 2,
  parameter int unsigned TxFifoLogDepth  = 2,
  parameter logic [RegDataWidth-1:0] RstChipBase  = 'h0,      // Base address for all chips
  parameter logic [RegDataWidth-1:0] RstChipSpace = 'h1_0000, // 64 KiB: Current maximum H
                                                              // yperBus device size
  parameter int unsigned PhyStartupCycles = 300 * 200, /* us*MHz */
                                                       // Conservative maximum
                                                       // frequency estimate
  parameter int unsigned AxiLogDepth     = 3,
  parameter int unsigned AxiSlaveArWidth = 0,
  parameter int unsigned AxiSlaveAwWidth = 0,
  parameter int unsigned AxiSlaveBWidth  = 0,
  parameter int unsigned AxiSlaveRWidth  = 0,
  parameter int unsigned AxiSlaveWWidth  = 0,
  parameter int unsigned CdcSyncStages   = 0
)(
  input  logic clk_i,
  input  logic rst_ni,
  input  logic test_mode_i,

  input  axi_reg_req_t axi_reg_req,
  output axi_reg_rsp_t axi_reg_rsp,
    
  input  axi_req_t hyper_req,
  output axi_rsp_t hyper_rsp,

  // Reference clock for the IDELAY Xilinx primitive
  input clk_ref200_i,

  // Hyperbus pinout
  inout  [NumPhys-1:0][NumChips-1:0] pad_hyper_csn,
  inout  [NumPhys-1:0]               pad_hyper_ck,
  inout  [NumPhys-1:0]               pad_hyper_ckn,
  inout  [NumPhys-1:0]               pad_hyper_rwds,
  inout  [NumPhys-1:0]               pad_hyper_reset,
  inout  [NumPhys-1:0][7:0]          pad_hyper_dq
);

logic rst_n;
logic clk_phy;
logic ph_phy;

reg_req_t reg_req;
reg_rsp_t reg_rsp;

typedef struct packed {
  logic [31:0]             idx;
  logic [AxiAddrWidth-1:0] start_addr;
  logic [AxiAddrWidth-1:0] end_addr;
} addr_rule_t;


axi_to_reg_v2 #(
  .AxiAddrWidth(AxiAddrWidth),
  .AxiDataWidth(RegDataWidth),
  .AxiIdWidth(AxiIdWidth),
  .AxiUserWidth(AxiUserWidth),
  .RegDataWidth(RegDataWidth),
  .axi_req_t(axi_reg_req_t),
  .axi_rsp_t(axi_reg_rsp_t),
  .reg_req_t(reg_req_t),
  .reg_rsp_t(reg_rsp_t),
  .id_t() //?
)(
  .clk_i(clk_i),
  .rst_ni,
  .axi_req_i(axi_reg_req),
  .axi_rsp_o(axi_reg_rsp),
  .reg_req_o(reg_req),
  .reg_rsp_i(reg_rsp),
  .reg_id_o(), // Is this important? Can I leave it unassigned?
  .busy_o() // Is this important? Can I leave it unassigned?
);


axi_req_t hyper_int_req;
axi_rsp_t hyper_int_rsp;

axi_cdc #(
  .aw_chan_t      ( axi_aw_chan_t ),
  .w_chan_t       ( axi_w_chan_t  ),
  .b_chan_t       ( axi_b_chan_t  ),
  .ar_chan_t      ( axi_ar_chan_t ),
  .r_chan_t       ( axi_r_chan_t  ),
  .axi_req_t      ( axi_req_t     ),
  .axi_resp_t     ( axi_rsp_t     ),
  .LogDepth(2),
  .SyncStages(2)
) (
  .src_clk_i(clk_i),
  .src_rst_ni(rst_ni),
  .src_req_i(hyper_req),
  .src_resp_o(hyper_rsp),
  .dst_clk_i(clk_phy),
  .dst_rst_ni(rst_ni),
  .dst_req_o(hyper_int_req),
  .dst_resp_i(hyper_int_rsp)
);

rstgen i_hyper_rstgen (
  .clk_i   ( clk_i ),
  .rst_ni,
  .test_mode_i,
  .rst_no  ( rst_n ),
  .init_no ( )
);

hyperbus_clk_gen i_hyper_clk_gen (
    .clk_i    ( clk_i ),
    .rst_ni   ( rst_n ),
    .clk_phy_o ( clk_phy ),
    .ph_phy_o  ( ph_phy )
);

(* mark_debug = "true" *) logic [NumPhys-1:0][NumChips-1:0] hyper_cs_no;
(* mark_debug = "true" *) logic [NumPhys-1:0] hyper_ck_o;
(* mark_debug = "true" *) logic [NumPhys-1:0] hyper_ck_no;
(* mark_debug = "true" *) logic [NumPhys-1:0] hyper_rwds_o;
(* mark_debug = "true" *) logic [NumPhys-1:0] hyper_rwds_i;
(* mark_debug = "true" *) logic [NumPhys-1:0] hyper_rwds_oe_o;
(* mark_debug = "true" *) logic [NumPhys-1:0][7:0] hyper_dq_i;
(* mark_debug = "true" *) logic [NumPhys-1:0][7:0] hyper_dq_o;
(* mark_debug = "true" *) logic [NumPhys-1:0][7:0] hyper_dq_oe_o;
(* mark_debug = "true" *) logic [NumPhys-1:0] hyper_reset_no;
(* mark_debug = "true" *) logic [NumPhys-1:0][7:0] hyper_pad_cfg_o;

hyperbus           #(
  .NumChips         ( NumChips         ),
  .NumPhys          ( NumPhys          ),
  .AxiAddrWidth     ( AxiAddrWidth     ),
  .AxiDataWidth     ( AxiDataWidth     ),
  .AxiIdWidth       ( AxiIdWidth       ),
  .AxiUserWidth     ( AxiUserWidth     ),
  .axi_req_t        ( axi_req_t        ),
  .axi_rsp_t        ( axi_rsp_t        ),
  .RegAddrWidth     ( RegAddrWidth     ),
  .RegDataWidth     ( RegDataWidth     ),
  .reg_req_t        ( reg_req_t        ),
  .reg_rsp_t        ( reg_rsp_t        ),
  .axi_rule_t       ( addr_rule_t      ),

  .MinFreqMHz       ( MinFreqMHz ),
  .RxFifoLogDepth   ( RxFifoLogDepth   ),
  .TxFifoLogDepth   ( TxFifoLogDepth   ),
  .RstChipBase      ( RstChipBase      ),
  .RstChipSpace     ( RstChipSpace     ),
  .PhyStartupCycles ( PhyStartupCycles ),
  .SyncStages       ( CdcSyncStages    )
) i_hyperbus        (
  .clk_phy_x2_i     ( clk_i              ),
  .clk_phy_i        ( clk_phy            ),
  .rst_ni           ( rst_n              ),
  .ph_phy_i         ( ph_phy             ),
  .test_mode_i      ( test_mode_i        ),
  .axi_req_i        ( hyper_int_req      ),
  .axi_rsp_o        ( hyper_int_rsp      ),
  .reg_req_i        ( reg_req            ),
  .reg_rsp_o        ( reg_rsp            ),
  .clk_ref200_i,
  .hyper_cs_no,
  .hyper_ck_o,
  .hyper_ck_no,
  .hyper_rwds_o,
  .hyper_rwds_i,
  .hyper_rwds_oe_o,
  .hyper_dq_i,
  .hyper_dq_o,
  .hyper_dq_oe_o,
  .hyper_reset_no,
  .hyper_pad_cfg_o
);


genvar i, j;
generate
  for(i=0; i<NumPhys; i++) begin: gen_phys
    pad_functional_pu padinst_hyper_rwds  (
      .OEN( ~hyper_rwds_oe_o[i] ),
      .I  ( hyper_rwds_o[i]     ),
      .O  ( hyper_rwds_i[i]     ),
      .PAD( pad_hyper_rwds[i]   ),
      .PEN( 1'b1                )
      );

    pad_functional_pu padinst_hyper_csn0  (
      .OEN( 1'b0                ),
      .I  ( hyper_cs_no[i][0]   ),
      .O  (                     ),
      .PAD( pad_hyper_csn[i][0] ),
      .PEN( 1'b1                )
       );

    pad_functional_pu padinst_hyper_csn1  (
      .OEN( 1'b0                ),
      .I  ( hyper_cs_no[i][1]   ),
      .O  (                     ),
      .PAD( pad_hyper_csn[i][1] ),
      .PEN( 1'b1                )
      );

    pad_functional_pu padinst_hyper_clk   (
      .OEN( 1'b0                ),
      .I  ( hyper_ck_o[i]       ),
      .O  (                     ),
      .PAD( pad_hyper_ck[i]     ),
      .PEN( 1'b1                )
      );

    pad_functional_pu padinst_hyper_clkn  (
      .OEN( 1'b0                ),
      .I  ( hyper_ck_no[i]      ),
      .O  (                     ),
      .PAD( pad_hyper_ckn[i]    ),
      .PEN( 1'b1                )
      );

    pad_functional_pu padinst_hyper_reset (
      .OEN( 1'b0                ),
      .I  ( hyper_reset_no[i]   ),
      .O  (                     ),
      .PAD( pad_hyper_reset[i]  ),
      .PEN( 1'b1                )
      );

    for (j=0; j<8; j++) begin: gen_dq
      pad_functional_pu padinst_hyper_dqio  (
        .OEN(~hyper_dq_oe_o[i][j]   ),
        .I  ( hyper_dq_o[i][j]      ),
        .O  ( hyper_dq_i[i][j]      ),
        .PAD( pad_hyper_dq[i][j]    ),
        .PEN( 1'b1                  )
        );
    end
  end
endgenerate

endmodule: hyperbus_wrap