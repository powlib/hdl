`timescale 1ns / 1ps

module powlib_ipunpackintr0(wrdata,rddata,rdbe,rdop);

`include "powlib_std.vh"
`include "powlib_ip.vh"

  parameter                   B_BPD   = 4;
  localparam                  B_DW    = `POWLIB_BW*B_BPD;
  localparam                  B_BEW   = B_BPD;
  localparam                  B_OPW   = `POWLIB_OPW;
  localparam                  OFF_0   = 0;
  localparam                  OFF_1   = OFF_0+B_DW;
  localparam                  OFF_2   = OFF_1+B_BEW;
  localparam                  OFF_3   = OFF_2+B_OPW;
  localparam                  B_WW    = OFF_3;

  input      wire [B_WW-1:0]  wrdata;
  output     wire [B_DW-1:0]  rddata;
  output     wire [B_BEW-1:0] rdbe;
  output     wire [B_OPW-1:0] rdop;

  assign                      rddata = wrdata[OFF_0+:B_DW];
  assign                      rdbe   = wrdata[OFF_1+:B_BEW];
  assign                      rdop   = wrdata[OFF_2+:B_OPW];
  
endmodule

module powlib_ippackintr0(rddata,wrdata,wrbe,wrop);

`include "powlib_std.vh"
`include "powlib_ip.vh"

  parameter                   B_BPD                 = 4;
  localparam                  B_DW                  = `POWLIB_BW*B_BPD;
  localparam                  B_BEW                 = B_BPD;
  localparam                  B_OPW                 = `POWLIB_OPW;
  localparam                  OFF_0                 = 0;
  localparam                  OFF_1                 = OFF_0+B_DW;
  localparam                  OFF_2                 = OFF_1+B_BEW;
  localparam                  OFF_3                 = OFF_2+B_OPW;
  localparam                  B_WW                  = OFF_3;
 
  output     wire [B_WW-1:0]  rddata;
  input      wire [B_DW-1:0]  wrdata;
  input      wire [B_BEW-1:0] wrbe;  
  input      wire [B_OPW-1:0] wrop;
  assign                      rddata[OFF_0+:B_DW]  = wrdata;
  assign                      rddata[OFF_1+:B_BEW] = wrbe;
  assign                      rddata[OFF_2+:B_OPW] = wrop;

endmodule

module powlib_ipmaxi(wraddr,wrdata,wrvld,wrrdy,wrnf,rdaddr,rddata,rdvld,rdrdy,
                     awaddr,awlen,awsize,awburst,awvalid,awready,
                     wdata,wstrb,wlast,wvalid,wready,
                     bresp,bvalid,bready,
                     araddr,arlen,arsize,arburst,arvalid,arready,
                     rdata,rresp,rlast,rvalid,rready,
                     clk,rst);
                     
`include "powlib_ip.vh"        

  parameter                     ID       = "IPMAXI";  // String identifier  
  parameter                     EAR      = 0;         // Enable asynchronous reset  
  parameter                     EDBG     = 0;
  parameter                     IN_NFS   = 0;
  parameter                     IN_D     = 8;
  parameter                     IN_S     = 0;
  parameter                     B_SIZE   = 8'd15;
  parameter                     B_BPD    = 4;
  parameter                     B_AW     = `POWLIB_BW*B_BPD;
  localparam                    B_DW     = `POWLIB_BW*B_BPD;
  localparam                    B_BEW    = B_BPD;
  localparam                    B_OPW    = `POWLIB_OPW;
  localparam                    B_WW     = B_OPW+B_BEW+B_DW;   
                     
  /* GLOBAL SYNCHRONIZATION INTERFACE. */
  input  wire                   clk;
  input  wire                   rst;
      
  /* POWLIB INTERFACE */  
  /* Writing */
  input  wire [B_AW-1:0]        wraddr;
  input  wire [B_WW-1:0]        wrdata;
  input  wire                   wrvld;
  output wire                   wrrdy;
  output wire                   wrnf;      
  // Reading
  output wire [B_AW-1:0]        rdaddr;
  output wire [B_WW-1:0]        rddata;
  output wire                   rdvld;
  input  wire                   rdrdy;                     
  
  /* MASTER AXI INTERFACE. */
  // Address Writing
  output wire [B_AW-1:0]        awaddr;
  output wire [`AXI_LENW-1:0]   awlen;
  output wire [`AXI_SIZEW-1:0]  awsize;
  output wire [`AXI_BURSTW-1:0] awburst;
  output wire                   awvalid;
  input  wire                   awready;
  // Writing Data 
  output wire [B_DW-1:0]        wdata;
  output wire [B_BEW-1:0]       wstrb;
  output wire                   wlast;
  output wire                   wvalid;
  input  wire                   wready;
  // Writing Response
  input  wire [`AXI_RESPW-1:0]  bresp;
  input  wire                   bvalid;
  output wire                   bready;
  // Address Reading 
  output wire [B_AW-1:0]        araddr;
  output wire [`AXI_LENW-1:0]   arlen;
  output wire [`AXI_SIZEW-1:0]  arsize;
  output wire [`AXI_BURSTW-1:0] arburst;
  output wire                   arvalid;
  input  wire                   arready;
  // Reading Data
  input  wire [B_DW-1:0]        rdata;
  input  wire [`AXI_RESPW-1:0]  rresp;
  input  wire                   rlast;
  input  wire                   rvalid;
  output wire                   rready;  
  


endmodule

module powlib_ipmaxi_rd(wraddr,wrdata,wrvld,wrrdy,wrnf,
                        rdaddr,rddata,rdvld,rdrdy,
                        araddr,arlen,arsize,arburst,arvalid,arready,
                        rdata,rresp,rlast,rvalid,rready,
                        clk,rst);
                        
`include "powlib_std.vh"
`include "powlib_ip.vh" 

  input  wire                   clk;
  input  wire                   rst;
  // PLB Writing 
  input  wire [B_AW-1:0]        wraddr;
  input  wire [B_DW-1:0]        wrdata;
  input  wire                   wrvld;
  output wire                   wrrdy;
  output wire                   wrnf;  
  // PBL Reading
  output wire [B_AW-1:0]        rdaddr;
  output wire [B_DW-1:0]        rddata;
  output wire [`AXI_RESPW-1:0]  rdresp;
  output wire                   rdvld;
  input  wire                   rdrdy;
  // AXI Address Reading 
  output wire [B_AW-1:0]        araddr;
  output wire [`AXI_LENW-1:0]   arlen;
  output wire [`AXI_SIZEW-1:0]  arsize;
  output wire [`AXI_BURSTW-1:0] arburst;
  output wire                   arvalid;
  input  wire                   arready;
  // AXI Reading Data
  input  wire [B_DW-1:0]        rdata;
  input  wire [`AXI_RESPW-1:0]  rresp;
  input  wire                   rlast;
  input  wire                   rvalid;
  output wire                   rready;   
  
  // Combinational Logic
  assign arsize                                = CL2B_BPD;
  assign arburst                               = `AXI_INCRBT;
  
  assign data_in_0[0+:B_DW]                    = wrdata;
  assign data_in_0[(0+B_DW)+:B_AW]             = wraddr;
  assign data_s0_1                             = data_s0_0[0+:B_DW];
  assign addr_s0_0                             = data_s0_0[(0+B_DW)+:B_AW];
  
  assign data_rs1_0[0+:B_DW]                   = data_rs1_1;
  assign data_rs1_0[(0+B_DW)+:`AXI_RESPW]      = resp_rs1_0;
  assign data_rs1_0[(0+B_DW+`AXI_RESPW)+:B_AW] = addr_rs1_0;
  assign rddata                                = data_out_0[0+:B_DW];
  assign rdresp                                = data_out_0[(0+B_DW)+:`AXI_RESPW];
  assign rdaddr                                = data_out_0[(0+B_DW+`AXI_RESPW)+:B_AW];
  
  assign data_ars3_0[0+:B_AW]                  = addr_ars3_0;
  assign data_ars3_0[(0+B_AW)+:`AXI_LENW]      = len_ars3_0;
  assign araddr                                = data_arout_0[0+:B_AW];
  assign arlen                                 = data_arout_0[(0+B_AW)+:`AXI_LENW];
  
  assign data_rin_0[0+:B_DW]                   = rdata;
  assign data_rin_0[(0+B_DW)+:`AXI_RESPW]      = rresp;
  assign data_rin_0[(0+B_DW+`AXI_RESPW)+:1]    = rlast;
  assign data_rs0_1                            = data_rs0_0[0+:B_DW];
  assign resp_rs0_0                            = data_rs0_0[(0+B_DW)+:`AXI_RESPW];
  assign last_rs0_0                            = data_rs0_0[(0+B_DW+`AXI_RESPW)+:1];
  
  assign data_s3_0[0+:B_AW]                    = raddr_s3_0;
  assign data_s3_0[(0+B_AW)+:1]                = explast_s3_0;
  assign raddr_rs0_0                           = data_rs0_2[0+:B_AW];
  assign explast_rs0_0                         = data_rs0_2[(0+B_AW)+:1];
  
  assign rdy_s0_0                              = ?;
  assign vld_rs1_0                             = ?;
  assign vld_ars3_0                            = ?;
  assign vld_s3_1                              = ?;
  assign rdy_rs0_0                             = ?;
  assign rdy_rs0_1                             = ?;  
  
  // Counters.
  
  // FIFOs
  powlib_swissfifo #(.W(B_AW+B_DW),.NFS(IN_NFS),.D(IN_D),.S(IN_S),
    .ID({ID,"_INFIFO"}),.EDBG(EDBG)) 
  fifo_in_s0_0_inst (
    .wrdata(data_in_0),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),
    .rddata(data_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst)); 

  powlib_swissfifo #(.W(B_AW+`AXI_RESPW+B_DW),.NFS(1),.D(8),
    .ID({ID,"_OUTFIFO"}),.EDBG(EDBG)) 
  fifo_s3_out_0_inst (
    .wrdata(data_rs1_0),.wrvld(vld_rs1_0),.wrrdy(rdy_rs1_0),.wrnf(nf_rs1_0),
    .rddata(data_out_0),.rdvld(rdvld),.rdrdy(rdrdy),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst)); 

  powlib_swissfifo #(.W(`AXI_LENW+B_AW),.NFS(3),.D(8),
    .ID({ID,"_ARFIFO"}),.EDBG(EDBG))
  fifo_ars3_out_inst (
    .wrdata(data_ars3_0),.wrvld(vld_ars3_0),.wrrdy(rdy_ars3_0),.wrnf(nf_ars3_0),
    .rddata(data_arout_0),.rdvld(arvalid),.rdrdy(arready),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));    
                        
  powlib_swissfifo #(.W(1+`AXI_RESPW+B_DW),.NFS(0),.D(8),
    .ID({ID,"_RFIFO"}),.EDBG(EDBG))
  fifo_rin_rs0_inst (
    .wrdata(data_rin_0),.wrvld(rdvalid),.wrrdy(rdready),
    .rddata(data_rs0_0),.rdvld(vld_rs0_0),.rdrdy(rdy_rs0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));  

  powlib_swissfifo #(.W(1+B_AW),.NFS(3),.D(MAX_BURST+8),
    .ID({ID,"_RAFIFO"}),.EDBG(EDBG))
  fifo_s3_rs0_inst (
    .wrdata(data_s3_0),.wrvld(vld_s3_1),.wrrdy(rdy_s3_1),.wrnf(nf_s3_1),
    .rddata(data_rs0_2),.rdvld(vld_rs0_1),.rdrdy(rdy_rs0_1),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));      
                                                
