`timescale 1ns / 1ps

module powlib_downfifo(wrdata,wrvld,wrrdy,wrnf,rddata,rdvld,rdrdy,wrclk,wrrst,rdclk,rdrst);

`include "powlib_std.vh"

  parameter                  W      = 16;         // Reading Data Width
  parameter                  MULT   = 2;          // Writing Data Multipler
  parameter                  NFS    = 0;          // Nearly full stages
  parameter                  D      = 12;         // Total depth
  parameter                  S      = 0;          // Pipeline Stages
  parameter                  EASYNC = 0;          // Enable asynchronous FIFO
  parameter                  DD     = 8;          // Default Depth for asynchronous FIFO
  parameter                  EAR    = 0;          // Enable asynchronous reset  
  parameter                  ID     = "DOWNFIFO"; // String identifier
  parameter                  EDBG   = 0;          // Enable debug  
  localparam                 WR_W   = W*MULT;     // Writing Data Width
  localparam                 PTR_W  = powlib_clogb2(WR_W);

  input      wire             wrclk;               // Write Clock
  input      wire             wrrst;               // Write Reset
  input      wire             rdclk;               // Read Clock
  input      wire             rdrst;               // Read Reset
  input      wire [WR_W-1:0]  wrdata;              // Write Interface: Data
  input      wire             wrvld;               //                  Valid data is available
  output     wire             wrrdy;               //                  Ready for data
  output     wire             wrnf;                //                  Nearly full
  output     wire [W-1:0]     rddata;              // Read Interface:  Data
  output     wire             rdvld;               //                  Valid data is available
  input      wire             rdrdy;               //                  Read for data   

             wire [WR_W-1:0]  data_s0_0, data_s1_0;
             wire [W-1:0]     data_s1_1 [0:MULT-1];
             reg  [W-1:0]     data_s2_0;
             wire [W-1:0]     data_s3_0;
             
             wire             vld_s0_0, vld_s0_1, vld_s1_0, 
                              vld_s1_1, vld_s2_0, vld_s3_0;
             wire             rdy_s0_0, rdy_s3_0;
             
             wire             nf_s3_0;             
             wire [PTR_W-1:0] ptr_s1_0;
             wire             adv_s0_0;
             wire             clr_s0_0;
             
             genvar           i;
  
  powlib_swissfifo #(.W(WR_W),.NFS(NFS),.D(D),.S(S),
    .EASYNC(EASYNC),.DD(DD),.EAR(EAR),
    .ID({ID,"_WR_FIFO"}),.EDBG(EDBG))
  fifo_wr_s0_inst (
    .wrdata(wrdata),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),.wrclk(wrclk),.wrrst(wrrst),
    .rddata(data_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),.rdclk(rdclk),.rdrst(rdrst));
  
  assign rdy_s0_0 = !nf_s3_0 && (!adv_s0_0 || clr_s0_0);
  assign vld_s0_1 = vld_s0_0 && rdy_s0_0;
  assign adv_s0_0 = vld_s1_0 || (ptr_s1_0!=0);
  assign clr_s0_0 = ptr_s1_0 == (MULT-1);
  powlib_flipflop #(.W(WR_W), .EAR(EAR),.EVLD(1)) data_s0_s1_0_inst (.d(data_s0_0),.q(data_s1_0),.vld(vld_s0_1),   .clk(rdclk),.rst(1'd0));
  powlib_flipflop #(.W(1),    .EAR(EAR))           vld_s0_s1_0_inst (.d(vld_s0_1), .q(vld_s1_0),                   .clk(rdclk),.rst(rdrst));  
  powlib_cntr     #(.W(PTR_W),.EAR(EAR),.ELD(0))  cntr_s0_s1_0_inst (.cntr(ptr_s1_0),.adv(adv_s0_0),.clr(clr_s0_0),.clk(rdclk),.rst(rdrst));

  for (i=0; i<MULT; i=i+1) assign data_s1_1[i] = data_s1_0[i*W+:W];
  assign vld_s1_1 = adv_s0_0;
  always @(posedge rdclk) data_s2_0 <= data_s1_1[ptr_s1_0];
  powlib_flipflop #(.W(1),    .EAR(EAR))           vld_s1_s2_0_inst (.d(vld_s1_1), .q(vld_s2_0),                   .clk(rdclk),.rst(rdrst));
  
  powlib_flipflop #(.W(W),    .EAR(EAR))          data_s2_s3_0_inst (.d(data_s2_0),.q(data_s3_0),                  .clk(rdclk),.rst(1'd0));
  powlib_flipflop #(.W(1),    .EAR(EAR))           vld_s2_s3_0_inst (.d(vld_s2_0), .q(vld_s3_0),                   .clk(rdclk),.rst(rdrst));   

  powlib_swissfifo #(.W(W),.NFS(3+(MULT-1)),.D(10+(MULT-1)),
    .EASYNC(0),.EAR(EAR),.ID({ID,"_RD_FIFO"}),.EDBG(EDBG))
  fifo_s3_rd_inst (
    .wrdata(data_s3_0),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0),.wrclk(rdclk),.wrrst(rdrst),
    .rddata(rddata),.rdvld(rdvld),.rdrdy(rdrdy),.rdclk(rdclk),.rdrst(rdrst));   
  
