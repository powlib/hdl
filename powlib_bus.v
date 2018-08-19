`timescale 1ns / 1ps



module powlib_buscross_lane(wrdatas,wraddrs,wrvlds,wrrdys,rddata,rdaddr,rdvld,rdrdy,clk,rst);

  parameter                        EAR    = 0;       // Enable asynchronous reset  
  parameter                        ID     = "LANE";  // String identifier
  parameter                        EDBG   = 0;       // Enable debug
  parameter                        B_WRS  = 4;
  parameter                        B_AW   = 2;
  parameter                        B_DW   = 4;
  parameter       [B_AW-1:0]       B_BASE = 0;
  parameter       [B_AW-1:0]       B_SIZE = 2;
  localparam      [B_AW-1:0]       B_HIGH = B_BASE+B_SIZE;
  
  input      wire                  clk;
  input      wire                  rst;
  input      wire [B_WRS*B_DW-1:0] wrdatas;
  input      wire [B_WRS*B_AW-1:0] wraddrs;
  input      wire [B_WRS-1:0]      wrvlds;
  output     wire [B_WRS-1:0]      wrrdys;

  output     wire [B_DW-1:0]       rddata;
  output     wire [B_AW-1:0]       rdaddr;
  output     wire                  rdvld;
  input      wire                  rdrdy;

             wire [B_DW-1:0]       datas_s0_0 [0:B_WRS-1];
             wire [B_AW-1:0]       addrs_s0_0 [0:B_WRS-1];
             wire [B_WRS-1:0]      cond_s0_0;
             wire [B_WRS-1:0]      cond_s0_1;
             wire [B_WRS-1:0]      cond_s0_2;
             wire [B_WRS-1:0]      cond_s0_3;

             wire [B_DW-1:0]       datas_s1_0 [0:B_WRS-1];
             wire [B_AW-1:0]       addrs_s1_0 [0:B_WRS-1];  
             wire [B_DW-1:0]       data_s1_0;
             wire [B_AW-1:0]       addr_s1_0;
             wire [B_WRS-1:0]      vlds_s1_0;
             wire                  vld_s1_0;

             wire [B_DW-1:0]       data_s2_0;
             wire [B_AW-1:0]       addr_s2_0;
             wire                  vld_s2_0;
             wire                  rdy_s2_0;
             wire                  nf_s2_0;
  
  genvar i;
  
  assign vld_s1_0 = |vlds_s1_0;
  
  for (i=0; i<B_WRS; i=i+1) begin

    assign datas_s0_0[i] = wrdatas[i*B_DW+:B_DW];
    assign addrs_s0_0[i] = wraddrs[i*B_AW+:B_AW];
    assign cond_s0_0[i]  = ((addrs_s0_0[i]>=B_BASE) && (addrs_s0_0[i] < B_HIGH));
    assign cond_s0_1[i]  = wrvlds[i] && cond_s0_0[i];
    assign cond_s0_2[i]  = ((i==0) ? 1 : !cond_s0_2[i-1]) && cond_s0_1[i];
    assign cond_s0_3[i]  = cond_s0_2[i] && !nf_s2_0;
    assign wrrdys[i]     = cond_s0_3[i];
    assign addr_s1_0     = (vlds_s1_0[i]) ? addrs_s1_0[i] : {B_AW{1'bz}};
    assign data_s1_0     = (vlds_s1_0[i]) ? datas_s1_0[i] : {B_DW{1'bz}};
    
    
    powlib_flipflop #(         .EAR(EAR))  vld_s0_s1_0_inst (.d( cond_s0_3[i]),.q( vlds_s1_0[i]),.clk(clk),.rst(rst));
    powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s0_s1_0_inst (.d(addrs_s0_0[i]),.q(addrs_s1_0[i]),.clk(clk),.rst(0));
    powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s0_s1_0_inst (.d(datas_s0_0[i]),.q(datas_s1_0[i]),.clk(clk),.rst(0));

  end

  powlib_flipflop #(         .EAR(EAR))  vld_s1_s2_0_inst (.d( vld_s1_0),.q( vld_s2_0),.clk(clk),.rst(rst));
  powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s1_s2_0_inst (.d(addr_s1_0),.q(addr_s2_0),.clk(clk),.rst(0));
  powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s1_s2_0_inst (.d(data_s1_0),.q(data_s2_0),.clk(clk),.rst(0));
  
  powlib_busfifo #(
    .NFS(2),.D(8),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_BUSFIFO"}),
    .B_AW(B_AW),.B_DW(B_DW)) 
  ofifo_inst (
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst),
    .wrdata(data_s2_0),.wraddr(addr_s2_0),.wrvld(vld_s2_0),.wrrdy(rdy_s2_0),.wrnf(nf_s2_0),
    .rddata(rddata),.rdaddr(rdaddr),.rdvld(rdvld),.rdrdy(rdrdy));

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
