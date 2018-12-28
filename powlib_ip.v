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


