`timescale 1ns / 1ps

module powlib_buscross_lane(wrdatas,wraddrs,wrvlds,wrrdys,wrnfs,wrclks,wrrsts,rddata,rdaddr,rdvld,rdrdy,rdclk,rdrst);
  

  parameter                        NFS       = 0;       // Nearly full stages
  parameter                        D         = 8;       // Total depth
  parameter                        S         = 0;       // Pipeline Stages
  parameter                        DD        = 4;       // Default Depth for asynchronous FIFO  
  parameter                        EAR       = 0;       // Enable asynchronous reset  
  parameter                        ID        = "LANE";  // String identifier
  parameter                        EDBG      = 0;       // Enable debug
  parameter                        B_WRS     = 4;
  parameter                        B_AW      = 2;
  parameter                        B_DW      = 4;
  parameter       [B_WRS-1:0]      B_EASYNCS = {1'b0,1'b0,1'b0,1'b0};          // Enable asynchronous FIFO  
  parameter       [B_AW-1:0]       B_BASE    = 0;
  parameter       [B_AW-1:0]       B_SIZE    = 2;
  localparam      [B_AW-1:0]       B_HIGH    = B_BASE+B_SIZE;  

  input      wire [B_WRS-1:0]      wrclks;
  input      wire [B_WRS-1:0]      wrrsts;
  input      wire [B_WRS*B_DW-1:0] wrdatas;
  input      wire [B_WRS*B_AW-1:0] wraddrs;
  input      wire [B_WRS-1:0]      wrvlds;
  output     wire [B_WRS-1:0]      wrrdys; 
  output     wire [B_WRS-1:0]      wrnfs;  

  input      wire                  rdclk;
  input      wire                  rdrst;
  output     wire [B_DW-1:0]       rddata;
  output     wire [B_AW-1:0]       rdaddr;
  output     wire                  rdvld;
  input      wire                  rdrdy;  

             wire [B_WRS-1:0]      conds_s1_0;    
             wire [B_WRS-1:0]      vlds_s2_0; 
             wire                  vld_s2_0;
             wire [B_DW-1:0]       data_s2_0;
             wire [B_AW-1:0]       addr_s2_0; 
             wire [B_DW-1:0]       data_s3_0;
             wire [B_AW-1:0]       addr_s3_0;             
             wire                  vld_s3_0;


             genvar                i;

             assign                vld_s2_0 = |vlds_s2_0;

  for (i=0; i<B_WRS; i=i+1) begin

    wire [B_DW-1:0] data_s0_0;
    wire [B_AW-1:0] addr_s0_0;
    wire            vld_s0_0;
    wire            rdy_s0_0;
    wire            cond_s0_0;
    wire            cond_s0_1;
    wire            cond_s1_0;
    wire            cond_s1_1;
    wire            cond_s1_2;
    wire [B_DW-1:0] data_s1_0;
    wire [B_AW-1:0] addr_s1_0;    
    wire [B_DW-1:0] data_s2_1;
    wire [B_AW-1:0] addr_s2_1;     

    assign          cond_s0_0     = ((addr_s0_0>=B_BASE) && (addr_s0_0 < B_HIGH));
    assign          cond_s0_1     = cond_s0_0 && vld_s0_0;
    assign          conds_s1_0[i] = ((i==0) ? 0 :  conds_s1_0[i-1]) || cond_s1_0;
    assign          cond_s1_1     = ((i==0) ? 1 : !conds_s1_0[i-1]) && conds_s1_0[i];
    assign          cond_s1_2     = cond_s1_1 && !nf_s3_0;
    assign          rdy_s0_0      = vld_s0_0 && !nf_s3_0;
    assign          addr_s2_0     = (vlds_s2_0[i]) ? addr_s2_1 : {B_AW{1'bz}};
    assign          data_s2_0     = (vlds_s2_0[i]) ? data_s2_1 : {B_DW{1'bz}};
    
    powlib_busfifo #(
      .D(D),.S(S),.EASYNC(B_EASYNCS[i]),.DD(DD),.EAR(EAR),
      .ID({ID,"_INFIFO"}),.EDBG(EDBG),
      .B_AW(B_AW),.B_DW(B_DW))
    fifo_in_s0_inst (
      .wrclk(wrclks[i]),.wrrst(wrrsts[i]),
      .rdclk(rdclk),    .rdrst(rdrst),
      .wrdata(wrdatas[i*B_DW+:B_DW]),.wraddr(wraddrs[i*B_AW+:B_AW]),.wrvld(wrvlds[i]),.wrrdy(wrrdys[i]),.wrnf(wrnfs[i]),
      .rddata(data_s0_0),            .rdaddr(addr_s0_0),            .rdvld(vld_s0_0), .rdrdy(rdy_s0_0));

    powlib_flipflop #(         .EAR(EAR)) cond_s0_s1_0_inst (.d(cond_s0_1),.q(cond_s1_0),.clk(rdclk),.rst(rdrst));
    powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s0_s1_0_inst (.d(addr_s0_0),.q(addr_s1_0),.clk(rdclk),.rst(1'b0));
    powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s0_s1_0_inst (.d(data_s0_0),.q(data_s1_0),.clk(rdclk),.rst(1'b0));    

    powlib_flipflop #(         .EAR(EAR))  vld_s1_s2_0_inst (.d(cond_s1_2),.q(vlds_s2_0[i]),.clk(rdclk),.rst(rdrst));
    powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s1_s2_0_inst (.d(addr_s1_0),.q(addr_s2_1),   .clk(rdclk),.rst(1'b0));
    powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s1_s2_0_inst (.d(data_s1_0),.q(data_s2_1),   .clk(rdclk),.rst(1'b0));

  end

  powlib_flipflop #(         .EAR(EAR))  vld_s2_s3_0_inst (.d( vld_s2_0),.q( vld_s3_0),.clk(rdclk),.rst(rdrst));
  powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s2_s3_0_inst (.d(addr_s2_0),.q(addr_s3_0),.clk(rdclk),.rst(1'b0));
  powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s2_s3_0_inst (.d(data_s2_0),.q(data_s3_0),.clk(rdclk),.rst(1'b0));  

  powlib_busfifo #(
    .NFS(3),.D(8),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_OUTFIFO"}),
    .B_AW(B_AW),.B_DW(B_DW)) 
  fifo_s2_out_inst (
    .wrclk(rdclk),.wrrst(rdrst),.rdclk(rdclk),.rdrst(rdrst),
    .wrdata(data_s3_0),.wraddr(addr_s3_0),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0),
    .rddata(rddata),   .rdaddr(rdaddr),   .rdvld(rdvld),   .rdrdy(rdrdy));

endmodule


module powlib_busfifo(wrdata,wraddr,wrvld,wrrdy,wrnf,wrclk,wrrst,
                      rddata,rdaddr,rdvld,rdrdy,     rdclk,rdrst);
  
  parameter                   NFS    = 0;          // Nearly full stages
  parameter                   D      = 8;          // Total depth
  parameter                   S      = 0;          // Pipeline Stages
  parameter                   EASYNC = 0;          // Enable asynchronous FIFO
  parameter                   DD     = 4;          // Default Depth for asynchronous FIFO
  parameter                   EAR    = 0;          // Enable asynchronous reset  
  parameter                   ID     = "BUSFIFO";  // String identifier
  parameter                   EDBG   = 0;          // Enable debug
  parameter                   B_AW   = 2;
  parameter                   B_DW   = 4;
  localparam                  OFF_0  = 0;
  localparam                  OFF_1  = OFF_0+B_DW;
  localparam                  OFF_2  = OFF_1+B_AW;
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
