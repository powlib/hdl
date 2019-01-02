
module powlib_ipmaxi(wraddr,wrdata,wrvld,wrrdy,wrnf,rdaddr,rddata,rdvld,rdrdy,
                     respresp,respop,respvld,resprdy,
                     awaddr,awlen,awsize,awburst,awvalid,awready,
                     wdata,wstrb,wlast,wvalid,wready,
                     bresp,bvalid,bready,
                     araddr,arlen,arsize,arburst,arvalid,arready,
                     rdata,rresp,rlast,rvalid,rready,
                     clk,rst);
                     
`include "powlib_ip.vh"        

  parameter                     ID        = "IPMAXI";  // String identifier  
  parameter                     EAR       = 0;         // Enable asynchronous reset  
  parameter                     EDBG      = 0;
  parameter                     MAX_BURST = 256;
  parameter                     IN_NFS    = 0;
  parameter                     IN_D      = 8;
  parameter                     IN_S      = 0;
  parameter                     B_BPD     = 4;
  parameter                     B_AW      = `POWLIB_BW*B_BPD;
  localparam                    B_DW      = `POWLIB_BW*B_BPD;
  localparam                    B_BEW     = B_BPD;
  localparam                    B_OPW     = `POWLIB_OPW;
  localparam                    B_WW      = B_OPW+B_BEW+B_DW;   
  localparam                    B_RESPW   = `POWLIB_OPW+`AXI_RESPW;
                     
  /* GLOBAL SYNCHRONIZATION INTERFACE. */
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
  // Response 
  output wire [`AXI_RESPW-1:0]  respresp;
  output wire [`POWLIB_OPW-1:0] respop;
  output wire                   respvld;
  input  wire                   resprdy;
  
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
  
         wire [B_AW-1:0]        addr_s0_0, addr_s1_0, addr_s2_0, addr_s3_0;
         wire [B_WW-1:0]        data_s0_0;
         wire [B_DW-1:0]        data_s0_1, data_s1_0, data_s2_0, data_s3_0, data_out_0;
         wire [B_RESPW-1:0]     data_s3_1, data_out_1;
         wire [`AXI_RESPW-1:0]  resp_s2_1, resp_s2_0, resp_s2_2, resp_s3_0;
         wire [B_OPW-1:0]       op_s0_0, op_s1_0, op_s2_0, op_s3_0;
         wire [B_BEW-1:0]       be_s0_0, be_s1_0;
         wire                   rdy_s0_0, rdy_s2_0, rdy_s2_1, nf_s1_0, nf_s1_1, nf_s3_0, nf_s3_1, 
                                vld_s0_0, vld_s0_1, vld_s1_0, vld_s1_1, vld_s2_0, vld_s2_1, 
                                vld_s1_2, vld_s2_3, vld_s2_2, vld_s2_4, vld_s2_5, vld_s3_1, last_s2_0;
  
  // Logic
  assign data_s3_1[0+:`AXI_RESPW]                 = resp_s3_0;
  assign data_s3_1[(0+`AXI_RESPW)+:`POWLIB_OPW] = op_s3_0;
  assign respresp                                 = data_out_1[0+:`AXI_RESPW];
  assign respop                                   = data_out_1[(0+`AXI_RESPW)+:`POWLIB_OPW];
  
  assign rdy_s0_0  = !nf_s1_0 && !nf_s1_1;
  assign vld_s0_1  = vld_s0_0 && rdy_s0_0;
  assign vld_s1_0  = (op_s1_0==`POWLIB_OP_WRITE) && vld_s1_2;
  assign vld_s1_1  = (op_s1_0==`POWLIB_OP_READ)  && vld_s1_2;
  assign rdy_s2_0  = !nf_s3_0 && !nf_s3_1 && (!vld_s2_3 || !last_s2_0);
  assign vld_s2_2  = vld_s2_0 && rdy_s2_0;
  assign rdy_s2_1  = !nf_s3_1;
  assign vld_s2_3  = vld_s2_1 && rdy_s2_1;
  assign vld_s2_4  = vld_s2_2 && last_s2_0;
  assign vld_s2_5  = vld_s2_3 || vld_s2_4;
  assign resp_s2_2 = vld_s2_3 ? resp_s2_1        : resp_s2_0;
  assign op_s2_0   = vld_s2_3 ? `POWLIB_OP_WRITE : `POWLIB_OP_READ;
  
  // Pipeline
  powlib_ipunpackintr0 #(.B_BPD(B_BPD))             unpack_s0_0_inst (.wrdata(data_s0_0),.rddata(data_s0_1),.rdbe(be_s0_0),.rdop(op_s0_0));
  powlib_ippackintr0   #(.B_BPD(B_BPD))                pack_out_inst (.wrdata(data_out_0),.wrbe({B_BEW{1'd1}}),.wrop(`POWLIB_OP_WRITE),.rddata(rddata));  
  powlib_flipflop      #(.W(B_DW),      .EAR(EAR)) data_s0_s1_0_inst (.d(data_s0_1),.q(data_s1_0),.clk(clk),.rst(1'd0));  
  powlib_flipflop      #(.W(B_DW),      .EAR(EAR)) data_s2_s3_0_inst (.d(data_s2_0),.q(data_s3_0),.clk(clk),.rst(1'd0));  
  powlib_flipflop      #(.W(B_AW),      .EAR(EAR)) addr_s0_s1_0_inst (.d(addr_s0_0),.q(addr_s1_0),.clk(clk),.rst(1'd0));
  powlib_flipflop      #(.W(B_AW),      .EAR(EAR)) addr_s2_s3_0_inst (.d(addr_s2_0),.q(addr_s3_0),.clk(clk),.rst(1'd0));  
  powlib_flipflop      #(.W(B_BEW),     .EAR(EAR))   be_s0_s1_0_inst (.d(be_s0_0),  .q(be_s1_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop      #(.W(B_OPW),     .EAR(EAR))   op_s0_s1_0_inst (.d(op_s0_0),  .q(op_s1_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop      #(.W(1),         .EAR(EAR))  vld_s0_s1_0_inst (.d(vld_s0_1), .q(vld_s1_2), .clk(clk),.rst(rst));
  powlib_flipflop      #(.W(1),         .EAR(EAR))  vld_s2_s3_0_inst (.d(vld_s2_2), .q(vld_s3_0), .clk(clk),.rst(rst));  
  
  powlib_flipflop      #(.W(`AXI_RESPW),.EAR(EAR)) resp_s2_s3_0_inst (.d(resp_s2_2),.q(resp_s3_0),.clk(clk),.rst(1'd0));
  powlib_flipflop      #(.W(B_OPW),     .EAR(EAR))   op_s2_s3_0_inst (.d(op_s2_0),  .q(op_s3_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop      #(.W(1),         .EAR(EAR))  vld_s2_s3_1_inst (.d(vld_s2_5), .q(vld_s3_1), .clk(clk),.rst(rst));
  
  
  // Main components
  powlib_ipmaxi_wr #(
    .MAX_BURST(MAX_BURST),.ID({ID,"_WR"}),.EAR(EAR),.EDBG(EDBG),
    .IN_NFS(1),.IN_D(4),.B_BPD(B_BPD),.B_AW(B_AW)) 
  wr_inst (
    .wraddr(addr_s1_0),.wrdata(data_s1_0),.wrbe(be_s1_0),.wrvld(vld_s1_0),.wrrdy(rdy_s1_0),.wrnf(nf_s1_0),
    .awaddr(awaddr),.awlen(awlen),.awsize(awsize),.awburst(awburst),.awvalid(awvalid),.awready(awready),
    .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.clk(clk),.rst(rst));  

  powlib_ipmaxi_rd #(
    .MAX_BURST(MAX_BURST),.ID({ID,"_RD"}),.EAR(EAR),.EDBG(EDBG),
    .IN_NFS(1),.IN_D(4),.B_BPD(B_BPD),.B_AW(B_AW))
  rd_inst (
    .wraddr(addr_s1_0),.wrdata(data_s1_0),.wrvld(vld_s1_1),.wrrdy(rdy_s1_1),.wrnf(nf_s1_1),
    .rdaddr(addr_s2_0),.rddata(data_s2_0),.rdresp(resp_s2_0),.rdlast(last_s2_0),.rdvld(vld_s2_0),.rdrdy(rdy_s2_0),
    .araddr(araddr),.arlen(arlen),.arsize(arsize),.arburst(arburst),.arvalid(arvalid),.arready(arready),
    .rdata(rdata),.rresp(rresp),.rlast(rlast),.rvalid(rvalid),.rready(rready),.clk(clk),.rst(rst));     
  
  // FIFOs
  powlib_busfifo #(
    .NFS(IN_NFS),.D(IN_D),.S(IN_S),.EAR(EAR),
    .ID({ID,"_INFIFO"}),.EDBG(EDBG),.B_AW(B_AW),.B_DW(B_WW)) 
  fifo_in_s0_0_inst (
    .wrdata(wrdata),.wraddr(wraddr),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),
    .rddata(data_s0_0),.rdaddr(addr_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_busfifo #(
    .NFS(1),.D(4),.EAR(EAR),
    .ID({ID,"_OUTFIFO"}),.EDBG(EDBG),.B_AW(B_AW),.B_DW(B_DW)) 
  fifo_s3_out_0_inst (
    .wrdata(data_s3_0),.wraddr(addr_s3_0),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0),
    .rddata(data_out_0),.rdaddr(rdaddr),.rdvld(rdvld),.rdrdy(rdrdy),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));   

  powlib_swissfifo #(
    .W(`AXI_RESPW),.D(4),.EAR(EAR),.ID({ID,"_BRESPFIFO"}),.EDBG(EDBG)) 
  fifo_in_s2_1_inst (
    .wrdata(bresp),.wrvld(bvalid),.wrrdy(bready),
    .rddata(resp_s2_1),.rdvld(vld_s2_1),.rdrdy(rdy_s2_1),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst)); 

  powlib_swissfifo #(
    .W(B_RESPW),.D(4),.EAR(EAR),.ID({ID,"_RESPOUTFIFO"}),.EDBG(EDBG)) 
  fifo_s3_out_1_inst (
    .wrdata(data_s3_1),.wrvld(vld_s3_1),.wrrdy(rdy_s3_1),.wrnf(nf_s3_1),
    .rddata(data_out_1),.rdvld(respvld),.rdrdy(resprdy),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));     
    
  always @(posedge clk) begin
    if (vld_s1_2 && !(vld_s1_0||vld_s1_1)) begin
      $display("ID: %s, WRITE and READ are the expected operators.", ID);
      $finish;      
    end
  end

endmodule

module powlib_ipmaxi_rd(wraddr,wrdata,wrvld,wrrdy,wrnf,
                        rdaddr,rddata,rdresp,rdlast,rdvld,rdrdy,
                        araddr,arlen,arsize,arburst,arvalid,arready,
                        rdata,rresp,rlast,rvalid,rready,
                        clk,rst);
                        
`include "powlib_std.vh"
`include "powlib_ip.vh" 

  parameter                     MAX_BURST    = 256;
  parameter                     ID           = "RD";  // String identifier  
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
  localparam                    CNTRW        = (CL2MAX_BURST==0) ? 1 : CL2MAX_BURST;

  input  wire                   clk;
  input  wire                   rst;
  // PLB Writing 
  input  wire [B_AW-1:0]        wraddr;
  input  wire [B_DW-1:0]        wrdata;
  input  wire                   wrvld;
  output wire                   wrrdy;
  output wire                   wrnf;  
  // PLB Reading
  output wire [B_AW-1:0]        rdaddr;
  output wire [B_DW-1:0]        rddata;
  output wire [`AXI_RESPW-1:0]  rdresp;
  output wire                   rdlast;
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
  
         wire [(B_AW+B_DW)-1:0]              data_in_0, data_s0_0;
         wire [(1+B_AW+`AXI_RESPW+B_DW)-1:0] data_rs1_0, data_out_0;
         wire [(`AXI_LENW+B_AW)-1:0]         data_ars3_0, data_arout_0;
         wire [(1+B_AW)-1:0]                 data_s3_0, data_rs0_2;
         wire [(1+`AXI_RESPW+B_DW)-1:0]      data_rin_0, data_rs0_0;
         wire [B_DW-1:0]                     data_s0_1, data_rs1_1, data_rs0_1;
         wire [B_AW-1:0]                     addr_s0_0, addr_s1_0, addr_s2_0, raddr_rs1_0, addr_ars3_0, 
                                             raddr_s1_0, raddr_s2_0, raddr_s3_0, raddr_rs0_0, base_s3_0;
         wire [CNTRW-1:0]                    cntr_s2_0, cntr_s3_0;
         wire [`AXI_RESPW-1:0]               resp_rs1_0, resp_rs0_0;
         wire [`AXI_LENW-1:0]                len_ars3_0;
         wire                                last_rs0_0, explast_s3_0, explast_rs0_0, 
                                             rdy_s0_0, rdy_rs0_0, rdy_rs0_1, nf_ars3_0, nf_s3_0, nf_rs1_0, 
                                             vld_s0_0, vld_s0_1, vld_s1_0, vld_s2_0, vld_s3_0, adv_s1_0, clr_s1_0,  
                                             addrfin_s2_0, addrfin_s3_0, basevld_s2_0, 
                                             vld_ars3_0, vld_rs0_2, vld_rs0_0, vld_rs0_1;
  
  // Combinational Logic
  assign arsize                                  = CL2B_BPD;
  assign arburst                                 = `AXI_INCRBT;
  
  assign data_in_0[0+:B_DW]                      = wrdata;
  assign data_in_0[(0+B_DW)+:B_AW]               = wraddr;
  assign data_s0_1                               = data_s0_0[0+:B_DW];
  assign addr_s0_0                               = data_s0_0[(0+B_DW)+:B_AW];
  
  assign data_rs1_0[0+:B_DW]                     = data_rs1_1;
  assign data_rs1_0[(0+B_DW)+:`AXI_RESPW]        = resp_rs1_0;
  assign data_rs1_0[(0+B_DW+`AXI_RESPW)+:B_AW]   = raddr_rs1_0;
  assign data_rs1_0[(0+B_DW+`AXI_RESPW+B_AW)+:1] = last_rs1_0;
  assign rddata                                  = data_out_0[0+:B_DW];
  assign rdresp                                  = data_out_0[(0+B_DW)+:`AXI_RESPW];
  assign rdaddr                                  = data_out_0[(0+B_DW+`AXI_RESPW)+:B_AW];
  assign rdlast                                  = data_out_0[(0+B_DW+`AXI_RESPW+B_AW)+:1];
  
  assign data_ars3_0[0+:B_AW]                    = addr_ars3_0;
  assign data_ars3_0[(0+B_AW)+:`AXI_LENW]        = len_ars3_0;
  assign araddr                                  = data_arout_0[0+:B_AW];
  assign arlen                                   = data_arout_0[(0+B_AW)+:`AXI_LENW];
  
  assign data_rin_0[0+:B_DW]                     = rdata;
  assign data_rin_0[(0+B_DW)+:`AXI_RESPW]        = rresp;
  assign data_rin_0[(0+B_DW+`AXI_RESPW)+:1]      = rlast;
  assign data_rs0_1                              = data_rs0_0[0+:B_DW];
  assign resp_rs0_0                              = data_rs0_0[(0+B_DW)+:`AXI_RESPW];
  assign last_rs0_0                              = data_rs0_0[(0+B_DW+`AXI_RESPW)+:1];
  
  assign data_s3_0[0+:B_AW]                      = raddr_s3_0;
  assign data_s3_0[(0+B_AW)+:1]                  = explast_s3_0;
  assign raddr_rs0_0                             = data_rs0_2[0+:B_AW];
  assign explast_rs0_0                           = data_rs0_2[(0+B_AW)+:1];
  
  assign rdy_s0_0                                = !nf_ars3_0 && !nf_s3_0;  
  assign vld_s0_1                                = vld_s0_0 && rdy_s0_0;  
  assign adv_s1_0                                = !clr_s1_0 && vld_s2_0;
  assign clr_s1_0                                = addrfin_s2_0 && vld_s2_0;  
  assign addrfin_s2_0                            = (cntr_s2_0==(MAX_BURST-1)) || ((addr_s2_0+B_BEW)!=addr_s1_0) || (!vld_s1_0);
  assign basevld_s2_0                            = (cntr_s2_0==0) && vld_s2_0;      
  assign vld_ars3_0                              = addrfin_s3_0 && vld_s3_0;
  assign addr_ars3_0                             = base_s3_0;
  assign len_ars3_0                              = {{(`AXI_LENW-CNTRW){1'd0}},cntr_s3_0};
  assign explast_s3_0                            = addrfin_s3_0;
  
  assign vld_rs0_2                               = vld_rs0_0 && vld_rs0_1 && !nf_rs1_0;
  assign rdy_rs0_0                               = vld_rs0_2;
  assign rdy_rs0_1                               = vld_rs0_2;  
  
  // Pipeline
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))   raddr_s0_s1_0_inst (.d(data_s0_1[0+:B_AW]),.q(raddr_s1_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))   raddr_s1_s2_0_inst (.d(raddr_s1_0),        .q(raddr_s2_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))   raddr_s2_s3_0_inst (.d(raddr_s2_0),        .q(raddr_s3_0),  .clk(clk),.rst(1'd0));   
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))    addr_s0_s1_0_inst (.d(addr_s0_0),         .q(addr_s1_0),   .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_AW),         .EAR(EAR))    addr_s1_s2_0_inst (.d(addr_s1_0),         .q(addr_s2_0),   .clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(B_AW),.EVLD(1),.EAR(EAR))    base_s2_s3_0_inst (.d(addr_s2_0),         .q(base_s3_0),   .clk(clk),.rst(1'd0),.vld(basevld_s2_0));    
  powlib_flipflop #(.W(1),            .EAR(EAR))     vld_s0_s1_0_inst (.d(vld_s0_1),          .q(vld_s1_0),    .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),            .EAR(EAR))     vld_s1_s2_0_inst (.d(vld_s1_0),          .q(vld_s2_0),    .clk(clk),.rst(rst));
  powlib_flipflop #(.W(1),            .EAR(EAR))     vld_s2_s3_0_inst (.d(vld_s2_0),          .q(vld_s3_0),    .clk(clk),.rst(rst)); 
  powlib_flipflop #(.W(CNTRW),        .EAR(EAR))    cntr_s2_s3_0_inst (.d(cntr_s2_0),         .q(cntr_s3_0),   .clk(clk),.rst(1'd0));  
  powlib_flipflop #(.W(1),            .EAR(EAR)) addrfin_s2_s3_0_inst (.d(addrfin_s2_0),      .q(addrfin_s3_0),.clk(clk),.rst(1'd0));

  powlib_flipflop #(.W(B_DW),         .EAR(EAR))  data_rs0_rs1_0_inst (.d(data_rs0_1),        .q(data_rs1_1),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(B_AW),         .EAR(EAR)) raddr_rs0_rs1_0_inst (.d(raddr_rs0_0),       .q(raddr_rs1_0), .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(`AXI_RESPW),   .EAR(EAR))  resp_rs0_rs1_0_inst (.d(resp_rs0_0),        .q(resp_rs1_0),  .clk(clk),.rst(1'd0));
  powlib_flipflop #(.W(1),            .EAR(EAR))  last_rs0_rs1_0_inst (.d(last_rs0_0),        .q(last_rs1_0),  .clk(clk),.rst(1'd0)); 
  powlib_flipflop #(.W(1),            .EAR(EAR))   vld_rs0_rs1_0_inst (.d(vld_rs0_2),         .q(vld_rs1_0),   .clk(clk),.rst(rst));
  
  // Counters
  powlib_cntr #(.W(CNTRW),.EAR(EAR),.ELD(0)) cntr_s1_s2_0_inst (
    .cntr(cntr_s2_0),.adv(adv_s1_0),.clr(clr_s1_0),
    .clk(clk),.rst(rst));
  
  // FIFOs
  powlib_swissfifo #(.W(B_AW+B_DW),.NFS(IN_NFS),.D(IN_D),.S(IN_S),
    .ID({ID,"_INFIFO"}),.EDBG(EDBG),.EAR(EAR)) 
  fifo_in_s0_0_inst (
    .wrdata(data_in_0),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),
    .rddata(data_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst)); 

  powlib_swissfifo #(.W(1+B_AW+`AXI_RESPW+B_DW),.NFS(1),.D(8),
    .ID({ID,"_OUTFIFO"}),.EDBG(EDBG),.EAR(EAR)) 
  fifo_s3_out_0_inst (
    .wrdata(data_rs1_0),.wrvld(vld_rs1_0),.wrrdy(rdy_rs1_0),.wrnf(nf_rs1_0),
    .rddata(data_out_0),.rdvld(rdvld),.rdrdy(rdrdy),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst)); 

  powlib_swissfifo #(.W(`AXI_LENW+B_AW),.NFS(3),.D(8),
    .ID({ID,"_ARFIFO"}),.EDBG(EDBG),.EAR(EAR))
  fifo_ars3_out_inst (
    .wrdata(data_ars3_0),.wrvld(vld_ars3_0),.wrrdy(rdy_ars3_0),.wrnf(nf_ars3_0),
    .rddata(data_arout_0),.rdvld(arvalid),.rdrdy(arready),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));    
                        
  powlib_swissfifo #(.W(1+`AXI_RESPW+B_DW),.NFS(0),.D(8),
    .ID({ID,"_RFIFO"}),.EDBG(EDBG),.EAR(EAR))
  fifo_rin_rs0_inst (
    .wrdata(data_rin_0),.wrvld(rvalid),.wrrdy(rready),
    .rddata(data_rs0_0),.rdvld(vld_rs0_0),.rdrdy(rdy_rs0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));  

  powlib_swissfifo #(.W(1+B_AW),.NFS(3),.D(MAX_BURST+8),
    .ID({ID,"_RAFIFO"}),.EDBG(EDBG),.EAR(EAR))
  fifo_s3_rs0_inst (
    .wrdata(data_s3_0),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0), 
    .rddata(data_rs0_2),.rdvld(vld_rs0_1),.rdrdy(rdy_rs0_1), 
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));      
            
  always @(posedge clk) begin
    if (vld_rs0_2 && (explast_rs0_0!=last_rs0_0)) begin
      $display("ID: %s, The expected last doesn't match the actual last.", ID);
      $finish;
    end
  end
  
  initial begin
    if ((1<<CL2MAX_BURST)!=MAX_BURST) begin
      $display("ID: %s, MAX_BURST: %d, MAX_BURST is not a power of 2.", ID, MAX_BURST);
      $finish;
    end
  end
            
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
  localparam                    CNTRW        = (CL2MAX_BURST==0) ? 1 : CL2MAX_BURST;
      
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
         wire [CNTRW-1:0]            cntr_s2_0, cntr_s3_0;
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
  assign len_aws3_0                       = {{(`AXI_LENW-CNTRW){1'd0}},cntr_s3_0};  
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
  powlib_flipflop #(.W(CNTRW),        .EAR(EAR))    cntr_s2_s3_0_inst (.d(cntr_s2_0),   .q(cntr_s3_0),   .clk(clk),.rst(1'd0));  
  powlib_flipflop #(.W(1),            .EAR(EAR)) addrfin_s2_s3_0_inst (.d(addrfin_s2_0),.q(addrfin_s3_0),.clk(clk),.rst(rst));
  
  // Counters
  powlib_cntr #(.W(CNTRW),.EAR(EAR),.ELD(0)) cntr_s1_s2_0_inst (
    .cntr(cntr_s2_0),.adv(adv_s1_0),.clr(clr_s1_0),
    .clk(clk),.rst(rst));

  // FIFOs
  powlib_swissfifo #(.W(B_BEW+B_AW+B_DW),.NFS(IN_NFS),.D(IN_D),.S(IN_S),
    .ID({ID,"_INFIFO"}),.EDBG(EDBG),.EAR(EAR)) 
  fifo_in_s0_0_inst (
    .wrdata(data_in_0),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),
    .rddata(data_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(.W(`AXI_LENW+B_AW),.NFS(3),.D(8),
    .ID({ID,"_AWFIFO"}),.EDBG(EDBG),.EAR(EAR))
  fifo_aws3_out_inst (
    .wrdata(data_aws3_0),.wrvld(vld_aws3_0),.wrrdy(rdy_aws3_0),.wrnf(nf_aws3_0),
    .rddata(data_awout_0),.rdvld(awvalid),.rdrdy(awready),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));
    
  powlib_swissfifo #(.W(1+B_BEW+B_DW),.NFS(3),.D(MAX_BURST+8),
    .ID({ID,"_WFIFO"}),.EDBG(EDBG),.EAR(EAR))
  fifo_ws3_out_inst (
    .wrdata(data_ws3_1),.wrvld(vld_ws3_0),.wrrdy(rdy_ws3_0),.wrnf(nf_ws3_0),
    .rddata(data_wout_0),.rdvld(wvalid),.rdrdy(wready),
    .wrclk(clk),.wrrst(rst),.rdclk(clk),.rdrst(rst));  
    
  initial begin
      if ((1<<CL2MAX_BURST)!=MAX_BURST) begin
        $display("ID: %s, MAX_BURST: %d, MAX_BURST is not a power of 2.", ID, MAX_BURST);
        $finish;
    end
  end
  
endmodule                        
