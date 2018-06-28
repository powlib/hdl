`timescale 1ns / 1ps

module powlib_sfifo(wrdata,wrvld,wrrdy,rddata,rdvld,rdrdy,clk,rst);

`include "powlib_std.vh"

  parameter                     W    = 16;       // Width
  parameter                     D    = 8;        // Depth
  parameter                     EAR  = 0;
  parameter                     EDBG = 0;        // Enable debug statements
  parameter                     ID   = "SFIFO";  // String identifier
  input      wire               clk;
  input      wire               rst;
  input      wire    [W-1:0]    wrdata;
  input      wire               wrvld;
  output     wire               wrrdy;
  output     wire    [W-1:0]    rddata;
  output     wire               rdvld;
  input      wire               rdrdy;
  
  localparam integer            WPTR =  powlib_clogb2(D);
  
             wire    [WPTR-1:0] wrptr, rdptr, rdptrm1;      
             
  assign                        wrrdy = wrptr!=rdptrm1;
             wire               wrinc = wrvld && wrrdy; 
             wire               wrclr = (wrptr==(D-1)) && wrinc;    
             
  assign                        rdvld = rdptr!=wrptr;
             wire               rdinc = rdvld && rdrdy;    
             wire               rdclr = (rdptr==(D-1)) && rdinc;                
  
  powlib_cntr     #(.W(WPTR),.ELD(0),.EAR(EAR))                 wrcntr_inst  (.cntr(wrptr),.adv(wrinc),.clr(wrclr),.clk(clk),.rst(rst));
  powlib_cntr     #(.W(WPTR),.ELD(0),.EAR(EAR))                 rdcntr_inst  (.cntr(rdptr),.adv(rdinc),.clr(rdclr),.clk(clk),.rst(rst));
  powlib_flipflop #(.W(WPTR),.INIT(D-1),.EVLD(1),.EAR(EAR))     rdptrm1_inst (.d(rdptr),.q(rdptrm1),.clk(clk),.rst(rst),.vld(rdinc));
  
  powlib_dpram    #(.W(W),.D(D),.EDBG(EDBG),.ID({ID,"_DPRAM"})) ram_inst     (.wridx(wrptr),.wrdata(wrdata),.wrvld(wrinc),.rdidx(rdptr),.rddata(rddata),.clk(clk));
  
endmodule

module powlib_afifo_wrcntrl(wrptr,graywrptr,grayrdptrm1,wrvld,wrrdy,wrinc,wrclk,wrrst);

`include "powlib_std.vh"

  parameter              W   = 16;        
  parameter              EAR = 0;
  output    wire [W-1:0] wrptr;
  output    wire [W-1:0] graywrptr;
  input     wire [W-1:0] grayrdptrm1;
  input     wire         wrvld;
  output    wire         wrrdy;
  output    wire         wrinc;
  input     wire         wrclk;
  input     wire         wrrst;
            wire [W-1:0] wrptr0;
            wire         wrinc0 = wrvld && wrrdy0;
            wire         wrrdy0 = graywrptr!=grayrdptrm1;
  assign                 wrinc  = wrinc0;
  assign                 wrrdy  = wrrdy0;
  
  powlib_flipflop #(.W(W),.INIT(0),.EAR(EAR),.EVLD(1)) wrptr0_inst (
    .d(wrptr0),.q(wrptr),.vld(wrinc0),.clk(wrclk),.rst(wrrst));
    
  powlib_grayencodeff #(.W(W),.INIT(0),.EAR(EAR),.EVLD(1)) encode_inst (
    .d(wrptr0),.q(graywrptr),.vld(wrinc0),.clk(wrclk),.rst(wrrst));
    
  powlib_cntr #(.W(W),.INIT(1),.EAR(EAR),.ELD(0)) cntr_inst (
    .cntr(wrptr0),.adv(wrinc0),.clr(0),.clk(wrclk),.rst(wrrst));
  
endmodule

module powlib_afifo_rdcntrl(rdptr,grayrdptrm1,graywrptr,rdvld,rdrdy,rdclk,rdrst);

`include "powlib_std.vh"

  parameter              W   = 16;        
  parameter              EAR = 0;
  output    wire [W-1:0] rdptr;
  output    wire [W-1:0] grayrdptrm1;
  input     wire [W-1:0] graywrptr;
  output    wire         rdvld;
  input     wire         rdrdy;
  input     wire         rdclk;
  input     wire         rdrst;
            wire [W-1:0] grayrdptr;
            wire         rdvld0 = graywrptr!=grayrdptr;
            wire [W-1:0] rdptr0;
            wire         rdinc0 = rdvld0 && rdrdy;
  assign                 rdvld  = rdvld0;
  
  powlib_flipflop #(.W(W),.INIT(0),.EAR(EAR),.EVLD(1)) rdptr0_inst (
    .d(rdptr0),.q(rdptr),.vld(rdinc0),.clk(rdclk),.rst(rdrst));
    
  powlib_flipflop #(.W(W),.INIT(powlib_grayencode({W{1'd1}})),.EAR(EAR),.EVLD(1)) encodem1_inst (
    .d(grayrdptr),.q(grayrdptrm1),.vld(rdinc0),.clk(rdclk),.rst(rdrst));
    
  powlib_grayencodeff #(.W(W),.INIT(0),.EAR(EAR),.EVLD(1)) encode_inst (
    .d(rdptr0),.q(grayrdptr),.vld(rdinc0),.clk(rdclk),.rst(rdrst));
    
  powlib_cntr #(.W(W),.INIT(1),.EAR(EAR),.ELD(0)) cntr_inst (
    .cntr(rdptr0),.adv(rdinc0),.clr(0),.clk(rdclk),.rst(rdrst));
  
