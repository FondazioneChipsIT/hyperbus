// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Philippe Sauter <phsauter@iis.ee.ethz.ch>

(* no_ungroup *)
(* no_boundary_optimization *)
(* keep_hierarchy = "yes" *)
module hyperbus_clk_delay
(
    input  logic       rst_i,
    input  logic       clk_ref200_i, // 200 MHz reference clock
    input  logic       clk_i,        // control clock used to load delay_i
    input  logic       in_i,
    input  logic [4:0] delay_i,
    output logic       out_o
);

    IDELAYCTRL 
`ifdef ULTRASCALE
    #(
    .SIM_DEVICE("ULTRASCALE")
    )
`endif    
    i_delayctrl
    (
        .REFCLK ( clk_ref200_i ),
        .RST    ( rst_i ),
        .RDY    ()
    );


`ifdef ULTRASCALE
    // Ultrascale FGPAs require IDELAY3
    IDELAYE3 #(
        .CASCADE("NONE"),
        .DELAY_FORMAT("COUNT"),
        .DELAY_TYPE("VAR_LOAD"),
        .DELAY_VALUE(0),
        .DELAY_SRC("DATAIN"), 
        .REFCLK_FREQUENCY(200.0),
        .UPDATE_MODE("ASYNC"),
        .SIM_DEVICE("ULTRASCALE_PLUS")
    ) i_delay (
        .DATAOUT(out_o),
        .DATAIN(in_i),
        .IDATAIN(1'b0),
    
        .CNTVALUEIN(delay_i),
        .CNTVALUEOUT(),
    
        .LOAD(1'b1),
        .CE(1'b0),
        .INC(1'b0),
    
        .CLK(clk_i),
        .RST(rst_i),
    
        .EN_VTC(1'b0),
    
        .CASC_IN(1'b0),
        .CASC_RETURN(1'b0)
    );
`else 
    IDELAYE2 #(
        .CINVCTRL_SEL          ( "FALSE"    ), // "TRUE" actives CINVCTRL functionality
        .DELAY_SRC             ( "DATAIN"   ), // source to delay chain ("CLKIN" or "IDATAIN")
        .HIGH_PERFORMANCE_MODE ( "TRUE"     ),  // "TRUE" for less jitter; "FALSE" for low power
        .IDELAY_TYPE           ( "VAR_LOAD" ), // mode of operation, see above
        .IDELAY_VALUE          ( 0          ), // delay value 0-31 (used in "VARIABLE" and "FIXED" mode)
        .PIPE_SEL              ( "FALSE"    ), // "TRUE" activates pipelined operation 
        .REFCLK_FREQUENCY      ( 200.0      ), // used for STA and simulation (190.0 - 310.0 MHz)
        .SIGNAL_PATTERN        ( "CLOCK"    ) // "DATA" or "CLOCK" depending on function, used in STA
    ) i_delay (
        .REGRST      ( rst_i       ), // input: reset delay tap value to IDELAY_VALUE or CNTVALUEIN
        .C           ( clk_i       ), // input: control input clock
        .DATAIN      ( in_i        ), // input: signal from FPGA logic to be delayed
        .IDATAIN     ( 1'b0        ), // input: signal from IO to be delayed
        .DATAOUT     ( out_o       ), // output: delayed from DATAIN or IDATAIN (drives ISERDESE2 or logic, not IO!)
        .CE          ( 1'b0        ), // input: increment/decrement enable
        .CINVCTRL    ( 1'b0        ), // input: switch clock polarity during operation (glitches!)
        .CNTVALUEIN  ( delay_i     ), // 5 bit input: delay tap
        .CNTVALUEOUT (             ), // 5 bit output: delay tap
        .LD          ( 1'b1        ), // input: load IDELAY_VALUE param or CNTVALUEIN (depends on IDELAY_TYPE)
        .INC         ( 1'b0        ), // input: increment/decrement delay tap
        .LDPIPEEN    ( 1'b0        ) // input: enable the pipeline register to load data from LD
    );
`endif 


endmodule
