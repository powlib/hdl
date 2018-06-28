`ifndef POWLIB 
`define POWLIB 
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