endmodule

module powlib_afifo(wrdata,wrvld,wrrdy,rddata,rdvld,rdrdy,wrclk,wrrst,rdclk,rdrst);

`include "powlib_std.vh"

  parameter                  W    = 16;       // Width
  parameter                  D    = 8;        // Depth
  parameter                  EAR  = 0;        // Enable asynchronous reset
  parameter                  EDBG = 0;        // Enable debug statements
  parameter                  ID   = "AFIFO";  // String identifier
  localparam                 WPTR =  powlib_clogb2(D);
  input      wire [W-1:0]    wrdata;
  input      wire            wrvld;
  output     wire            wrrdy;
  output     wire [W-1:0]    rddata;
  output     wire            rdvld;
  input      wire            rdrdy; 
  input      wire            wrclk;
  input      wire            wrrst;
  input      wire            rdclk;
  input      wire            rdrst;
             wire            wrinc;
             wire [WPTR-1:0] wrptr, graywrptr, graywrptr0;
             wire [WPTR-1:0] rdptr, grayrdptrm1, grayrdptrm10;
  
  powlib_afifo_wrcntrl #(.W(WPTR),.EAR(EAR)) wrcntrl_inst (
    .wrptr(wrptr),.graywrptr(graywrptr),.grayrdptrm1(grayrdptrm10),
    .wrvld(wrvld),.wrrdy(wrrdy),.wrinc(wrinc),
    .wrclk(wrclk),.wrrst(wrrst));
    
  powlib_afifo_rdcntrl #(.W(WPTR),.EAR(EAR)) rdcntrl_inst (
    .rdptr(rdptr),.grayrdptrm1(grayrdptrm1),.graywrptr(graywrptr0),
    .rdvld(rdvld),.rdrdy(rdrdy),
    .rdclk(rdclk),.rdrst(rdrst));
    
  powlib_ffsync #(.W(WPTR),.INIT(0),.EAR(EAR)) graywrptr_sync_inst (
    .d(graywrptr),.q(graywrptr0),
    .aclk(wrclk),.bclk(rdclk),.arst(wrrst),.brst(rdrst));
    
  powlib_ffsync #(.W(WPTR),.INIT(powlib_grayencode({WPTR{1'd1}})),.EAR(EAR)) grayrdptrm1_sync_inst (
    .d(grayrdptrm1),.q(grayrdptrm10),
    .aclk(rdclk),.bclk(wrclk),.arst(rdrst),.brst(wrrst));

  powlib_dpram #(.W(W),.D(D),.EDBG(EDBG),.ID({ID,"_DPRAM"})) ram_inst (
    .wridx(wrptr),.wrdata(wrdata),.wrvld(wrinc),
    .rdidx(rdptr),.rddata(rddata),.clk(wrclk));
  
  initial begin
    if ((1<<WPTR)!=D) begin
      $display("ID: %s, D: %d, D is not a power of 2.", ID, D);
      $finish;
    end;
  end
  
endmodule
