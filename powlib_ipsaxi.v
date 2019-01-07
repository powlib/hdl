`timescale 1ns / 1ps

module powlib_ipsaxi_rd(arid,araddr,arlen,arsize,arburst,arvalid,arready,
                        rid,rdata,rresp,rlast,rvalid,rready,
                        rdaddr,rddata,rdvld,rdrdy,
                        wraddr,wrdata,wrvld,wrrdy,wrnf,clk,rst);

`include "powlib_std.vh"
`include "powlib_ip.vh" 

  parameter                     ID        = "RD";  // String identifier  
  parameter                     EAR       = 0;         // Enable asynchronous reset  
  parameter                     EDBG      = 0;
  parameter                     IDW       = 1;
  parameter                     WR_D      = 8;
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
  // PLB Reading
  output wire [B_AW-1:0]        rdaddr;
  output wire [B_DW-1:0]        rddata;
  output wire                   rdvld;
  input  wire                   rdrdy;
  // PLB Writing 
  input  wire [B_AW-1:0]        wraddr;
  input  wire [B_DW-1:0]        wrdata;
  input  wire                   wrvld;
  output wire                   wrrdy;
  output wire                   wrnf;  
  
  // FIFOs.

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
  parameter                     WR_D      = 8;
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
  // PLB Reading
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
    .W(IDW+B_AW+`AXI_LENW+`AXI_SIZEW+`AXI_BURSTW),.EAR(EAR),.ID({ID,"_AWFIFO"}),.EDBG(EDBG)) 
  fifo_awin_aws0_0_inst (
    .wrdata(data_awin_0),.wrvld(awvalid),.wrrdy(awready),.rddata(data_aws0_0),.rdvld(vld_aws0_0),.rdrdy(rdy_aws0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
  
  powlib_swissfifo #(
    .W(B_DW+B_BEW+1),.D(8),.EAR(EAR),.ID({ID,"_WFIFO"}),.EDBG(EDBG)) 
   fifo_win_ws0_0_inst (
    .wrdata(data_win_0),.wrvld(wvalid),.wrrdy(wready),.rddata(data_ws0_0),.rdvld(vld_ws0_0),.rdrdy(rdy_ws0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(B_AW+B_DW+B_BEW),.NFS(3),.D(8+WR_D),.S(WR_S),.EAR(EAR),.ID({ID,"_OUTFIFO"}),.EDBG(EDBG))
  fifo_s3_rdout_0_inst (
    .wrdata(data_s3_1),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0),
    .rddata(data_rdout_0),.rdvld(rdvld),.rdrdy(rdrdy),.wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(
    .W(`AXI_RESPW+IDW),.NFS(3),.D(8),.EAR(EAR),.ID({ID,"_BFIFO"}),.EDBG(EDBG))
  fifo_bs3_bout_0_inst (
    .wrdata(data_bs3_0),.wrvld(vld_bs3_0),.wrrdy(rdy_bs3_0),.wrnf(nf_bs3_0),
    .rddata(data_bsout_0),.rdvld(bvalid),.rdrdy(bready),.wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));

endmodule