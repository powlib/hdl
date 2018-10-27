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
 
  input      wire [B_WW-1:0]  rddata;
  output     wire [B_DW-1:0]  wrdata;
  output     wire [B_BEW-1:0] wrbe;  
  output     wire [B_OPW-1:0] wrop
  assign                      rddata[OFF_0+:B_DW]  = wrdata;
  assign                      rddata[OFF_1+:B_BEW] = wrbe;
  assign                      rddata[OFF_2+:B_OPW] = wrop;

endmodule

module powlib_ipram();

`include "powlib_std.vh"
`include "powlib_ip.vh"
  
  parameter                  ID   = "IPRAM";  // String identifier  
  parameter                  EAR  = 0;        // Enable asynchronous reset  
  parameter                  EDBG = 0;

  parameter                  B_BASE = 8'd0;
  parameter                  B_SIZE = 8'd15;
  parameter                   B_BPD   = 4;
  parameter                   B_AW    = `POWLIB_BW*B_BPD;
  localparam                  B_DW    = `POWLIB_BW*B_BPD;
  localparam                  B_BEW   = B_BPD;
  localparam                  B_OPW   = `POWLIB_OPW;
  localparam                  B_WW    = B_OPW+B_BEW+B_DW;
  localparam               RAM_D = B_SIZE+1;
  localparam  RAM_WIDX = powlib_clogb2(D);

input wire clk;
input wire rst;

input wire [B_AW-1:0] wraddr;
input wire [B_WW-1:0] wrdata;
input wire wrvld;
output wire wrrdy;
output wire wrnf;

output wire [B_AW-1:0] rdaddr;
output wire [B_WW-1:0] rddata;
output wire rdvld;
input wire rdrdy;


// DPRAM instantiation.
powlib_dpram         #(.W(B_DW),.D(RAM_D),EWBE(1),.EDBG(EDBG),.ID({ID,"_DPRAM"})) ram_inst (
  .wridx(wridx_s0_0),.wrdata(wrdata_s0_0),.wrvld(1'd0),.wrbe(wrbe_s0_0),
  .rdidx(rdidx_s0_0),.rddata(rddata_s1_0),.clk(clk));



// FIFO the input data.
powlib_busfifo #(.NFS(IN_NFS),.D(IN_D),.S(IN_S),.EAR(EAR),.ID({ID,"_INFIFO"}),.EDBG(EDBG),.B_AW(B_AW),.B_DW(B_WW)) infifo_inst (
  .wrdata(wrdata),.wraddr(wraddr),.wrvld(wrvld),.wrrdy(wrrdy),.wrnf(wrnf),.wrclk(clk),.wrrst(rst),
  .rddata(data_in_0),.rdaddr(addr_in_0),.rdvld(vld_in_0),.rdrdy(rdy_in_0),.rdclk(clk),.rdrst(rst));


// Stage the FIFOed data. Unpack the data word.
assign rdy_in_0 = nf_s2_0;
assign vld_in_1 = vld_in_0 && rdy_in_0;
powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_in_s0_inst (.d(addr_in_0),.q(addr_s0_0),.clk(clk),.rst(0'd0));
powlib_flipflop #(.W(B_WW),.EAR(EAR)) data_in_s0_inst (.d(data_in_0),.q(data_s0_0),.clk(clk),.rst(0'd0));
powlib_flipflop #(.W(1),   .EAR(EAR)) vld_in_s0_inst  (.d(vld_in_1), .q(vld_s0_0), .clk(clk),.rst(rst));
powlib_ipunpackintr0 #(.B_BPD(B_BPD)) unpack_s0_inst (.wrdata(data_s0_0),.rddata(data_s0_1),.rdbe(be_s0_0),.rdop(op_s0_0));

// Set the write bit enables for the DPRAM. Determine if write operation.
assign wridx_s0_0  = addr_s0_0-B_BASE;
assign wrdata_s0_0 = data_s0_1;
for (i=0; i<B_BEW; i=i+1) begin
  assign wrbe_s0_0[i*`POWLIB_BW+:`POWLIB_BW] = ((vld_s0_0==1)&&(op_s0_0==`POWLIB_OP_WRITE)&&(be_s0_0[i]==1)) ? {`POWLIB_BW{1'b1}} : {`POWLIB_BW{1'b0}};
end

// Stage the valid read address data. The data from the write interface becomes the return address. Determine if read operation.
assign rdidx_s0_0 = wridx_s0_0;
assign vld_s0_1   = (vld_s0_0==1)&&(op_s0_0==`POWLIB_OP_READ);
powlib_flipflop #(.W(1),   .EAR(EAR)) vld_s0_s1_inst  (.d(vld_s0_1),          .q(vld_s1_0), .clk(clk),.rst(rst));
powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s0_s1_inst (.d(data_s0_0[0+:B_AW]),.q(addr_s1_0),.clk(clk),.rst(1'd0));

// Stage the data from the last step before FIFO. Pack the data as well.
powlib_flipflop #(.W(1),   .EAR(EAR)) vld_s1_s2_inst  (.d(vld_s1_0), .q(vld_s2_0), .clk(clk),.rst(rst));
powlib_flipflop #(.W(B_AW),.EAR(EAR)) addr_s1_s2_inst (.d(addr_s1_0),.q(addr_s2_0),.clk(clk),.rst(1'd0));
powlib_flipflop #(.W(B_DW),.EAR(EAR)) data_s1_s2_inst (.d(data_s1_0),.q(data_s2_0),.clk(clk),.rst(1'd0));
powlib_ippackintr0 #(.B_BPD(B_BPD)) pack_s2_inst   (.wrdata(data_s2_0),.wrbe({B_BEW{1'b1}}}),.wrop(`POWLIB_OP_WRITE),.rddata(data_s2_1));


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