endmodule

module powlib_upfifo(wrdata,wrvld,wrrdy,wrnf,rddata,rdvld,rdrdy,wrclk,wrrst,rdclk,rdrst);

  /* --------------------------------------------------------------------------------------- 
   * Up Fifo
   * Vectorizes input words. Specifically, if MULT input words of width W are clocked into the 
   * Up Fifo's writing interface, a single output word of width W*MULT is returned from the Up
   * Fifo's reading interface. The output word is a concatenation of the MULT input words, where
   * the earliest input word is the least significant word in the output word.
   *
   * Due to the nature of how the FIFO is architectured, it's advisable to register the outputs.   
   * --------------------------------------------------------------------------------------- */

`include "powlib_std.vh"

  parameter                  W      = 16;         // Writing Data Width
  parameter                  MULT   = 2;          // Reading Data Multipler
  parameter                  NFS    = 0;          // Nearly full stages
  parameter                  D      = 8;          // Total depth
  parameter                  S      = 0;          // Pipeline Stages
  parameter                  EASYNC = 0;          // Enable asynchronous FIFO
  parameter                  DD     = 4;          // Default Depth for asynchronous FIFO
  parameter                  EAR    = 0;          // Enable asynchronous reset  
  parameter                  ID     = "UPFIFO";   // String identifier
  parameter                  EDBG   = 0;          // Enable debug  
  localparam                 RD_W   = W*MULT;     // Reading Data Width
  localparam                 PTR_W  = powlib_clogb2(RD_W);
  
  input      wire             wrclk;               // Write Clock
  input      wire             wrrst;               // Write Reset
  input      wire             rdclk;               // Read Clock
  input      wire             rdrst;               // Read Reset
  input      wire [W-1:0]     wrdata;              // Write Interface: Data
  input      wire             wrvld;               //                  Valid data is available
  output     wire             wrrdy;               //                  Ready for data
  output     wire             wrnf;                //                  Nearly full
  output     wire [RD_W-1:0]  rddata;              // Read Interface:  Data
  output     wire             rdvld;               //                  Valid data is available
  input      wire             rdrdy;               //                  Read for data   
  
             wire [W-1:0]     data_s0_0, data_s1_0;
             reg  [W-1:0]     datas_s2_0 [0:MULT-1];
             wire [RD_W-1:0]  datas_s2_1, datas_s3_0;
			 
             wire             vld_s0_0, vld_s0_1, 
                              vld_s1_0, vld_s1_1,
                              vld_s2_0, vld_s3_0;
							 
             wire             rdy_s0_0, rdy_s3_0, nf_s3_0;
			 
			       wire [PTR_W-1:0] ptr_s2_0;
			       wire             adv_s1_0, clr_s1_0;
			 
             genvar           i;
  
  powlib_swissfifo #(.W(W),.NFS(NFS),.D(D),.S(S),
    .EASYNC(0),.DD(DD),.EAR(EAR),
    .ID({ID,"_WR_FIFO"}),.EDBG(EDBG))
  fifo_wr_s0_inst (
    .wrdata(wrdata),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),.wrclk(wrclk),.wrrst(wrrst),
    .rddata(data_s0_0),.rdvld(vld_s0_0),.rdrdy(rdy_s0_0),.rdclk(wrclk),.rdrst(wrrst));
	
  assign rdy_s0_0 = !nf_s3_0;
  assign vld_s0_1 = vld_s0_0 && rdy_s0_0;
  powlib_flipflop #(.W(W),    .EAR(EAR))         data_s0_s1_inst  (.d(data_s0_0), .q(data_s1_0),                .clk(wrclk),.rst(1'd0));
  powlib_flipflop #(.W(1),    .EAR(EAR))          vld_s0_s1_inst  (.d(vld_s0_1),  .q(vld_s1_0),                 .clk(wrclk),.rst(wrrst));
  
  assign vld_s1_1 = (ptr_s2_0==(MULT-1)) && vld_s1_0;
  assign adv_s1_0 = vld_s1_0;
  assign clr_s1_0 = vld_s1_1;
  always @(posedge wrclk) datas_s2_0[ptr_s2_0] <= data_s1_0;  
  powlib_flipflop #(.W(1),    .EAR(EAR))          vld_s1_s2_inst  (.d(vld_s1_1),  .q(vld_s2_0),                 .clk(wrclk),.rst(wrrst));
  powlib_cntr     #(.W(PTR_W),.EAR(EAR),.ELD(0)) cntr_s1_s2_inst (.cntr(ptr_s2_0),.adv(adv_s1_0),.clr(clr_s1_0),.clk(wrclk),.rst(wrrst));
  
  for (i=0; i<MULT; i=i+1) assign datas_s2_1[i*W+:W] = datas_s2_0[i];
  powlib_flipflop #(.W(RD_W),.EAR(EAR))          data_s2_s3_inst  (.d(datas_s2_1),.q(datas_s3_0),               .clk(wrclk),.rst(1'd0));
  powlib_flipflop #(.W(1),   .EAR(EAR))          vld_s2_s3_inst   (.d(vld_s2_0),  .q(vld_s3_0),                 .clk(wrclk),.rst(wrrst));
  
  powlib_swissfifo #(.W(RD_W),.NFS(3),.D(10),
    .EASYNC(EASYNC),.EAR(EAR),
    .ID({ID,"_RD_FIFO"}),.EDBG(EDBG))
  fifo_s3_rd_inst (
    .wrdata(datas_s3_0),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrnf(nf_s3_0),.wrclk(wrclk),.wrrst(wrrst),
    .rddata(rddata),.rdvld(rdvld),.rdrdy(rdrdy),.rdclk(rdclk),.rdrst(rdrst));  

endmodule

module powlib_swissfifo(wrdata,wrvld,wrrdy,wrnf,rddata,rdvld,rdrdy,wrclk,wrrst,rdclk,rdrst);

  /* --------------------------------------------------------------------------------------- 
   * Swiss Fifo
   * Depending on how this module is constrained, a combination of a pipe, synchronous FIFO,
   * or asynchronous FIFO is implemented.
   *
   * Due to the nature of how the FIFO
   * is architectured, it's advisable
   * to register the outputs.   
   * --------------------------------------------------------------------------------------- */

  parameter               W      = 16;         // Width
  parameter               NFS    = 0;          // Nearly full stages
  parameter               D      = 8;          // Total depth
  parameter               S      = 0;          // Pipeline Stages
  parameter               EASYNC = 0;          // Enable asynchronous FIFO
  parameter               DD     = 4;          // Default Depth for asynchronous FIFO
  parameter               EAR    = 0;          // Enable asynchronous reset  
  parameter               ID     = "SWISSFIFO";// String identifier
  parameter               EDBG   = 0;          // Enable debug
  input      wire         wrclk;               // Write Clock
  input      wire         wrrst;               // Write Reset
  input      wire         rdclk;               // Read Clock
  input      wire         rdrst;               // Read Reset
  input      wire [W-1:0] wrdata;              // Write Interface: Data
  input      wire         wrvld;               //                  Valid data is available
  output     wire         wrrdy;               //                  Ready for data
  output     wire         wrnf;                //                  Nearly full
  output     wire [W-1:0] rddata;              // Read Interface:  Data
  output     wire         rdvld;               //                  Valid data is available
  input      wire         rdrdy;               //                  Read for data  

             wire [W-1:0] data_s0_0, data_s1_0, 
                          data_s2_0, data_s3_0,
                          data_s4_0;
             wire         vld_s0_0, vld_s1_0, vld_s1_1,
                          vld_s2_0, vld_s3_0, vld_s4_0,
                          rdy_s0_0, rdy_s1_0, rdy_s2_0,
                          rdy_s3_0, rdy_s4_0,
                          nf_s0_0, nf_s2_0;


  if (S!=0 && EASYNC!=0) begin

    localparam LD        = D-( 2*(S+1)+DD );
    assign     data_s0_0 = wrdata;
    assign     vld_s0_0  = wrvld;
    assign     wrrdy     = rdy_s0_0;
    assign     wrnf      = nf_s0_0;
    assign     rdy_s1_0  = ~nf_s2_0;
    assign     vld_s1_1  = vld_s1_0 & rdy_s1_0; 
    assign     rddata    = data_s4_0;
    assign     rdvld     = vld_s4_0;
    assign     rdy_s4_0  = rdrdy;
  
    powlib_sfifo #(.W(W),.D(S+1),.NFS(NFS),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_SFIFO_0"})) sfifo_0_inst (
      .wrdata(data_s0_0),.wrvld(vld_s0_0),.wrrdy(rdy_s0_0),.wrnf(nf_s0_0),
      .rddata(data_s1_0),.rdvld(vld_s1_0),.rdrdy(rdy_s1_0), 
      .clk(wrclk),.rst(wrrst));
  
    powlib_pipe #(.W(W),.EAR(EAR),.S(S)) datapipe_inst (
      .d(data_s1_0),.q(data_s2_0),.clk(wrclk),.rst(0));
  
    powlib_pipe #(.W(1),.EAR(EAR),.S(S)) vldpipe_inst (
      .d(vld_s1_1),.q(vld_s2_0),.clk(wrclk),.rst(wrrst));  
  
    powlib_sfifo #(.W(W),.D(LD+S+1),.NFS(S),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_SFIFO_1"})) sfifo_1_inst (
      .wrdata(data_s2_0),.wrvld(vld_s2_0),.wrrdy(rdy_s2_0),.wrnf(nf_s2_0),
      .rddata(data_s3_0),.rdvld(vld_s3_0),.rdrdy(rdy_s3_0), 
      .clk(wrclk),.rst(wrrst));  
  
    powlib_afifo #(.W(W),.D(DD),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_AFIFO"})) afifo_inst (
      .wrdata(data_s3_0),.wrvld(vld_s3_0),.wrrdy(rdy_s3_0),.wrclk(wrclk),.wrrst(wrrst),
      .rddata(data_s4_0),.rdvld(vld_s4_0),.rdrdy(rdy_s4_0),.rdclk(rdclk),.rdrst(rdrst));

    initial begin
      if ( ( 2*(S+1)+DD )>=D ) begin
        $display("ID: %s, D: %d, S: %d, DD: %d, EASYNC: %d, D should be greater than ( 2*(S+1)+DD ).", ID, D, S, DD, EASYNC);
        $finish;
      end
    end
 
  end

  if (S!=0 && EASYNC==0) begin
    
    localparam LD        = D-( 2*(S+1) );
    assign     data_s0_0 = wrdata;
    assign     vld_s0_0  = wrvld;
    assign     wrrdy     = rdy_s0_0;
    assign     wrnf      = nf_s0_0;
    assign     rdy_s1_0  = ~nf_s2_0;
    assign     vld_s1_1  = vld_s1_0 & rdy_s1_0; 
    assign     rddata    = data_s3_0;
    assign     rdvld     = vld_s3_0;
    assign     rdy_s3_0  = rdrdy;
  
    powlib_sfifo #(.W(W),.D(S+1),.NFS(NFS),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_SFIFO_0"})) sfifo_0_inst (
      .wrdata(data_s0_0),.wrvld(vld_s0_0),.wrrdy(rdy_s0_0),.wrnf(nf_s0_0),
      .rddata(data_s1_0),.rdvld(vld_s1_0),.rdrdy(rdy_s1_0), 
      .clk(wrclk),.rst(wrrst));
  
    powlib_pipe #(.W(W),.EAR(EAR),.S(S)) datapipe_inst (
      .d(data_s1_0),.q(data_s2_0),.clk(wrclk),.rst(0));
  
    powlib_pipe #(.W(1),.EAR(EAR),.S(S)) vldpipe_inst (
      .d(vld_s1_1),.q(vld_s2_0),.clk(wrclk),.rst(wrrst));  
  
    powlib_sfifo #(.W(W),.D(LD+S+1),.NFS(S),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_SFIFO_1"})) sfifo_1_inst (
      .wrdata(data_s2_0),.wrvld(vld_s2_0),.wrrdy(rdy_s2_0),.wrnf(nf_s2_0),
      .rddata(data_s3_0),.rdvld(vld_s3_0),.rdrdy(rdy_s3_0), 
      .clk(wrclk),.rst(wrrst));  

    initial begin
      if ( ( 2*(S+1) )>=D ) begin
        $display("ID: %s, D: %d, S: %d, DD: %d, EASYNC: %d, D should be greater than ( 2*(S+1) ).", ID, D, S, DD, EASYNC);
        $finish;
      end    
    end

  end

  if (S==0 && EASYNC!=0) begin

    localparam LD        = D-( DD );
    assign     data_s0_0 = wrdata;
    assign     vld_s0_0  = wrvld;
    assign     wrrdy     = rdy_s0_0;
    assign     wrnf      = nf_s0_0;
    assign     rddata    = data_s2_0;
    assign     rdvld     = vld_s2_0;
    assign     rdy_s2_0  = rdrdy;
  
    powlib_sfifo #(.W(W),.D(LD),.NFS(NFS),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_SFIFO"})) sfifo_inst (
      .wrdata(data_s0_0),.wrvld(vld_s0_0),.wrrdy(rdy_s0_0),.wrnf(nf_s0_0),
      .rddata(data_s1_0),.rdvld(vld_s1_0),.rdrdy(rdy_s1_0), 
      .clk(wrclk),.rst(wrrst));
  
    powlib_afifo #(.W(W),.D(DD),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_AFIFO"})) afifo_inst (
      .wrdata(data_s1_0),.wrvld(vld_s1_0),.wrrdy(rdy_s1_0),.wrclk(wrclk),.wrrst(wrrst),
      .rddata(data_s2_0),.rdvld(vld_s2_0),.rdrdy(rdy_s2_0),.rdclk(rdclk),.rdrst(rdrst));

    initial begin
      if ( ( DD )>=D ) begin
        $display("ID: %s, D: %d, S: %d, DD: %d, EASYNC: %d, D should be greater than ( DD ).", ID, D, S, DD, EASYNC);
        $finish;
      end    
    end    

  end

  if (S==0 && EASYNC==0) begin

    assign data_s0_0 = wrdata;
    assign vld_s0_0  = wrvld;
    assign wrrdy     = rdy_s0_0;
    assign wrnf      = nf_s0_0;
    assign rddata    = data_s1_0;
    assign rdvld     = vld_s1_0;
    assign rdy_s1_0  = rdrdy;
  
    powlib_sfifo #(.W(W),.D(D),.NFS(NFS),.EAR(EAR),.EDBG(EDBG),.ID({ID,"_SFIFO"})) sfifo_inst (
      .wrdata(data_s0_0),.wrvld(vld_s0_0),.wrrdy(rdy_s0_0),.wrnf(nf_s0_0),
      .rddata(data_s1_0),.rdvld(vld_s1_0),.rdrdy(rdy_s1_0), 
      .clk(wrclk),.rst(wrrst));

  end

endmodule

module powlib_sfifo(wrdata,wrvld,wrrdy,wrnf,rddata,rdvld,rdrdy,clk,rst);

  /* --------------------------------- 
   * Synchronous FIFO
   * Due to the nature of how the FIFO
   * is architectured, it's advisable
   * to register the outputs.   
   * --------------------------------- */

`include "powlib_std.vh"

  parameter                     W     = 16;      // Width
  parameter                     D     = 8;       // Depth
  parameter                     NFS   = 0;       // Nearly full stages
  parameter                     EAR   = 0;       // Enable asynchronous reset
  parameter                     EDBG  = 0;       // Enable debug statements
  parameter                     ID    = "SFIFO"; // String identifier
  localparam                    WPTR  = powlib_clogb2(D);
  localparam         [WPTR-1:0] NFT   = D-NFS-1; // Nearly full threshold  
  input      wire               clk;             // Clock
  input      wire               rst;             // Reset
  input      wire    [W-1:0]    wrdata;          // Write Interface: Data
  input      wire               wrvld;           //                  Valid data is available
  output     wire               wrrdy;           //                  Ready for data
  output     wire               wrnf;            //                  Nearly full
  output     wire    [W-1:0]    rddata;          // Read Interface:  Data
  output     wire               rdvld;           //                  Valid data is available
  input      wire               rdrdy;           //                  Read for data
    
             wire    [WPTR-1:0] wrptr, rdptr, rdptrm1;      
             
  assign                        wrrdy = wrptr!=rdptrm1;
             wire               wrinc = wrvld && wrrdy; 
             wire               wrclr = (wrptr==(D-1)) && wrinc;    
             
  assign                        rdvld = rdptr!=wrptr;
             wire               rdinc = rdvld && rdrdy;    
             wire               rdclr = (rdptr==(D-1)) && rdinc;   

             wire    [WPTR-1:0] amtcurr;
             wire               amtop = wrinc || rdinc;      
             wire    [WPTR-1:0] amtdx = (wrinc!=0 && rdinc==0) ?  1 : 
                                        (wrinc==0 && rdinc!=0) ? -1 : 0;
  assign                        wrnf  = amtcurr>=NFT;                     
  
  powlib_cntr     #(.W(WPTR),.ELD(0),.EAR(EAR))                 wrcntr_inst  (.cntr(wrptr),.adv(wrinc),.clr(wrclr),.clk(clk),.rst(rst));
  powlib_cntr     #(.W(WPTR),.ELD(0),.EAR(EAR))                 rdcntr_inst  (.cntr(rdptr),.adv(rdinc),.clr(rdclr),.clk(clk),.rst(rst));
  powlib_flipflop #(.W(WPTR),.INIT(D-1),.EVLD(1),.EAR(EAR))     rdptrm1_inst (.d(rdptr),.q(rdptrm1),.clk(clk),.rst(rst),.vld(rdinc));
  powlib_cntr     #(.W(WPTR),.ELD(0),.EAR(EAR),.EDX(1))         nfcntr_inst  (.cntr(amtcurr),.adv(amtop),.dx(amtdx),.clr(1'b0),.clk(clk),.rst(rst));
  
  powlib_dpram    #(.W(W),.D(D),.EDBG(EDBG),.ID({ID,"_DPRAM"})) ram_inst     (.wridx(wrptr),.wrdata(wrdata),.wrvld(wrinc),.rdidx(rdptr),.rddata(rddata),.clk(clk));

  initial begin
    if ((NFS+1)>D) begin
      $display("ID: %s, NFS: %d, D: %d, NFS+1 should not be greater than D.", ID, NFS, D);
      $finish;
    end
    if (D<2) begin
      $display("ID: %s, D: %d, D should be at least 2.", ID, D);
      $finish;
    end
  end

