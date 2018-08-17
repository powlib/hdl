`timescale 1ns / 1ps

module powlib_busfifo(wrdata,wrbe,wraddr,wroper,wrvld,wrrdy,wrnf,wrclk,wrrst,
                      rddata,rdbe,rdaddr,rdoper,rdvld,rdrdy,     rdclk,rdrst);
  
`include "powlib_std.vh"

  parameter                   NFS    = 0;      // Nearly full stages
  parameter                   D      = 8;      // Total depth
  parameter                   S      = 0;      // Pipeline Stages
  parameter                   EASYNC = 0;      // Enable asynchronous FIFO
  parameter                   DD     = 4;      // Default Depth for asynchronous FIFO
  parameter                   EAR    = 0;      // Enable asynchronous reset  
  parameter                   ID     = "BUS";  // String identifier
  parameter                   EDBG   = 0;      // Enable debug
  parameter                   B_BPD  = 4;
  parameter                   B_AW   = 2;
  parameter                   B_OW   = 1;
  localparam                  B_DW   = B_BPD*`POWLIB_BW;
  localparam                  OFF_0  = 0;
  localparam                  OFF_1  = OFF_0+B_DW;
  localparam                  OFF_2  = OFF_1+B_BPD;
  localparam                  OFF_3  = OFF_2+B_AW;
  localparam                  OFF_4  = OFF_3+B_OW;  
  localparam                  B_WW   = OFF_4;

  input      wire             wrclk;
  input      wire             wrrst;
  input      wire             rdclk;
  input      wire             rdrst;
     
  input      wire [B_DW-1:0]  wrdata;
  input      wire [B_BPD-1:0] wrbe;
  input      wire [B_AW-1:0]  wraddr;
  input      wire [B_OW-1:0]  wroper;
  input      wire             wrvld;
  output     wire             wrrdy;
  output     wire             wrnf;
    
  output     wire [B_DW-1:0]  rddata;
  output     wire [B_BPD-1:0] rdbe;
  output     wire [B_AW-1:0]  rdaddr;
  output     wire [B_OW-1:0]  rdoper;
  output     wire             rdvld;
  input      wire             rdrdy;

             wire [B_WW-1:0]  wrword;  
             wire [B_WW-1:0]  rdword;

  assign                      wrword[OFF_0 +: B_DW]  = wrdata;
  assign                      wrword[OFF_1 +: B_BPD] = wrbe;
  assign                      wrword[OFF_2 +: B_AW]  = wraddr;
  assign                      wrword[OFF_3 +: B_OW]  = wroper;
                     
  assign                      rddata                 = rdword[OFF_0 +: B_DW];
  assign                      rdbe                   = rdword[OFF_1 +: B_BPD];
  assign                      rdaddr                 = rdword[OFF_2 +: B_AW];
  assign                      rdoper                 = rdword[OFF_3 +: B_OW];

  powlib_swissfifo #(
    .W(B_WW),.NFS(NFS),.D(D),.S(S),.EASYNC(EASYNC),.DD(DD),.EAR(EAR),
    .ID({ID,"_SWISS"}),.EDBG(EDBG))
  swissfifo_inst (
    .wrdata(wrword),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),.wrclk(wrclk),.wrrst(wrrst),
    .rddata(rdword),.rdvld(rdvld),.rdrdy(rdrdy),            .rdclk(rdclk),.rdrst(rdrst));

endmodule