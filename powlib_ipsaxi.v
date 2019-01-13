`timescale 1ns / 1ps

module powlib_ipsaxi(wraddr,wrdata,wrvld,wrrdy,wrnf,rdaddr,rddata,rdvld,rdrdy,
                     awid,awaddr,awlen,awsize,awburst,awvalid,awready,
                     wdata,wstrb,wlast,wvalid,wready,
                     bresp,bid,bvalid,bready,
                     arid,araddr,arlen,arsize,arburst,arvalid,arready,
                     rid,rdata,rresp,rlast,rvalid,rready,
                     clk,rst);
                     
  parameter                     ID        = "IPSAXI";  // String identifier  
  parameter                     EAR       = 0;     // Enable asynchronous reset  
  parameter                     EDBG      = 0;
  parameter                     IDW       = 1;
  parameter                     IN_D      = 8;
  parameter                     IN_NFS    = 0;
  parameter                     IN_S      = 0;
  parameter                     WR_D      = 0;
  parameter                     WR_S      = 0;
  parameter                     RD_D      = 0;
  parameter                     RD_S      = 0;
  parameter                     B_BPD     = 4;
  parameter                     B_AW      = `POWLIB_BW*B_BPD;
  parameter [B_AW-1:0]          B_BASE    = {B_AW{1'd0}};  
  localparam                    B_DW      = `POWLIB_BW*B_BPD;
  localparam                    B_BEW     = B_BPD;
  localparam                    B_OPW     = `POWLIB_OPW;
  localparam                    B_WW      = B_OPW+B_BEW+B_DW;                      
  
                     
  /* GLOBAL SYNCHRONIZATION INTERFACE */
  input  wire                   clk;
  input  wire                   rst;
      
  /* POWLIB INTERFACE */  
  // Writing 
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
  
  /* MASTER AXI INTERFACE */
  // Address Writing
  input  wire [IDW-1:0]         awid;
  input  wire [B_AW-1:0]        awaddr;
  input  wire [`AXI_LENW-1:0]   awlen;
  input  wire [`AXI_SIZEW-1:0]  awsize;
  input  wire [`AXI_BURSTW-1:0] awburst;
  input  wire                   awvalid;
  output wire                   awready;
  // Writing Data 
  input  wire [B_DW-1:0]        wdata;
  input  wire [B_BEW-1:0]       wstrb;
  input  wire                   wlast;
  input  wire                   wvalid;
  output wire                   wready;
  // Writing Response
  output wire [`AXI_RESPW-1:0]  bresp;
  output wire [IDW-1:0]         bid;
  output wire                   bvalid;
  input  wire                   bready;
  // Address Reading 
  input  wire [IDW-1:0]         arid;
  input  wire [B_AW-1:0]        araddr;
  input  wire [`AXI_LENW-1:0]   arlen;
  input  wire [`AXI_SIZEW-1:0]  arsize;
  input  wire [`AXI_BURSTW-1:0] arburst;
  input  wire                   arvalid;
  output wire                   arready;
  // Reading Data
  output wire [IDW-1:0]         rid;
  output wire [B_DW-1:0]        rdata;
  output wire [`AXI_RESPW-1:0]  rresp;
  output wire                   rlast;
  output wire                   rvalid;
  input  wire                   rready;
  
  wire [B_WW-1:0]  data_s0_0, data_z1_0;
  wire [B_AW-1:0]  addr_z0_0, addr_z1_0;
  wire [B_DW-1:0]  data_z0_0, data_wz0_0, data_z1_1, data_s0_1, data_s1_0;
  wire [B_BEW-1:0] be_z0_0, be_wz0_0, be_z1_0, be_s0_0;
  wire [B_OPW-1:0] op_z0_0, op_z1_0, op_s0_0;
  
  assign rdy_rz0_0 = !nf_z1_0  && !vld_wz0_0;
  assign vld_rz0_1 = vld_rz0_0 && rdy_rz0_0;
  assign rdy_wz0_0 = !nf_z1_0;
  assign vld_wz0_1 = vld_wz0_0 && rdy_wz0_0;
  assign vld_z0_0  = vld_wz0_1||vld_rz0_1;
  assign addr_z0_0 = (rdy_rz0_0) ? addr_rz0_0      : addr_wz0_0;
  assign data_z0_0 = (rdy_rz0_0) ? B_BASE          : data_wz0_0;
  assign be_z0_0   = (rdy_rz0_0) ? {B_BEW{1'd1}}   : be_wz0_0;
  assign op_z0_0   = (rdy_rz0_0) ? `POWLIB_OP_READ : `POWLIB_OP_WRITE;
  
  assign rdy_s0_0  = !nf_s1_0;
  assign vld_s1_1  = vld_s0_0 && rdy_s0_0;

  powlib_ipunpackintr0 #(.B_BPD(B_BPD))             unpack_s0_0_inst (.wrdata(data_s0_0),.rddata(data_s0_1),.rdbe(be_s0_0),.rdop(op_s0_0));
  powlib_ippackintr0   #(.B_BPD(B_BPD))               pack_z1_0_inst (.wrdata(data_z1_1),.wrbe(be_z1_0),.wrop(op_z1_0),.rddata(data_z1_0));  
  
  powlib_flipflop #(.W(1),    .EAR(EAR))  vld_z0_z1_0_inst (.d(vld_z0_0), .q(vld_z1_0), .clk(clk),.rst(rst)); 
  powlib_flipflop #(.W(B_AW), .EAR(EAR)) addr_z0_z1_0_inst (.d(addr_z0_0),.q(addr_z1_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW), .EAR(EAR)) data_z0_z1_0_inst (.d(data_z0_0),.q(data_z1_1),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_BEW),.EAR(EAR))   be_z0_z1_0_inst (.d(be_z0_0),  .q(be_z1_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_OPW),.EAR(EAR))   op_z0_z1_0_inst (.d(op_z0_0),  .q(op_z1_0),  .clk(clk),.rst(1'd0));
  
  powlib_flipflop #(.W(1),    .EAR(EAR))  vld_s0_s1_0_inst (.d(vld_s1_1), .q(vld_s1_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(B_DW), .EAR(EAR)) data_s0_s1_0_inst (.d(data_s0_1),.q(data_s1_0),.clk(clk),.rst(1'd0));  
  
  powlib_ipsaxi_rd #(
    .ID({ID,"_RD"}),.EAR(EAR),.EDBG(EDBG),.IDW(IDW),.IN_D(8),.IN_NFS(1),.RD_D(RD_D),.RD_S(RD_S),.B_BPD(B_BPD),.B_AW(B_AW))
  rd_inst (
    .arid(arid),.araddr(araddr),.arlen(arlen),.arsize(arsize),.arvalid(arvalid),.arready(arready),
    .rid(rid),.rdata(rdata),.rresp(rresp),.rlast(rlast),.rvalid(rvalid),.rready(rready),
    .rdaddr(addr_rz0_0),.rdvld(vld_rz0_0),.rdrdy(rdy_rz0_0),
    .wrdata(data_s1_0),.wrvld(vld_s1_0),.wrrdy(rdy_s1_0),.wrnf(nf_s1_0));
    
  powlib_ipsaxi_wr #(
    .ID({ID,"_WR"}),.EAR(EAR),.EDBG(EDBG),.IDW(IDW),.WR_D(WR_D),.WR_S(WR_S),.B_BPD(B_BPD),.B_AW(B_AW))
  wr_inst (
    .awid(awid),.awaddr(awaddr),.awlen(awlen),.awsize(awsize),.awburst(awburst),.awvalid(awvalid),.awready(awready),
    .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),
    .bresp(bresp),.bid(bid),.bvalid(bvalid),.bready(bready),
    .rdaddr(addr_wz0_0),.rddata(data_wz0_0),.rdbe(be_wz0_0),.rdvld(vld_wz0_0),.rdrdy(rdy_wz0_0));    

  powlib_busfifo #(
    .NFS(IN_NFS),.D(IN_D),.S(IN_S),.EAR(EAR),
    .ID({ID,"_INFIFO"}),.EDBG(EDBG),.B_AW(B_AW),.B_DW(B_WW)) 
  fifo_wrin_s0_0_inst (
    .wrdata(wrdata),.wraddr(wraddr),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),
    .rddata(data_s0_0),.rdaddr(addr_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));    
        
  powlib_busfifo #(
    .NFS(1),.D(8),.EAR(EAR),
    .ID({ID,"_OUTFIFO"}),.EDBG(EDBG),.B_AW(B_AW),.B_DW(B_DW)) 
  fifo_z1_rdout_0_inst (
    .wrdata(data_z1_0),.wraddr(addr_z1_0),.wrvld(vld_z1_0),.wrrdy(rdy_z1_0),.wrnf(nf_z1_0),
    .rddata(rddata),.rdaddr(rdaddr),.rdvld(rdvld),.rdrdy(rdrdy),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));    
                     