endmodule

module powlib_afifo(wrdata,wrvld,wrrdy,rddata,rdvld,rdrdy,wrclk,wrrst,rdclk,rdrst);

  /* --------------------------------- 
   * Asynchronous FIFO
   * Due to the nature of how the FIFO
   * is architectured, it's advisable
   * to register the outputs.
   * --------------------------------- */

`include "powlib_std.vh"

  parameter                  W    = 16;       // Width
  parameter                  D    = 8;        // Depth
  parameter                  EAR  = 0;        // Enable asynchronous reset
  parameter                  EDBG = 0;        // Enable debug statements
  parameter                  ID   = "AFIFO";  // String identifier
  localparam                 WPTR =  powlib_clogb2(D);
  input      wire [W-1:0]    wrdata;          // Write Interface: Data
  input      wire            wrvld;           //                  Valid data is available
  output     wire            wrrdy;           //                  Ready for data
  output     wire [W-1:0]    rddata;          // Read Interface:  Data
  output     wire            rdvld;           //                  Valid data is available
  input      wire            rdrdy;           //                  Ready for data
  input      wire            wrclk;           // Write Clock
  input      wire            wrrst;           // Write Reset
  input      wire            rdclk;           // Read Clock
  input      wire            rdrst;           // Read Reset
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
    end
    if (D<2) begin
      $display("ID: %s, D: %d, D should be at least 2.", ID, D);
      $finish;
    end    
  end
  
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
    .cntr(wrptr0),.adv(wrinc0),.clr(1'd0),.clk(wrclk),.rst(wrrst));
  
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
    .cntr(rdptr0),.adv(rdinc0),.clr(1'd0),.clk(rdclk),.rst(rdrst));
  
endmodule

