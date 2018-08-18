`timescale 1ns / 1ps

/*

module powlib_buscross_lane();

  parameter B_WRS = 4;
  parameter B_AW = 2;
  parameter B_DW = 4;
  
  parameter [B_AW-1:0] B_BASE = 0;
  parameter [B_AW-1:0] B_SIZE = 2;
  localparam [B_AW-1:0] B_HIGH = B_BASE+B_SIZE;
  
  input wire clk;
  input wire rst;
  input wire [B_WRS*B_DW-1:0] wrdatas;
  input wire [B_WRS*B_AW-1:0] wraddrs;
  input wire [B_WRS-1:0] wrvlds;
  output wire [B_WRS-1:0] wrrdys;
  
  wire [B_DW-1:0] wrdata [0:B_WRS-1];
  wire [B_AW-1:0] wraddr [0:B_WRS-1];
  wire [B_WRS-1:0] cond0_flgs;
  wire [B_WRS-1:0] cond1_flgs;
  
  genvar i;
  
  assign vld_s1_0 = |vlds_s1_0;
  
  for (i=0; i<B_WRS; i=i+1) begin
    assign wrdata[i]     = wrdatas[i*B_DW+:B_DW];
    assign wraddr[i]     = wraddrs[i*B_AW+:B_AW];
    assign cond0_s0_0[i] = ((wraddr[i]>=B_BASE) && (wraddr[i] < B_HIGH));
    assign cond1_s0_0[i] = wrvlds[i] && cond0_s0_0[i];
    assign cond2_s0_0[i] = ((i==0) ? 1 : !cond2_s0_0[i-1]) && cond1_s0_0[i];
    assign cond3_s0_0[i] = cond2_s0_0[i] && !nf_s2_0;
    assign wrrdys[i]     = cond3_s0_0[i];
    assign addr_s1_1     = ( vlds_s1_0[i] ) ? addr_s1_0[i] : {B_AW{1'bz}};
    assign data_s1_1     = ( vlds_s1_0[i] ) ? data_s1_0[i] : {B_DW{1'bz}};
    
    
    powlib_flipflop #(.EAR(EAR)) vld_s0_s1_0_inst (.d(cond3_s0_0[i]),.q(vlds_s1_0[i]),.clk(clk),.rst(rst));
    powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s0_s1_0_inst (.d(wraddr[i]),.q(addr_s1_0[i]),.clk(clk),.rst(0));
    powlib_flipflop #(.W(B_AW),.EAR(EAR)) data_s0_s1_0_inst (.d(wrdata[i]),.q(data_s1_0[i]),.clk(clk),.rst(0));
  end
  


endmodule
*/

module powlib_busfifo(wrdata,wraddr,wrvld,wrrdy,wrnf,wrclk,wrrst,
                      rddata,rdaddr,rdvld,rdrdy,     rdclk,rdrst);
  
`include "powlib_std.vh"

  parameter                   NFS    = 0;      // Nearly full stages
  parameter                   D      = 8;      // Total depth
  parameter                   S      = 0;      // Pipeline Stages
  parameter                   EASYNC = 0;      // Enable asynchronous FIFO
  parameter                   DD     = 4;      // Default Depth for asynchronous FIFO
  parameter                   EAR    = 0;      // Enable asynchronous reset  
  parameter                   ID     = "BUS";  // String identifier
  parameter                   EDBG   = 0;      // Enable debug
  parameter                   B_AW   = 2;
  parameter                   B_DW   = 4;
  localparam                  OFF_0  = 0;
  localparam                  OFF_1  = OFF_0+B_AW;
  localparam                  OFF_2  = OFF_1+B_DW;
  localparam                  B_WW   = OFF_2;

  input      wire             wrclk;
  input      wire             wrrst;
  input      wire             rdclk;
  input      wire             rdrst;     
  input      wire [B_DW-1:0]  wrdata;
  input      wire [B_AW-1:0]  wraddr;
  input      wire             wrvld;
  output     wire             wrrdy;
  output     wire             wrnf;    
  output     wire [B_DW-1:0]  rddata;
  output     wire [B_AW-1:0]  rdaddr;
  output     wire             rdvld;
  input      wire             rdrdy;
             wire [B_WW-1:0]  wrword;  
             wire [B_WW-1:0]  rdword;

  assign                      wrword[OFF_0 +: B_DW]  = wrdata;
  assign                      wrword[OFF_1 +: B_AW]  = wraddr;                     
  assign                      rddata                 = rdword[OFF_0 +: B_DW];
  assign                      rdaddr                 = rdword[OFF_1 +: B_AW];

  powlib_swissfifo #(
    .W(B_WW),.NFS(NFS),.D(D),.S(S),.EASYNC(EASYNC),.DD(DD),.EAR(EAR),
    .ID({ID,"_SWISS"}),.EDBG(EDBG))
  swissfifo_inst (
    .wrdata(wrword),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),.wrclk(wrclk),.wrrst(wrrst),
    .rddata(rdword),.rdvld(rdvld),.rdrdy(rdrdy),            .rdclk(rdclk),.rdrst(rdrst));

endmodule
