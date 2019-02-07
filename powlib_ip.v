`timescale 1ns / 1ps

module powlib_ipunpackintr0(wrdata,rddata,rdbe,rdop);

  /* --------------------------------- 
   * Unpack data.    
   * --------------------------------- */

`include "powlib_std.vh"
`include "powlib_ip.vh"

  parameter                   B_BPD   = 4;                // Bus Bytes Per Data
  localparam                  B_DW    = `POWLIB_BW*B_BPD; // Bus Data Width
  localparam                  B_BEW   = B_BPD;            // Bus Byte Enable Width
  localparam                  B_OPW   = `POWLIB_OPW;      // Bus Operation Width
  localparam                  OFF_0   = 0;
  localparam                  OFF_1   = OFF_0+B_DW;
  localparam                  OFF_2   = OFF_1+B_BEW;
  localparam                  OFF_3   = OFF_2+B_OPW;
  localparam                  B_WW    = OFF_3;            // Bus Packed Data Width

  input      wire [B_WW-1:0]  wrdata;                     // Writing Data
  output     wire [B_DW-1:0]  rddata;                     // Reading Data
  output     wire [B_BEW-1:0] rdbe;                       // Reading Byte Enable
  output     wire [B_OPW-1:0] rdop;                       // Reading Operation

  assign                      rddata = wrdata[OFF_0+:B_DW];
  assign                      rdbe   = wrdata[OFF_1+:B_BEW];
  assign                      rdop   = wrdata[OFF_2+:B_OPW];
  
endmodule

module powlib_ippackintr0(rddata,wrdata,wrbe,wrop);

  /* --------------------------------- 
   * Pack data.    
   * --------------------------------- */

`include "powlib_std.vh"
`include "powlib_ip.vh"

  parameter                   B_BPD                 = 4;                // Bus Bytes Per Data
  localparam                  B_DW                  = `POWLIB_BW*B_BPD; // Bus Data Width
  localparam                  B_BEW                 = B_BPD;            // Bus Byte Enable Width
  localparam                  B_OPW                 = `POWLIB_OPW;      // Bus Operation Width
  localparam                  OFF_0                 = 0;
  localparam                  OFF_1                 = OFF_0+B_DW;
  localparam                  OFF_2                 = OFF_1+B_BEW;
  localparam                  OFF_3                 = OFF_2+B_OPW;
  localparam                  B_WW                  = OFF_3;            // Bus Packed Data Width
 
  output     wire [B_WW-1:0]  rddata;                                   // Reading Data
  input      wire [B_DW-1:0]  wrdata;                                   // Writing Data
  input      wire [B_BEW-1:0] wrbe;                                     // Writing Byte Enable
  input      wire [B_OPW-1:0] wrop;                                     // Writing Operation
  assign                      rddata[OFF_0+:B_DW]  = wrdata;
  assign                      rddata[OFF_1+:B_BEW] = wrbe;
  assign                      rddata[OFF_2+:B_OPW] = wrop;

endmodule


