`ifndef POWLIB_STD 
`define POWLIB_STD

`define POWLIB_BW  8  // Byte Width
`define POWLIB_DW  32 // Default Width
`define POWLIB_DLW 64 // Default Long Width

`endif

function integer powlib_clogb2;
  input reg [`POWLIB_DW-1:0] value;
  begin
    value = value - 1;
    for (powlib_clogb2=0; value>0; powlib_clogb2=powlib_clogb2+1) begin
      value = value >> 1;
    end
  end
endfunction

function integer powlib_grayencode;
  input reg [`POWLIB_DW-1:0] value;
  begin
    powlib_grayencode = value^(value>>1);
  end
endfunction

function integer powlib_graydecode;
  input reg     [`POWLIB_DW-1:0] encoded;
        reg     [`POWLIB_DW-1:0] value;
        integer                  i;
  begin
    value[`POWLIB_DW-1] = encoded[`POWLIB_DW-1];
    for (i=`POWLIB_DW-2; i>=0; i=i-1) begin
      value[i] = encoded[i]^value[i+1];
    end
    powlib_graydecode = value;
  end 
endfunction

function integer powlib_digits;
  input reg     [`POWLIB_DW-1:0] value;
  input reg     [`POWLIB_DW-1:0] base;
        integer                  i;
  begin
    i = 0;
    while (value!=0) begin
      value = value/base;
      i     = i+1;
    end
    if (i==0) begin
      powlib_digits = 1;
    end else begin
      powlib_digits = i;
    end    
  end
endfunction

function integer powlib_itoaw;
  parameter                      BASE = 10;         // Value base.
  parameter                      CW   = `POWLIB_BW; // ASCII width
  input     reg [`POWLIB_DW-1:0] value;
  begin
    powlib_itoaw = (powlib_digits(value,BASE)+1)*CW;
  end
endfunction    

function [`POWLIB_DW*`POWLIB_BW-1:0] powlib_itoa;
  parameter                      BASE = 10;         // Value base.
  parameter                      CW   = `POWLIB_BW; // ASCII width
  input     reg [`POWLIB_DW-1:0] value;  
            reg [CW-1:0]         digit;
            integer              i;
  begin
    powlib_itoa = 0;
    i           = 1;
    while (value!=0) begin
      digit                 = value%BASE;
      value                 = value/BASE;
      powlib_itoa[i*CW+:CW] = digit + "0";
      i                     = i+1;
    end
    if (i==1) begin
      powlib_itoa[1*CW+:CW] = "0";
    end
  end
endfunction


