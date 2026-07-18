// Copyright 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Carlotta Chiarini

`include "axi/typedef.svh"
`include "register_interface/typedef.svh"
//`include "phy_definitions.svh"

module hyperbus_top_xilinx
(
  input logic       sys_clk_p,
  input logic       sys_clk_n,

  input logic       cpu_reset,
  
  inout  [1:0][1:0] pad_hyper_csn,
  inout  [1:0]      pad_hyper_ck,
  inout  [1:0]      pad_hyper_ckn,
  inout  [1:0]      pad_hyper_rwds,
  inout  [1:0]      pad_hyper_reset,
  inout  [1:0][7:0] pad_hyper_dq
);

  logic hyp_clk;
  logic clk_100, clk_200, clk_20;
  logic sys_clk, sys_rst;
  
  (* dont_touch = "yes" *) logic rst_n;

  logic vio_reset;
  
  axi_pkg::xbar_rule_32_t[1:0] axi_xbar_rule;

  xlnx_vio (
    .clk(soc_clk),
    .probe_out0(vio_reset)
  );

  clk_wiz_0 i_xlnx_clk_wiz (
    .clk_in1_n ( sys_clk_n  ),
    .clk_in1_p ( sys_clk_p  ),
    .reset   ( '0       ),
    .clk_20  ( clk_20   ),
    .clk_100 ( clk_100  ),
    .clk_200 ( clk_200  )
  );
  
  assign sys_rst = cpu_reset | vio_reset;
  assign soc_clk = clk_100;
  assign hyp_clk = clk_20;
 

  rstgen i_rstgen_main (
    .clk_i        ( soc_clk                  ),
    .rst_ni       ( ~sys_rst                 ),
    .test_mode_i  ( 1'b0                     ),
    .rst_no       ( rst_n                    ),
    .init_no      (                          ) // keep open
  );

  // Used for the axi interface
  localparam int unsigned AddrWidth = 32;
  localparam int unsigned AxiDataWidth = 64;
  
  // Used for the registers
  localparam int unsigned AxiNarrowAddrWidth = 32;
  localparam int unsigned AxiNarrowDataWidth = 32;
  
  // Used for the axi crossbar
  localparam int unsigned AxiIdWidth = 1;
  localparam int unsigned AxiUserWidth = 32;
  localparam int unsigned SlaveArWidth = 32;
  localparam int unsigned SlaveAwWidth = 32;
  localparam int unsigned SlaveBWidth = 32;
  localparam int unsigned SlaveRWidth = 32;
  localparam int unsigned SlaveWWidth = 32;
  localparam int unsigned LogDepth = 32;
  localparam int unsigned AxiMaxSlvTrans = 32;
  localparam int unsigned SyncStages = 32;

  // Used for Hyperbus
  localparam int unsigned NumChips = 2;
  localparam int unsigned NumPhys = 2;
  
  
  `AXI_TYPEDEF_ALL_CT(axi, axi_req_t, axi_rsp_t, logic[AddrWidth-1:0], logic[AxiIdWidth-1:0], logic[AxiDataWidth-1:0], logic[AxiDataWidth/8-1:0], logic[AxiUserWidth-1:0])
  `REG_BUS_TYPEDEF_ALL(hyper_reg, logic [31:0], logic [31:0], logic [3:0])

  (* mark_debug = "true" *) axi_req_t jtag_axi_req;
  (* mark_debug = "true" *) axi_rsp_t jtag_axi_rsp;

  jtag_axi_0 i_jtag_to_axi (
    .aclk           (hyp_clk),
    .aresetn        (rst_n),

    .m_axi_awid     (jtag_axi_req.aw.id),
    .m_axi_awaddr   (jtag_axi_req.aw.addr),
    .m_axi_awlen    (jtag_axi_req.aw.len),
    .m_axi_awsize   (jtag_axi_req.aw.size),
    .m_axi_awburst  (jtag_axi_req.aw.burst),
    .m_axi_awlock   (jtag_axi_req.aw.lock),
    .m_axi_awcache  (jtag_axi_req.aw.cache),
    .m_axi_awprot   (jtag_axi_req.aw.prot),
    .m_axi_awqos    (jtag_axi_req.aw.qos),
    .m_axi_awvalid  (jtag_axi_req.aw_valid),
    .m_axi_awready  (jtag_axi_rsp.aw_ready),

    .m_axi_wdata    (jtag_axi_req.w.data),
    .m_axi_wstrb    (jtag_axi_req.w.strb),
    .m_axi_wlast    (jtag_axi_req.w.last),
    .m_axi_wvalid   (jtag_axi_req.w_valid),
    .m_axi_wready   (jtag_axi_rsp.w_ready),

    .m_axi_bid      (jtag_axi_rsp.b.id),
    .m_axi_bresp    (jtag_axi_rsp.b.resp),
    .m_axi_bvalid   (jtag_axi_rsp.b_valid),
    .m_axi_bready   (jtag_axi_req.b_ready),

    .m_axi_arid     (jtag_axi_req.ar.id),
    .m_axi_araddr   (jtag_axi_req.ar.addr),
    .m_axi_arlen    (jtag_axi_req.ar.len),
    .m_axi_arsize   (jtag_axi_req.ar.size),
    .m_axi_arburst  (jtag_axi_req.ar.burst),
    .m_axi_arlock   (jtag_axi_req.ar.lock),
    .m_axi_arcache  (jtag_axi_req.ar.cache),
    .m_axi_arprot   (jtag_axi_req.ar.prot),
    .m_axi_arqos    (jtag_axi_req.ar.qos),
    .m_axi_arvalid  (jtag_axi_req.ar_valid),
    .m_axi_arready  (jtag_axi_rsp.ar_ready),

    .m_axi_rid      (jtag_axi_rsp.r.id),
    .m_axi_rdata    (jtag_axi_rsp.r.data),
    .m_axi_rresp    (jtag_axi_rsp.r.resp),
    .m_axi_rlast    (jtag_axi_rsp.r.last),
    .m_axi_rvalid   (jtag_axi_rsp.r_valid),
    .m_axi_rready   (jtag_axi_req.r_ready)
  );

  // Connectivity of Xbar
  (* mark_debug = "true" *) axi_req_t [1:0]  axi_out_req;
  (* mark_debug = "true" *) axi_rsp_t [1:0]  axi_out_rsp;

  // Configure AXI Xbar
  localparam axi_pkg::xbar_cfg_t AxiXbarCfg = '{
    NoSlvPorts:         1,
    NoMstPorts:         2,
    MaxMstTrans:        AxiMaxSlvTrans,
    MaxSlvTrans:        AxiMaxSlvTrans,
    FallThrough:        0,
    LatencyMode:        axi_pkg::CUT_ALL_PORTS,
    PipelineStages:     0,
    AxiIdWidthSlvPorts: 1,
    AxiIdUsedSlvPorts:  1,
    UniqueIds:          0,
    AxiAddrWidth:       AddrWidth,
    AxiDataWidth:       AxiDataWidth,
    NoAddrRules:        2
  };

  assign axi_xbar_rule[0] = '{idx: 32'd0, start_addr: 'h0, end_addr:'h1000_0000 }; // MEM
  assign axi_xbar_rule[1] = '{idx: 32'd1, start_addr: 'h1000_0000, end_addr: 'h2000_0000 }; // REG

  axi_xbar #(
    .Cfg            ( AxiXbarCfg ),
    .ATOPs          ( 1  ),
    .Connectivity   ( '1 ),
    .slv_aw_chan_t  ( axi_aw_chan_t ),
    .mst_aw_chan_t  ( axi_aw_chan_t ),
    .w_chan_t       ( axi_w_chan_t  ),
    .slv_b_chan_t   ( axi_b_chan_t  ),
    .mst_b_chan_t   ( axi_b_chan_t  ),
    .slv_ar_chan_t  ( axi_ar_chan_t ),
    .mst_ar_chan_t  ( axi_ar_chan_t ),
    .slv_r_chan_t   ( axi_r_chan_t  ),
    .mst_r_chan_t   ( axi_r_chan_t  ),
    .slv_req_t      ( axi_req_t ),
    .slv_resp_t     ( axi_rsp_t ),
    .mst_req_t      ( axi_req_t ),
    .mst_resp_t     ( axi_rsp_t ),
    .rule_t         ( axi_pkg::xbar_rule_32_t )
  ) i_axi_xbar (
    .clk_i(hyp_clk),
    .rst_ni(rst_n),
    .test_i                 ( 1'b0 ),
    .slv_ports_req_i        ( jtag_axi_req ),
    .slv_ports_resp_o       ( jtag_axi_rsp ),
    .mst_ports_req_o        ( axi_out_req ),
    .mst_ports_resp_i       ( axi_out_rsp ),
    .addr_map_i             ( axi_xbar_rule ),
    .en_default_mst_port_i  ( '0 ),
    .default_mst_port_i     ( '0 )
  );

  ///////////////////
  // HYPE CLK      //
  ///////////////////

  // We want to be able to test the hyperbus with several clocks, in order to catch the functional limit of the IP on FPGA

  /*localparam int unsigned HyperDivWidth = 20;
  localparam int unsigned DefaultHyperClkDivValue = 1;  

  logic hyper_clk_decoupled_valid, hyper_clk_decoupled_ready;

  lossy_valid_to_stream #(
    .T(logic [HyperDivWidth-1:0])
  ) i_hyperbus_decouple (
    .clk_i   ( clk_200 ),
    .rst_ni  ( rst_n ),
    .valid_i ( hyperbus_regs_reg2hw.clk_div_value.qe ),
    .data_i  ( hyperbus_regs_reg2hw.clk_div_value.q  ),
    .valid_o ( hyper_clk_decoupled_valid ),
    .ready_i ( hyper_clk_decoupled_ready ),
    .data_o  ( ),
    .busy_o  ( )
  );

  clk_int_div #(
    .DIV_VALUE_WIDTH ( HyperDivWidth ),
    .DEFAULT_DIV_VALUE ( DefaultHyperClkDivValue ),
    .ENABLE_CLOCK_IN_RESET ( 1 )
  ) i_hyper_clk_div (
    .clk_i                 ( periph_clk ),
    .rst_ni                ( periph_rst_n ),
    .en_i                  ( hyperbus_regs_reg2hw.clk_div_en.q ),
    .test_mode_en_i        ( test_mode_i ),
    .div_i                 ( hyperbus_regs_reg2hw.clk_div_value.q ),
    .div_valid_i           ( hyper_clk_decoupled_valid ),
    .div_ready_o           ( hyper_clk_decoupled_ready ),
    .clk_o                 ( hyp_clk ),
    .cycl_count_o          (  )
  );
*/


// Hyperbus
hyperbus_wrap      #(
  .NumChips         ( NumChips                            ),
  .NumPhys          ( NumPhys                             ),
 // .UsePhyClkDivider ( 1'b1                                ),
  .AxiAddrWidth     ( AddrWidth                           ),
  .AxiDataWidth     ( AxiDataWidth                        ),
  .AxiIdWidth       ( AxiIdWidth                          ),
  .AxiUserWidth     ( AxiUserWidth                        ),
  .axi_req_t        ( axi_req_t                           ),
  .axi_rsp_t        ( axi_rsp_t                           ),
  .RegAddrWidth     ( AxiNarrowAddrWidth                  ),
  .RegDataWidth     ( AxiNarrowDataWidth                  ),
  .reg_req_t        ( hyper_reg_req_t                     ),
  .reg_rsp_t        ( hyper_reg_rsp_t                     ),
  .axi_aw_chan_t      ( axi_aw_chan_t ),
  .axi_w_chan_t       ( axi_w_chan_t  ),
  .axi_b_chan_t       ( axi_b_chan_t  ),
  .axi_ar_chan_t      ( axi_ar_chan_t ),
  .axi_r_chan_t       ( axi_r_chan_t  ),
  .RxFifoLogDepth   ( 32'd2                               ),
  .TxFifoLogDepth   ( 32'd2                               ),
  .RstChipBase      ( 'h0                                 ),
  .RstChipSpace     ( NumChips * NumPhys * 'h800_0000     ),
  .PhyStartupCycles ( 300 * 200                           ),
  .AxiLogDepth      ( LogDepth                            ),
  .AxiSlaveArWidth  ( SlaveArWidth                        ),
  .AxiSlaveAwWidth  ( SlaveAwWidth                        ),
  .AxiSlaveBWidth   ( SlaveBWidth                         ),
  .AxiSlaveRWidth   ( SlaveRWidth                         ),
  .AxiSlaveWWidth   ( SlaveWWidth                         ),
  .AxiMaxTrans      ( AxiMaxSlvTrans                      ),
  .CdcSyncStages    ( SyncStages                          )
) i_hyperbus_wrap   (
  .clk_i               ( hyp_clk              ),
  .rst_ni              ( rst_n                ),
  .test_mode_i         ( 1'b0                 ),
  .axi_reg_req         ( axi_out_req[1]       ),
  .axi_reg_rsp         ( axi_out_rsp[1]       ),
  .hyper_req           ( axi_out_req[0]       ),
  .hyper_rsp           ( axi_out_rsp[0]       ),
  // Reference clock for the IDELAY Xilinx primitive
  .clk_ref200_i(clk_200),
  // Hyperbus pinout
  .pad_hyper_csn,
  .pad_hyper_ck,
  .pad_hyper_ckn,
  .pad_hyper_rwds,
  .pad_hyper_dq,
  .pad_hyper_reset
);


endmodule