endmodule                     

module powlib_ipsaxi_rd(arid,araddr,arlen,arsize,arburst,arvalid,arready,
                        rid,rdata,rresp,rlast,rvalid,rready,
                        rdaddr,rdvld,rdrdy,
                        wrdata,wrvld,wrrdy,wrnf,clk,rst);

`include "powlib_std.vh"
`include "powlib_ip.vh" 

  /* ------------------------------------------- 
   * WARNING
   * There's actually a huge fundamental problem
   * that will need to be addressed in the future.
   * Currently, the architecture is designed such 
   * that this core sends out read requests through
   * the powlib Bus (PLB) Reading Interface, and 
   * expects the data to arrive IN ORDER through the
   * PLB Reading Interface. However, if the IN ORDER
   * condition is not kept--considering the interconnect 
   * cannot guarantee ordered transactions accross the 
   * memory boundaries of different IP--this core will
   * will return the incorrectly ordered data across
   * its Slave AXI Interface.
   * ------------------------------------------- */

  parameter                     ID        = "RD";  // String identifier  
  parameter                     EAR       = 0;     // Enable asynchronous reset  
  parameter                     EDBG      = 0;
  parameter                     IDW       = 1;
  parameter                     IN_D      = 8;
  parameter                     IN_NFS    = 0;
  parameter                     IN_S      = 0;
  parameter                     RD_D      = 0;
  parameter                     RD_S      = 0;
  parameter                     B_BPD     = 4;
  parameter                     B_AW      = `POWLIB_BW*B_BPD;
  localparam                    B_DW      = `POWLIB_BW*B_BPD;
  localparam                    B_BEW     = B_BPD;
  localparam                    B_OPW     = `POWLIB_OPW;
  localparam                    B_WW      = B_OPW+B_BEW+B_DW; 
  localparam                    CNTRW     = `AXI_LENW;

  input  wire                   clk;
  input  wire                   rst;
  // AXI Address Reading
  input  wire [IDW-1:0]         arid;
  input  wire [B_AW-1:0]        araddr;
  input  wire [`AXI_LENW-1:0]   arlen;
  input  wire [`AXI_SIZEW-1:0]  arsize;
  input  wire [`AXI_BURSTW-1:0] arburst;
  input  wire                   arvalid;
  output wire                   arready; 
  // AXI Reading Data
  output wire [IDW-1:0]         rid;
  output wire [B_DW-1:0]        rdata;
  output wire [`AXI_RESPW-1:0]  rresp;
  output wire                   rlast;
  output wire                   rvalid;
  input  wire                   rready;  
  // PLB Reading -- Used for making read requests.
  output wire [B_AW-1:0]        rdaddr;
  output wire                   rdvld;
  input  wire                   rdrdy;
  // PLB Writing -- Used for receiving the responses (i.e. the data) from the read requests.
  input  wire [B_DW-1:0]        wrdata;
  input  wire                   wrvld;
  output wire                   wrrdy;
  output wire                   wrnf;  
  
  wire [(IDW+B_AW+`AXI_LENW+`AXI_SIZEW+`AXI_BURSTW)-1:0] data_arin_0, data_ars0_0;
  wire [(IDW+`AXI_RESPW+1)-1:0]                          data_cntrls3_1, data_cntrlz0_1;
  wire [(IDW+B_DW+`AXI_RESPW+1)-1:0]                     data_z3_1, data_rout_0;
  wire [`AXI_BURSTW-1:0]                                 burst_ars0_0, burst_ars1_0, burst_ars2_0;
  wire [`AXI_SIZEW-1:0]                                  size_ars0_0, size_ars1_0;
  wire [`AXI_LENW-1:0]                                   len_ars0_0, len_ars1_0;
  wire [B_AW-1:0]                                        shift_s2_0, addr_ars0_0, addr_ars1_0, addr_s2_0, addr_s3_0;
  reg  [B_AW-1:0]                                        addr_s1_0;
  reg  [B_AW-1:0]                                        shift_s1_0[0:(1<<`AXI_SIZEW)-1];
  wire [IDW-1:0]                                         id_ars0_0, id_ars1_0, id_cntrls2_0, id_cntrls3_0, id_cntrlz0_0, id_z1_0, id_z2_0, id_z3_0;
  wire [`AXI_RESPW-1:0]                                  resp_cntrls2_0, resp_cntrls3_0, resp_cntrlz0_0, resp_z1_0, resp_z2_0, resp_z3_0;
  wire [B_DW-1:0]                                        data_z0_0, data_z1_0, data_z2_0, data_z3_0;
  wire [CNTRW-1:0]                                       cntr_s1_0;
  integer                                                i;
  
  // Logic.
  assign data_arin_0[0+:`AXI_BURSTW]                                 = arburst;
  assign data_arin_0[(0+`AXI_BURSTW)+:`AXI_SIZEW]                    = arsize;
  assign data_arin_0[(0+`AXI_BURSTW+`AXI_SIZEW)+:`AXI_LENW]          = arlen;
  assign data_arin_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW)+:B_AW]     = araddr;
  assign data_arin_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW+B_AW)+:IDW] = arid;
  assign burst_ars0_0 = data_ars0_0[0+:`AXI_BURSTW];
  assign size_ars0_0  = data_ars0_0[(0+`AXI_BURSTW)+:`AXI_SIZEW];
  assign len_ars0_0   = data_ars0_0[(0+`AXI_BURSTW+`AXI_SIZEW)+:`AXI_LENW];
  assign addr_ars0_0  = data_ars0_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW)+:B_AW];
  assign id_ars0_0    = data_ars0_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW+B_AW)+:IDW];  
  
  assign data_cntrls3_1[0+:1]                  = last_cntrls3_0;
  assign data_cntrls3_1[(0+1)+:`AXI_RESPW]     = resp_cntrls3_0;
  assign data_cntrls3_1[(0+1+`AXI_RESPW)+:IDW] = id_cntrls3_0;
  assign last_cntrlz0_0 = data_cntrlz0_1[0+:1];
  assign resp_cntrlz0_0 = data_cntrlz0_1[(0+1)+:`AXI_RESPW];
  assign id_cntrlz0_0   = data_cntrlz0_1[(0+1+`AXI_RESPW)+:IDW];
  
  assign data_z3_1[0+:1]                       = last_z3_0;
  assign data_z3_1[(0+1)+:`AXI_RESPW]          = resp_z3_0;
  assign data_z3_1[(0+1+`AXI_RESPW)+:B_DW]     = data_z3_0;
  assign data_z3_1[(0+1+`AXI_RESPW+B_DW)+:IDW] = id_z3_0;
  assign rlast = data_rout_0[0+:1];
  assign rresp = data_rout_0[(0+1)+:`AXI_RESPW];
  assign rdata = data_rout_0[(0+1+`AXI_RESPW)+:B_DW];
  assign rid   = data_rout_0[(0+1+`AXI_RESPW+B_DW)+:IDW];
  
  assign transset_s0_0  = addrfin_s1_0 && !vld_ars0_1;
  assign transclr_s0_0  = vld_ars0_1;
  assign rdy_ars0_0     = !nf_s3_0 && !nf_cntrls3_0 && transfin_s1_1;
  assign vld_ars0_1     = vld_ars0_0 && rdy_ars0_0;
  assign clr_s0_0       = vld_ars0_1;
  assign adv_s0_0       = !clr_s0_0 && vld_s1_0;
  assign addrfin_s1_0   = (cntr_s1_0==len_ars1_0) && vld_s1_0;
  assign transfin_s1_1  = transfin_s1_0 || addrfin_s1_0;
  assign vld_s1_0       = !nf_s3_0 && !nf_cntrls3_0 && !transfin_s1_0;
  assign last_cntrls1_0 = addrfin_s1_0;
  assign resp_cntrls2_0 = ((burst_ars2_0!=`AXI_INCRBT) || (shift_s2_0>B_BPD))? `AXI_SLVERRRT : `AXI_OKAYRT;
  
  assign rdy_cntrlz0_0 = !nf_z3_0 && vld_z0_0;
  assign vld_cntrlz0_1 = vld_cntrlz0_0 && rdy_cntrlz0_0;
  assign rdy_z0_0      = !nf_z3_0 && vld_cntrlz0_0;
  assign vld_z0_1      = vld_z0_0 && rdy_z0_0;
  
  always @(*) begin
    if (vld_ars1_0) begin
      addr_s1_0 <= addr_ars1_0;
    end else begin
      addr_s1_0 <= addr_s2_0+shift_s1_0[size_ars1_0];
    end
  end
  
  initial begin
    for (i=0; i<(1<<`AXI_SIZEW); i=i+1) begin
      shift_s1_0[i] <= (1<<i);
    end
  end
  
  // Pipeline
  powlib_flag #(.INIT(1'd1),.EAR(EAR)) transfin_s0_s1_0_inst (.q(transfin_s1_0),.set(transset_s0_0),.clr(transclr_s0_0),.clk(clk),.rst(rst));
  
  powlib_flipflop #(.W(`AXI_BURSTW),.EVLD(1),.EAR(EAR)) burst_ars0_ars1_0_inst (.d(burst_ars0_0),.q(burst_ars1_0),.clk(clk),.rst(1'd0),.vld(vld_ars0_1)); 
  powlib_flipflop #(.W(`AXI_BURSTW),         .EAR(EAR)) burst_ars1_ars2_0_inst (.d(burst_ars1_0),.q(burst_ars2_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(`AXI_SIZEW), .EVLD(1),.EAR(EAR))  size_ars0_ars1_0_inst (.d(size_ars0_0), .q(size_ars1_0), .clk(clk),.rst(1'd0),.vld(vld_ars0_1));  
  powlib_flipflop #(.W(`AXI_LENW),  .EVLD(1),.EAR(EAR))   len_ars0_ars1_0_inst (.d(len_ars0_0),  .q(len_ars1_0),  .clk(clk),.rst(1'd0),.vld(vld_ars0_1)); 
  powlib_flipflop #(.W(B_AW),       .EVLD(1),.EAR(EAR))  addr_ars0_ars1_0_inst (.d(addr_ars0_0), .q(addr_ars1_0), .clk(clk),.rst(1'd0),.vld(vld_ars0_1));
  powlib_flipflop #(.W(IDW),        .EVLD(1),.EAR(EAR))    id_ars0_ars1_0_inst (.d(id_ars0_0),   .q(id_ars1_0),   .clk(clk),.rst(1'd0),.vld(vld_ars0_1));
  powlib_flipflop #(.W(1),                   .EAR(EAR))   vld_ars0_ars1_0_inst (.d(vld_ars0_1),  .q(vld_ars1_0),  .clk(clk),.rst(rst));  
  
  powlib_flipflop #(.W(B_AW),         .EAR(EAR)) shift_s1_s2_0_inst (.d(shift_s1_0[size_ars1_0]),.q(shift_s2_0),.clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(B_AW),.EVLD(1),.EAR(EAR))  addr_s1_s2_0_inst (.d(addr_s1_0),              .q(addr_s2_0), .clk(clk),.rst(1'd0),.vld(vld_s1_0));
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))  addr_s2_s3_0_inst (.d(addr_s2_0),              .q(addr_s3_0), .clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(1),            .EAR(EAR))   vld_s1_s2_0_inst (.d(vld_s1_0),               .q(vld_s2_0),  .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),            .EAR(EAR))   vld_s2_s3_0_inst (.d(vld_s2_0),               .q(vld_s3_0),  .clk(clk),.rst(rst));
  
  powlib_flipflop #(.W(1),         .EAR(EAR)) last_cntrls1_cntrls2_0_inst (.d(last_cntrls1_0),.q(last_cntrls2_0),.clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(1),         .EAR(EAR)) last_cntrls2_cntrls3_0_inst (.d(last_cntrls2_0),.q(last_cntrls3_0),.clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(`AXI_RESPW),.EAR(EAR)) resp_cntrls2_cntrls3_0_inst (.d(resp_cntrls2_0),.q(resp_cntrls3_0),.clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(IDW),       .EAR(EAR))      id_ars1_cntrls2_0_inst (.d(id_ars1_0),     .q(id_cntrls2_0),  .clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(IDW),       .EAR(EAR))   id_cntrls2_cntrls3_0_inst (.d(id_cntrls2_0),  .q(id_cntrls3_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),         .EAR(EAR))       vld_s1_cntrls2_0_inst (.d(vld_s1_0),      .q(vld_cntrls2_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),         .EAR(EAR))  vld_cntrls2_cntrls3_0_inst (.d(vld_cntrls2_0), .q(vld_cntrls3_0), .clk(clk),.rst(rst));  
  
  powlib_flipflop #(.W(1),         .EAR(EAR)) last_cntrlz0_z1_0_inst (.d(last_cntrlz0_0),.q(last_z1_0),.clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(1),         .EAR(EAR))      last_z1_z2_0_inst (.d(last_z1_0),     .q(last_z2_0),.clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(1),         .EAR(EAR))      last_z2_z3_0_inst (.d(last_z2_0),     .q(last_z3_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(`AXI_RESPW),.EAR(EAR)) resp_cntrlz0_z1_0_inst (.d(resp_cntrlz0_0),.q(resp_z1_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(`AXI_RESPW),.EAR(EAR))      resp_z1_z2_0_inst (.d(resp_z1_0),     .q(resp_z2_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(`AXI_RESPW),.EAR(EAR))      resp_z2_z3_0_inst (.d(resp_z2_0),     .q(resp_z3_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),      .EAR(EAR))      data_z0_z1_0_inst (.d(data_z0_0),     .q(data_z1_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),      .EAR(EAR))      data_z1_z2_0_inst (.d(data_z1_0),     .q(data_z2_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),      .EAR(EAR))      data_z2_z3_0_inst (.d(data_z2_0),     .q(data_z3_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(IDW),       .EAR(EAR))   id_cntrlz0_z1_0_inst (.d(id_cntrlz0_0),  .q(id_z1_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(IDW),       .EAR(EAR))        id_z1_z2_0_inst (.d(id_z1_0),       .q(id_z2_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(IDW),       .EAR(EAR))        id_z2_z3_0_inst (.d(id_z2_0),       .q(id_z3_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),         .EAR(EAR))       vld_z0_z1_0_inst (.d(vld_z0_1),      .q(vld_z1_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),         .EAR(EAR))       vld_z1_z2_0_inst (.d(vld_z1_0),      .q(vld_z2_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),         .EAR(EAR))       vld_z2_z3_0_inst (.d(vld_z2_0),      .q(vld_z3_0), .clk(clk),.rst(rst));
  
  // Counter
  powlib_cntr #(.W(CNTRW),.EAR(EAR),.ELD(0)) cntr_s0_s1_0_inst (
    .cntr(cntr_s1_0),.adv(adv_s0_0),.clr(clr_s0_0),.clk(clk),.rst(rst));
  
  // FIFOs.
  powlib_swissfifo #(
    .W(IDW+B_AW+`AXI_LENW+`AXI_SIZEW+`AXI_BURSTW),.D(8),.EAR(EAR),.ID({ID,"_ARFIFO"}),.EDBG(EDBG)) 
  fifo_arin_ars0_0_inst (
    .wrdata(data_arin_0),.wrvld(arvalid),.wrrdy(arready),.rddata(data_ars0_0),.rdvld(vld_ars0_0),.rdrdy(rdy_ars0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(B_AW),.NFS(3),.D(8),.EAR(EAR),.ID({ID,"_OUTFIFO"}),.EDBG(EDBG))
  fifo_s3_rdout_0_inst (
    .wrdata(addr_s3_0),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0),
    .rddata(rdaddr),.rdvld(rdvld),.rdrdy(rdrdy),.wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(IDW+`AXI_RESPW+1),.NFS(3),.D(8),.EAR(EAR),.ID({ID,"_CNTRLFIFO"}),.EDBG(EDBG))
  fifo_cntrls3_cntrlz0_0_inst (
    .wrdata(data_cntrls3_1),.wrvld(vld_cntrls3_0),.wrrdy(rdy_cntrls3_0),.wrnf(nf_cntrls3_0),
    .rddata(data_cntrlz0_1),.rdvld(vld_cntrlz0_0),.rdrdy(rdy_cntrlz0_0),.wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(B_DW),.NFS(IN_NFS),.D(IN_D),.S(IN_S),.EAR(EAR),.ID({ID,"_INFIFO"}),.EDBG(EDBG))
  fifo_wrin_z0_0_inst (
    .wrdata(wrdata),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),
    .rddata(data_z0_0),.rdvld(vld_z0_0),.rdrdy(rdy_z0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(IDW+B_DW+`AXI_RESPW+1),.NFS(3),.D(8+RD_D),.S(RD_S),.EAR(EAR),.ID({ID,"_RFIFO"}),.EDBG(EDBG))
  fifo_z1_rout_0_inst (
    .wrdata(data_z3_1),.wrvld(vld_z3_0),.wrrdy(rdy_z3_0),.wrnf(nf_z3_0),
    .rddata(data_rout_0),.rdvld(rvalid),.rdrdy(rready),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));

endmodule

module powlib_ipsaxi_wr(awid,awaddr,awlen,awsize,awburst,awvalid,awready,
                        wdata,wstrb,wlast,wvalid,wready,
                        bresp,bid,bvalid,bready,
                        rdaddr,rddata,rdbe,rdvld,rdrdy,
                        clk,rst);
                        
`include "powlib_std.vh"
`include "powlib_ip.vh" 
                        
  parameter                     ID        = "WR";  // String identifier  
  parameter                     EAR       = 0;         // Enable asynchronous reset  
  parameter                     EDBG      = 0;
  parameter                     IDW       = 1;
  parameter                     WR_D      = 0;
  parameter                     WR_S      = 0;
  parameter                     B_BPD     = 4;
  parameter                     B_AW      = `POWLIB_BW*B_BPD;
  localparam                    B_DW      = `POWLIB_BW*B_BPD;
  localparam                    B_BEW     = B_BPD;
  localparam                    B_OPW     = `POWLIB_OPW;
  localparam                    B_WW      = B_OPW+B_BEW+B_DW; 
  localparam                    CNTRW     = `AXI_LENW;

  input  wire                   clk;
  input  wire                   rst;
  // AXI Address Writing
  input  wire [IDW-1:0]         awid;
  input  wire [B_AW-1:0]        awaddr;
  input  wire [`AXI_LENW-1:0]   awlen;
  input  wire [`AXI_SIZEW-1:0]  awsize;
  input  wire [`AXI_BURSTW-1:0] awburst;
  input  wire                   awvalid;
  output wire                   awready;
  // AXI Writing Data 
  input  wire [B_DW-1:0]        wdata;
  input  wire [B_BEW-1:0]       wstrb;
  input  wire                   wlast;
  input  wire                   wvalid;
  output wire                   wready; 
  // AXI Writing Response
  output wire [`AXI_RESPW-1:0]  bresp;
  output wire [IDW-1:0]         bid;
  output wire                   bvalid;
  input  wire                   bready;
  // PLB Reading -- Used for writing out the data.
  output wire [B_AW-1:0]        rdaddr;
  output wire [B_DW-1:0]        rddata;
  output wire [B_BEW-1:0]       rdbe;
  output wire                   rdvld;
  input  wire                   rdrdy; 
  
  wire [(IDW+B_AW+`AXI_LENW+`AXI_SIZEW+`AXI_BURSTW)-1:0] data_awin_0, data_aws0_0;
  wire [(B_DW+B_BEW+1)-1:0]                              data_win_0, data_ws0_0;
  wire [(`AXI_RESPW+IDW)-1:0]                            data_bs3_0, data_bsout_0;
  wire [(B_AW+B_DW+B_BEW)-1:0]                           data_s3_1, data_rdout_0;
  wire [`AXI_BURSTW-1:0]                                 burst_aws0_0, burst_aws1_0, burst_aws2_0;
  wire [`AXI_SIZEW-1:0]                                  size_aws0_0, size_aws1_0;
  wire [`AXI_LENW-1:0]                                   len_aws0_0, len_aws1_0;
  wire [`AXI_RESPW-1:0]                                  resp_bs2_0, resp_bs3_0;
  wire [B_AW-1:0]                                        addr_aws0_0, addr_aws1_0, addr_s2_0, addr_s3_0;
  reg  [B_AW-1:0]                                        addr_s1_0;
  wire [IDW-1:0]                                         id_aws0_0, id_aws1_0, id_bs2_0, id_bs3_0;
  wire [B_BEW-1:0]                                       strb_ws0_0, be_s1_0, be_s2_0, be_s3_0;
  wire [B_DW-1:0]                                        data_ws0_1, data_s1_0, data_s2_0, data_s3_0;
  wire [CNTRW-1:0]                                       cntr_s1_0;
  reg  [B_AW-1:0]                                        shift_s1_0 [0:(1<<`AXI_SIZEW)-1];
  integer                                                i; 
  
  // Logic.
  assign data_awin_0[0+:`AXI_BURSTW]                                 = awburst;
  assign data_awin_0[(0+`AXI_BURSTW)+:`AXI_SIZEW]                    = awsize;
  assign data_awin_0[(0+`AXI_BURSTW+`AXI_SIZEW)+:`AXI_LENW]          = awlen;
  assign data_awin_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW)+:B_AW]     = awaddr;
  assign data_awin_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW+B_AW)+:IDW] = awid;
  assign burst_aws0_0 = data_aws0_0[0+:`AXI_BURSTW];
  assign size_aws0_0  = data_aws0_0[(0+`AXI_BURSTW)+:`AXI_SIZEW];
  assign len_aws0_0   = data_aws0_0[(0+`AXI_BURSTW+`AXI_SIZEW)+:`AXI_LENW];
  assign addr_aws0_0  = data_aws0_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW)+:B_AW];
  assign id_aws0_0    = data_aws0_0[(0+`AXI_BURSTW+`AXI_SIZEW+`AXI_LENW+B_AW)+:IDW];
  
  assign data_win_0[0+:1]              = wlast;
  assign data_win_0[(0+1)+:B_BEW]      = wstrb;
  assign data_win_0[(0+1+B_BEW)+:B_DW] = wdata;
  assign last_ws0_0 = data_ws0_0[0+:1];
  assign strb_ws0_0 = data_ws0_0[(0+1)+:B_BEW];
  assign data_ws0_1 = data_ws0_0[(0+1+B_BEW)+:B_DW];
  
  assign data_s3_1[0+:B_BEW]             = be_s3_0;
  assign data_s3_1[(0+B_BEW)+:B_DW]      = data_s3_0;
  assign data_s3_1[(0+B_BEW+B_DW)+:B_AW] = addr_s3_0;
  assign rdbe   = data_rdout_0[0+:B_BEW];
  assign rddata = data_rdout_0[(0+B_BEW)+:B_DW];
  assign rdaddr = data_rdout_0[(0+B_BEW+B_DW)+:B_AW];
  
  assign data_bs3_0[0+:IDW]              = id_bs3_0;
  assign data_bs3_0[(0+IDW)+:`AXI_RESPW] = resp_bs3_0;
  assign bid   = data_bsout_0[0+:IDW];
  assign bresp = data_bsout_0[(0+IDW)+:`AXI_RESPW];
  
  assign transset_s0_0 = addrfin_s1_0 && !vld_aws0_1;
  assign transclr_s0_0 = vld_aws0_1;
  assign rdy_aws0_0    = !nf_s3_0 && !nf_bs3_0 && vld_ws0_0 && transfin_s1_1;
  assign vld_aws0_1    = vld_aws0_0 && rdy_aws0_0;
  assign rdy_ws0_0     = !nf_s3_0 && !nf_bs3_0 && (vld_aws0_0 || !transfin_s1_1);
  assign vld_ws0_1     = vld_ws0_0 && rdy_ws0_0;
  assign clr_s0_0      = vld_aws0_1;
  assign adv_s0_0      = !clr_s0_0 && vld_s1_0;
  assign addrfin_s1_0  = (cntr_s1_0==len_aws1_0) && vld_s1_0;
  assign transfin_s1_1 = transfin_s1_0 || addrfin_s1_0;
  assign vld_bs1_0     = addrfin_s1_0;
  assign resp_bs2_0    = ((vld_bs2_0!=last_s2_0)||(burst_aws2_0!=`AXI_INCRBT))? `AXI_SLVERRRT : `AXI_OKAYRT;
  
  always @(*) begin
    if (vld_aws1_0) begin
      addr_s1_0 <= addr_aws1_0;
    end else begin
      addr_s1_0 <= addr_s2_0+shift_s1_0[size_aws1_0];
    end
  end
  
  initial begin
    for (i=0; i<(1<<`AXI_SIZEW); i=i+1) begin
      shift_s1_0[i] <= (1<<i);
    end
  end
  
  // Pipeline
  powlib_flag #(.INIT(1'd1),.EAR(EAR)) transfin_s0_s1_0_inst (.q(transfin_s1_0),.set(transset_s0_0),.clr(transclr_s0_0),.clk(clk),.rst(rst));

  powlib_flipflop #(.W(`AXI_BURSTW),.EVLD(1),.EAR(EAR)) burst_aws0_aws1_0_inst (.d(burst_aws0_0),.q(burst_aws1_0),.clk(clk),.rst(1'd0),.vld(vld_aws0_1)); 
  powlib_flipflop #(.W(`AXI_BURSTW),         .EAR(EAR)) burst_aws1_aws2_0_inst (.d(burst_aws1_0),.q(burst_aws2_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(`AXI_SIZEW), .EVLD(1),.EAR(EAR))  size_aws0_aws1_0_inst (.d(size_aws0_0), .q(size_aws1_0), .clk(clk),.rst(1'd0),.vld(vld_aws0_1));  
  powlib_flipflop #(.W(`AXI_LENW),  .EVLD(1),.EAR(EAR))   len_aws0_aws1_0_inst (.d(len_aws0_0),  .q(len_aws1_0),  .clk(clk),.rst(1'd0),.vld(vld_aws0_1)); 
  powlib_flipflop #(.W(B_AW),       .EVLD(1),.EAR(EAR))  addr_aws0_aws1_0_inst (.d(addr_aws0_0), .q(addr_aws1_0), .clk(clk),.rst(1'd0),.vld(vld_aws0_1));
  powlib_flipflop #(.W(IDW),        .EVLD(1),.EAR(EAR))    id_aws0_aws1_0_inst (.d(id_aws0_0),   .q(id_aws1_0),   .clk(clk),.rst(1'd0),.vld(vld_aws0_1));
  powlib_flipflop #(.W(1),                   .EAR(EAR))   vld_aws0_aws1_0_inst (.d(vld_aws0_1),  .q(vld_aws1_0),  .clk(clk),.rst(rst));
  
  powlib_flipflop #(.W(B_AW),.EVLD(1),.EAR(EAR))  addr_s1_s2_0_inst (.d(addr_s1_0), .q(addr_s2_0),.clk(clk),.rst(1'd0),.vld(vld_s1_0));
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))  addr_s2_s3_0_inst (.d(addr_s2_0), .q(addr_s3_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),         .EAR(EAR)) data_ws0_s1_0_inst (.d(data_ws0_1),.q(data_s1_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),         .EAR(EAR))  data_s1_s2_0_inst (.d(data_s1_0), .q(data_s2_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_DW),         .EAR(EAR))  data_s2_s3_0_inst (.d(data_s2_0), .q(data_s3_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_BEW),        .EAR(EAR))   be_ws0_s1_0_inst (.d(strb_ws0_0),.q(be_s1_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_BEW),        .EAR(EAR))    be_s1_s2_0_inst (.d(be_s1_0),   .q(be_s2_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_BEW),        .EAR(EAR))    be_s2_s3_0_inst (.d(be_s2_0),   .q(be_s3_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),            .EAR(EAR)) last_ws0_s1_0_inst (.d(last_ws0_0),.q(last_s1_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),            .EAR(EAR))  last_s1_s2_0_inst (.d(last_s1_0), .q(last_s2_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),            .EAR(EAR))  vld_ws0_s1_0_inst (.d(vld_ws0_1), .q(vld_s1_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),            .EAR(EAR))   vld_s1_s2_0_inst (.d(vld_s1_0),  .q(vld_s2_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),            .EAR(EAR))   vld_s2_s3_0_inst (.d(vld_s2_0),  .q(vld_s3_0), .clk(clk),.rst(rst));
  
  powlib_flipflop #(.W(`AXI_RESPW),.EAR(EAR)) resp_bs2_bs3_0_inst (.d(resp_bs2_0),.q(resp_bs3_0),.clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(IDW),.EAR(EAR))         id_aws1_bs2_0_inst (.d(id_aws1_0), .q(id_bs2_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(IDW),.EAR(EAR))          id_bs2_bs3_0_inst (.d(id_bs2_0),  .q(id_bs3_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),.EAR(EAR))           vld_bs1_bs2_0_inst (.d(vld_bs1_0), .q(vld_bs2_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),.EAR(EAR))           vld_bs2_bs3_0_inst (.d(vld_bs2_0), .q(vld_bs3_0), .clk(clk),.rst(rst));
  
  // Counter
  powlib_cntr #(.W(CNTRW),.EAR(EAR),.ELD(0)) cntr_s0_s1_0_inst (
    .cntr(cntr_s1_0),.adv(adv_s0_0),.clr(clr_s0_0),.clk(clk),.rst(rst));
  
  // FIFOs.
  powlib_swissfifo #(
    .W(IDW+B_AW+`AXI_LENW+`AXI_SIZEW+`AXI_BURSTW),.D(8),.EAR(EAR),.ID({ID,"_AWFIFO"}),.EDBG(EDBG)) 
  fifo_awin_aws0_0_inst (
    .wrdata(data_awin_0),.wrvld(awvalid),.wrrdy(awready),.rddata(data_aws0_0),.rdvld(vld_aws0_0),.rdrdy(rdy_aws0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
  
  powlib_swissfifo #(
    .W(B_DW+B_BEW+1),.D(8+WR_D),.S(WR_S),.EAR(EAR),.ID({ID,"_WFIFO"}),.EDBG(EDBG)) 
   fifo_win_ws0_0_inst (
    .wrdata(data_win_0),.wrvld(wvalid),.wrrdy(wready),.rddata(data_ws0_0),.rdvld(vld_ws0_0),.rdrdy(rdy_ws0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(B_AW+B_DW+B_BEW),.NFS(3),.D(8),.EAR(EAR),.ID({ID,"_OUTFIFO"}),.EDBG(EDBG))
  fifo_s3_rdout_0_inst (
    .wrdata(data_s3_1),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0),
    .rddata(data_rdout_0),.rdvld(rdvld),.rdrdy(rdrdy),.wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(`AXI_RESPW+IDW),.NFS(3),.D(8),.EAR(EAR),.ID({ID,"_BFIFO"}),.EDBG(EDBG))
  fifo_bs3_bout_0_inst (
    .wrdata(data_bs3_0),.wrvld(vld_bs3_0),.wrrdy(rdy_bs3_0),.wrnf(nf_bs3_0),
    .rddata(data_bsout_0),.rdvld(bvalid),.rdrdy(bready),.wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));

endmodule