endmodule                        

module powlib_ipmaxi_wr(wraddr,wrdata,wrbe,wrvld,wrrdy,wrnf,
                        awaddr,awlen,awsize,awburst,awvalid,awready,
                        wdata,wstrb,wlast,wvalid,wready,
                        clk,rst);
      
`include "powlib_std.vh"
`include "powlib_ip.vh"   

  parameter                     MAX_BURST    = 256;
  parameter                     ID           = "WR";  // String identifier  
  parameter                     EAR          = 0;         // Enable asynchronous reset  
  parameter                     EDBG         = 0;
  parameter                     IN_NFS       = 0;
  parameter                     IN_D         = 8;
  parameter                     IN_S         = 0;  
  parameter                     B_BPD        = 4;
  parameter                     B_AW         = `POWLIB_BW*B_BPD;
  localparam                    B_DW         = `POWLIB_BW*B_BPD;
  localparam                    B_BEW        = B_BPD;  
  localparam                    CL2MAX_BURST = powlib_clogb2(MAX_BURST);
  localparam                    CL2B_BPD     = powlib_clogb2(B_BPD);
      
  input  wire                   clk;
  input  wire                   rst;
  // PLB Writing 
  input  wire [B_AW-1:0]        wraddr;
  input  wire [B_DW-1:0]        wrdata;
  input  wire [B_BEW-1:0]       wrbe;
  input  wire                   wrvld;
  output wire                   wrrdy;
  output wire                   wrnf;        
  // AXI Address Writing
  output wire [B_AW-1:0]        awaddr;
  output wire [`AXI_LENW-1:0]   awlen;
  output wire [`AXI_SIZEW-1:0]  awsize;
  output wire [`AXI_BURSTW-1:0] awburst;
  output wire                   awvalid;
  input  wire                   awready;
  // AXI Writing Data 
  output wire [B_DW-1:0]        wdata;
  output wire [B_BEW-1:0]       wstrb;
  output wire                   wlast;
  output wire                   wvalid;
  input  wire                   wready;       

         wire [B_BEW+B_AW+B_DW-1:0]  data_in_0, data_s0_0;
         wire [B_DW-1:0]             data_s0_1, data_s1_0, data_s2_0, data_s3_0, data_ws3_0;
         wire [B_AW-1:0]             addr_s0_0, addr_s1_0, addr_s2_0, base_s3_0, addr_aws3_0;
         wire [B_BEW-1:0]            be_s0_0, be_s1_0, be_s2_0, be_s3_0, strb_ws3_0;
         wire [(`AXI_LENW+B_AW)-1:0] data_aws3_0, data_awout_0;
         wire [`AXI_LENW-1:0]        len_aws3_0;
         wire [(1+B_BEW+B_DW)-1:0]   data_ws3_1, data_wout_0;
         wire [CL2MAX_BURST-1:0]     cntr_s2_0, cntr_s3_0;
         wire                        vld_s0_0, vld_s0_1, vld_s2_0, vld_s3_0, 
                                     rdy_s0_0, adv_s1_0, clr_s1_0, basevld_s2_0, 
                                     addrfin_s2_0, addrfin_s3_0, vld_aws3_0, rdy_aws3_0, nf_aws3_0, 
                                     vld_ws3_0, rdy_ws3_0, nf_ws3_0, last_ws3_0;
     
  // Combinational Logic   
  assign awsize                           = CL2B_BPD;
  assign awburst                          = `AXI_INCRBT;
  
  assign data_in_0[0+:B_DW]               = wrdata;
  assign data_in_0[(0+B_DW)+:B_AW]        = wraddr;
  assign data_in_0[(0+B_DW+B_AW)+:B_BEW]  = wrbe;
  assign data_s0_1                        = data_s0_0[0+:B_DW];
  assign addr_s0_0                        = data_s0_0[(0+B_DW)+:B_AW];
  assign be_s0_0                          = data_s0_0[(0+B_DW+B_AW)+:B_BEW];
  
  assign data_aws3_0[0+:B_AW]             = addr_aws3_0;
  assign data_aws3_0[(0+B_AW)+:`AXI_LENW] = len_aws3_0;
  assign awaddr                           = data_awout_0[0+:B_AW];
  assign awlen                            = data_awout_0[(0+B_AW)+:`AXI_LENW]; 
  
  assign data_ws3_1[0+:B_DW]              = data_ws3_0;
  assign data_ws3_1[(0+B_DW)+:B_BEW]      = strb_ws3_0;
  assign data_ws3_1[(0+B_DW+B_BEW)+:1]    = last_ws3_0;
  assign wdata                            = data_wout_0[0+:B_DW];
  assign wstrb                            = data_wout_0[(0+B_DW)+:B_BEW];
  assign wlast                            = data_wout_0[(0+B_DW+B_BEW)+:1];
  
  assign rdy_s0_0                         = !nf_aws3_0 && !nf_ws3_0;  
  assign vld_s0_1                         = vld_s0_0 && rdy_s0_0;
  assign adv_s1_0                         = !clr_s1_0 && vld_s2_0;
  assign clr_s1_0                         = addrfin_s2_0 && vld_s2_0;
  assign addrfin_s2_0                     = (cntr_s2_0==(MAX_BURST-1)) || ((addr_s2_0+B_BEW)!=addr_s1_0) || (!vld_s1_0);
  assign basevld_s2_0                     = (cntr_s2_0==0) && vld_s2_0;
  assign vld_aws3_0                       = addrfin_s3_0 && vld_s3_0;
  assign addr_aws3_0                      = base_s3_0;
  assign len_aws3_0                       = {{(`AXI_LENW-CL2MAX_BURST){1'd0}},cntr_s3_0};
  assign vld_ws3_0                        = vld_s3_0;
  assign data_ws3_0                       = data_s3_0;
  assign strb_ws3_0                       = be_s3_0;
  assign last_ws3_0                       = addrfin_s3_0;
  
  // Pipeline.
  powlib_flipflop #(.W(B_DW),         .EAR(EAR))    data_s0_s1_0_inst (.d(data_s0_1),   .q(data_s1_0),   .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),         .EAR(EAR))    data_s1_s2_0_inst (.d(data_s1_0),   .q(data_s2_0),   .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),         .EAR(EAR))    data_s2_s3_0_inst (.d(data_s2_0),   .q(data_s3_0),   .clk(clk),.rst(1'd0));  
  powlib_flipflop #(.W(B_BEW),        .EAR(EAR))      be_s0_s1_0_inst (.d(be_s0_0),     .q(be_s1_0),     .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_BEW),        .EAR(EAR))      be_s1_s2_0_inst (.d(be_s1_0),     .q(be_s2_0),     .clk(clk),.rst(1'd0));  
  powlib_flipflop #(.W(B_BEW),        .EAR(EAR))      be_s2_s3_0_inst (.d(be_s2_0),     .q(be_s3_0),     .clk(clk),.rst(1'd0));  
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))    addr_s0_s1_0_inst (.d(addr_s0_0),   .q(addr_s1_0),   .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))    addr_s1_s2_0_inst (.d(addr_s1_0),   .q(addr_s2_0),   .clk(clk),.rst(1'd0));  
  powlib_flipflop #(.W(1),            .EAR(EAR))     vld_s0_s1_0_inst (.d(vld_s0_1),    .q(vld_s1_0),    .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),            .EAR(EAR))     vld_s1_s2_0_inst (.d(vld_s1_0),    .q(vld_s2_0),    .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),            .EAR(EAR))     vld_s2_s3_0_inst (.d(vld_s2_0),    .q(vld_s3_0),    .clk(clk),.rst(rst));  
  powlib_flipflop #(.W(B_AW),.EVLD(1),.EAR(EAR))    base_s2_s3_0_inst (.d(addr_s2_0),   .q(base_s3_0),   .clk(clk),.rst(1'd0),.vld(basevld_s2_0));  
  powlib_flipflop #(.W(CL2MAX_BURST), .EAR(EAR))    cntr_s2_s3_0_inst (.d(cntr_s2_0),   .q(cntr_s3_0),   .clk(clk),.rst(1'd0));  
  powlib_flipflop #(.W(1),            .EAR(EAR)) addrfin_s2_s3_0_inst (.d(addrfin_s2_0),.q(addrfin_s3_0),.clk(clk),.rst(rst));
  
  // Counters
  powlib_cntr #(.W(CL2MAX_BURST),.EAR(EAR),.ELD(0)) cntr_s1_s2_0_inst (
    .cntr(cntr_s2_0),.adv(adv_s1_0),.clr(clr_s1_0),
    .clk(clk),.rst(rst));

  // FIFOs
  powlib_swissfifo #(.W(B_BEW+B_AW+B_DW),.NFS(IN_NFS),.D(IN_D),.S(IN_S),
    .ID({ID,"_INFIFO"}),.EDBG(EDBG)) 
  fifo_in_s0_0_inst (
    .wrdata(data_in_0),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),
    .rddata(data_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(.W(`AXI_LENW+B_AW),.NFS(3),.D(8),
    .ID({ID,"_AWFIFO"}),.EDBG(EDBG))
  fifo_aws3_out_inst (
    .wrdata(data_aws3_0),.wrvld(vld_aws3_0),.wrrdy(rdy_aws3_0),.wrnf(nf_aws3_0),
    .rddata(data_awout_0),.rdvld(awvalid),.rdrdy(awready),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(.W(1+B_BEW+B_DW),.NFS(3),.D(MAX_BURST+8),
    .ID({ID,"_WFIFO"}),.EDBG(EDBG))
  fifo_ws3_out_inst (
    .wrdata(data_ws3_1),.wrvld(vld_ws3_0),.wrrdy(rdy_ws3_0),.wrnf(nf_ws3_0),
    .rddata(data_wout_0),.rdvld(wvalid),.rdrdy(wready),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));  
  
endmodule                        

module powlib_ipram(wraddr,wrdata,wrvld,wrrdy,wrnf,rdaddr,rddata,rdvld,rdrdy,clk,rst);

`include "powlib_std.vh"
`include "powlib_ip.vh"
  
  parameter                  ID       = "IPRAM";  // String identifier  
  parameter                  EAR      = 0;        // Enable asynchronous reset  
  parameter                  EDBG     = 0;
  parameter                  IN_NFS   = 0;
  parameter                  IN_D     = 8;
  parameter                  IN_S     = 0;
  parameter                  B_SIZE   = 8'd15;
  parameter                  B_BPD    = 4;
  parameter                  B_AW     = `POWLIB_BW*B_BPD;
  localparam                 B_DW     = `POWLIB_BW*B_BPD;
  localparam                 B_BEW    = B_BPD;
  localparam                 B_OPW    = `POWLIB_OPW;
  localparam                 B_WW     = B_OPW+B_BEW+B_DW;
  localparam                 RAM_D    = (B_SIZE+1)/B_BPD;
  localparam                 RAM_WIDX = powlib_clogb2(RAM_D);
  localparam                 RAM_LB   = powlib_clogb2(B_BPD);

  input  wire                clk;
  input  wire                rst;
      
  input  wire [B_AW-1:0]     wraddr;
  input  wire [B_WW-1:0]     wrdata;
  input  wire                wrvld;
  output wire                wrrdy;
  output wire                wrnf;
      
  output wire [B_AW-1:0]     rdaddr;
  output wire [B_WW-1:0]     rddata;
  output wire                rdvld;
  input  wire                rdrdy;
      
         wire [B_DW-1:0]     wrdata_s0_0;
         wire [B_DW-1:0]     rddata_s0_0;
         wire [B_DW-1:0]     wrbe_s0_0;
         wire [RAM_WIDX-1:0] wridx_s0_0;
         wire [RAM_WIDX-1:0] rdidx_s0_0;
         
         wire [B_WW-1:0]     data_in_0;
         wire [B_AW-1:0]     addr_in_0;
         wire                vld_in_0;    
         wire                vld_in_1;    
         wire                rdy_in_0;    
             
         wire [B_AW-1:0]     addr_s0_0;
         wire [B_WW-1:0]     data_s0_0;
         wire [B_DW-1:0]     data_s0_1;
         wire [B_DW-1:0]     data_s0_2;
         wire [B_BEW-1:0]    be_s0_0;
         wire [B_OPW-1:0]    op_s0_0;
         wire                vld_s0_0;
         wire                vld_s0_1;
         
         wire [B_AW-1:0]     addr_s1_0;
         wire [B_DW-1:0]     data_s1_0;
         wire                vld_s1_0;
         
         wire [B_AW-1:0]     addr_s2_0;
         wire [B_DW-1:0]     data_s2_0;
         wire [B_WW-1:0]     data_s2_1;
         wire                nf_s2_0;
         wire                vld_s2_0;
         wire                rdy_s2_0;

         genvar              i;

  // DPRAM instantiation.
  powlib_dpram         #(.W(B_DW),.D(RAM_D),.EWBE(1),.EDBG(EDBG),.ID({ID,"_DPRAM"})) ram_inst (
    .wridx(wridx_s0_0),.wrdata(wrdata_s0_0),.wrvld(1'd0),.wrbe(wrbe_s0_0),
    .rdidx(rdidx_s0_0),.rddata(rddata_s0_0),.clk(clk));
  
  // FIFO the input data.
  powlib_busfifo #(.NFS(IN_NFS),.D(IN_D),.S(IN_S),.EAR(EAR),.ID({ID,"_INFIFO"}),.EDBG(EDBG),.B_AW(B_AW),.B_DW(B_WW)) infifo_inst (
    .wrdata(wrdata),.wraddr(wraddr),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),.wrclk(clk),.wrrst(rst),
    .rddata(data_in_0),.rdaddr(addr_in_0),.rdvld(vld_in_0),.rdrdy(rdy_in_0),.rdclk(clk),.rdrst(rst));
    
  // Stage the FIFOed data. Unpack the data word.
  assign rdy_in_0 = !nf_s2_0;
  assign vld_in_1 = vld_in_0 && rdy_in_0;
  powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_in_s0_inst (.d(addr_in_0),.q(addr_s0_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_WW),.EAR(EAR)) data_in_s0_inst (.d(data_in_0),.q(data_s0_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),   .EAR(EAR)) vld_in_s0_inst  (.d(vld_in_1), .q(vld_s0_0), .clk(clk),.rst(rst));
  powlib_ipunpackintr0 #(.B_BPD(B_BPD)) unpack_s0_inst  (.wrdata(data_s0_0),.rddata(data_s0_1),.rdbe(be_s0_0),.rdop(op_s0_0));
  
  // Set the write bit enables for the DPRAM. Determine if write operation.
  assign wridx_s0_0  = addr_s0_0[RAM_LB+:RAM_WIDX];
  assign wrdata_s0_0 = data_s0_1;
  for (i=0; i<B_BEW; i=i+1) begin
    assign wrbe_s0_0[i*`POWLIB_BW+:`POWLIB_BW] = ((vld_s0_0==1)&&(op_s0_0==`POWLIB_OP_WRITE)&&(be_s0_0[i]==1)) ? {`POWLIB_BW{1'b1}} : {`POWLIB_BW{1'b0}};
  end
  
  // Stage the valid read address data. The data from the write interface becomes the return address. Determine if read operation occurs.
  // Finally, stage the output of the RAM.
  assign rdidx_s0_0 = wridx_s0_0;
  assign vld_s0_1   = (vld_s0_0==1)&&(op_s0_0==`POWLIB_OP_READ);
  assign data_s0_2  = rddata_s0_0;
  powlib_flipflop #(.W(1),   .EAR(EAR)) vld_s0_s1_inst  (.d(vld_s0_1),          .q(vld_s1_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s0_s1_inst (.d(data_s0_1[0+:B_AW]),.q(addr_s1_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s0_s1_inst (.d(data_s0_2),         .q(data_s1_0),.clk(clk),.rst(1'd0));
  
  // Stage the data from the last step before FIFO. Pack the data as well.
  powlib_flipflop #(.W(1),   .EAR(EAR)) vld_s1_s2_inst  (.d(vld_s1_0), .q(vld_s2_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s1_s2_inst (.d(addr_s1_0),.q(addr_s2_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s1_s2_inst (.d(data_s1_0),.q(data_s2_0),.clk(clk),.rst(1'd0));
  powlib_ippackintr0 #(.B_BPD(B_BPD)) pack_s2_inst   (.wrdata(data_s2_0),.wrbe({B_BEW{1'b1}}),.wrop(`POWLIB_OP_WRITE),.rddata(data_s2_1));
  
  // FIFO the output data.
  powlib_busfifo #(.NFS(3),.D(8),.S(IN_S),.ID({ID,"_OUTFIFO"}),.EDBG(EDBG),.B_AW(B_AW),.B_DW(B_WW)) outfifo_inst (
    .wrdata(data_s2_1),.wraddr(addr_s2_0),.wrvld(vld_s2_0),.wrrdy(rdy_s2_0),.wrnf(nf_s2_0),.wrclk(clk),.wrrst(rst),
    .rddata(rddata),.rdaddr(rdaddr),.rdvld(rdvld),.rdrdy(rdrdy),.rdclk(clk),.rdrst(rst));

  initial begin
    if (B_DW<B_AW) begin
      $display("ID: %s, B_DW: %d, B_AW: %d, B_DW must be equal to or greater than B_AW", ID, B_DW, B_AW);
      $finish;
    end
  end

endmodule