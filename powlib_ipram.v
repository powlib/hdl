
module powlib_ipram(wraddr,wrdata,wrvld,wrrdy,wrnf,rdaddr,rddata,rdvld,rdrdy,clk,rst);

  /* --------------------------------- 
   * IP RAM.   
   * --------------------------------- */

`include "powlib_std.vh"
`include "powlib_ip.vh"
  
  parameter                  ID       = "IPRAM";              // String Identifier  
  parameter                  EAR      = 0;                    // Enable Asynchronous Reset  
  parameter                  EDBG     = 0;                    // Enable Debug
  parameter                  IN_NFS   = 0;                    // Input FIFO Nearly Full Stages
  parameter                  IN_D     = 8;                    // Input FIFO Depth
  parameter                  IN_S     = 0;                    // Input FIFO Pipeline Stages
  parameter                  B_SIZE   = 8'hFF;                // Bus Size (size in bytes-1)
  parameter                  B_BPD    = 4;                    // Bus Bytes Per Data (must be a power of 2)
  parameter                  B_AW     = `POWLIB_BW*B_BPD;     // Bus Address Width (must be equal to or greater than B_AW)
  localparam                 B_DW     = `POWLIB_BW*B_BPD;     // Bus Data Width
  localparam                 B_BEW    = B_BPD;                // Bus Byte Enable Width
  localparam                 B_OPW    = `POWLIB_OPW;          // Bus Operation Width
  localparam                 B_WW     = B_OPW+B_BEW+B_DW;     // Bus Packed Data Width
  localparam                 RAM_D    = (B_SIZE+1)/B_BPD;     // RAM Depth
  localparam                 RAM_WIDX = powlib_clogb2(RAM_D); // RAM Writing/Reading Index Width
  localparam                 RAM_LB   = powlib_clogb2(B_BPD);

  input  wire                clk;                             // Clock
  input  wire                rst;                             // Active-High Reset
      
  input  wire [B_AW-1:0]     wraddr;                          // Write Address
  input  wire [B_WW-1:0]     wrdata;                          // Write Data
  input  wire                wrvld;                           // Write Valid
  output wire                wrrdy;                           // Write Ready
  output wire                wrnf;                            // Write Nearly-Full
      
  output wire [B_AW-1:0]     rdaddr;                          // Read Address
  output wire [B_WW-1:0]     rddata;                          // Read Data
  output wire                rdvld;                           // Read Valid
  input  wire                rdrdy;                           // Read Ready
      
         wire [B_DW-1:0]     wrdata_s0_0;
         wire [B_DW-1:0]     rddata_s1_0;
         wire [B_DW-1:0]     wrbe_s0_0;
         wire [RAM_WIDX-1:0] wridx_s0_0;
         wire [RAM_WIDX-1:0] rdidx_s0_0;
         
         wire [B_WW-1:0]     data_in_0;
         wire [B_AW-1:0]     addr_in_0;   
             
         wire [B_AW-1:0]     addr_s0_0;
         wire [B_WW-1:0]     data_s0_0;
         wire [B_DW-1:0]     data_s0_1;
         wire [B_BEW-1:0]    be_s0_0;
         wire [B_OPW-1:0]    op_s0_0;
         
         wire [B_AW-1:0]     addr_s1_0;
         wire [B_DW-1:0]     data_s1_0;
         
         wire [B_AW-1:0]     addr_s2_0;
         wire [B_DW-1:0]     data_s2_0;
         wire [B_WW-1:0]     data_s2_1;

         genvar              i;

  // DPRAM instantiation.
  for (i=0; i<B_BPD; i=i+1) begin
    localparam [powlib_itoaw(i)-1:0] IDX_STR = powlib_itoa(i);  
    wire be_s0_1 = (vld_s0_0)&&(op_s0_0==`POWLIB_OP_WRITE)&&(be_s0_0[i]);
    powlib_dpram         #(.W(`POWLIB_BW),.D(RAM_D),.EDBG(EDBG),.ID({ID,"_DPRAM",IDX_STR}),.ERRD(1)) ram_inst (
      .wridx(wridx_s0_0),.wrdata(wrdata_s0_0[(i*`POWLIB_BW)+:`POWLIB_BW]),.wrvld(be_s0_1),
      .rdidx(rdidx_s0_0),.rddata(rddata_s1_0[(i*`POWLIB_BW)+:`POWLIB_BW]),.clk(clk));
  end
  
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
  
  // Stage the valid read address data. The data from the write interface becomes the return address. Determine if read operation occurs.
  assign wridx_s0_0  = addr_s0_0[RAM_LB+:RAM_WIDX];
  assign wrdata_s0_0 = data_s0_1;  
  assign rdidx_s0_0  = wridx_s0_0;
  assign vld_s0_1    = (vld_s0_0==1)&&(op_s0_0==`POWLIB_OP_READ);  
  powlib_flipflop #(.W(1),   .EAR(EAR)) vld_s0_s1_inst  (.d(vld_s0_1),          .q(vld_s1_0), .clk(clk),.rst(rst));
  powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s0_s1_inst (.d(data_s0_1[0+:B_AW]),.q(addr_s1_0),.clk(clk),.rst(1'd0));
  
  // Stage the data. Pack the data as well.
  assign data_s1_0   = rddata_s1_0;
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
    if ((1<<RAM_LB)!=B_BPD) begin
      $display("ID: %s, B_BPD: %d, B_BPD is not a power of 2.", ID, B_BPD);
      $finish;
    end
  end

endmodule