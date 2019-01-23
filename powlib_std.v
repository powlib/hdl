`timescale 1ns / 1ps

module powlib_flipflop(d,q,clk,rst,vld);

  /* --------------------------------- 
   * Registers data.   
   * --------------------------------- */   

  parameter              W    = 1;    // Width
  parameter      [W-1:0] INIT = 0;    // Initial value
  parameter              EAR  = 0;    // Enable asynchronous reset
  parameter              EVLD = 0;    // Enable valid  
  input     wire [W-1:0] d;           // Input data
  input     wire         vld;         // Valid  
  input     wire         clk;         // Clock
  input     wire         rst;         // Reset
  output    reg  [W-1:0] q    = INIT; // Output data  
            reg          vld0;

  always @(*) begin
    vld0 <= vld==1 || EVLD==0;
  end            

  if (EAR==0) begin
    always @(posedge clk) begin
      if (rst==1) begin
        q <= INIT;
      end else if (vld0==1) begin
        q <= d;
      end
    end
  end else begin
    always @(posedge clk or posedge rst) begin
      if (rst==1) begin
        q <= INIT;
      end else if (vld0==1) begin
        q <= d;
      end    
    end  
  end

endmodule

module powlib_ffsync(d,q,aclk,bclk,arst,brst,vld);

  /* --------------------------------- 
   * Flip flip synchronizer.   
   * --------------------------------- */ 

  parameter                W    = 1;    // Width
  parameter        [W-1:0] INIT = 0;    // Initial value
  parameter                EAR  = 0;    // Enable asynchronous reset
  parameter                EVLD = 0;    // Enable valid
  parameter                S    = 2;    // Number of B clk domain stages
  input     wire   [W-1:0] d;           // Input data
  input     wire           vld;         // Valid  
  input     wire           aclk, bclk;  // Clock
  input     wire           arst, brst;  // Reset
  output    wire   [W-1:0] q;           // Output data  
  
            genvar         i;
            wire   [W-1:0] ds [0:S];
            wire   [W-1:0] aq;
  
  powlib_flipflop #(.W(W),.INIT(INIT),.EAR(EAR),.EVLD(EVLD))  aff (.d(d),.q(aq),.clk(aclk),.rst(arst),.vld(vld));
  
  for (i=0; i<S; i=i+1) begin
    powlib_flipflop #(.W(W),.INIT(INIT),.EAR(EAR))  bffs (.d(ds[i]),.q(ds[i+1]),.clk(bclk),.rst(brst));
  end
  
  if (S<1) begin
    assign q     = aq;
  end else begin
    assign ds[0] = aq;
    assign q     = ds[S];
  end 
  
endmodule

module powlib_edge(d,q,clk,rst,vld);

  /* --------------------------------- 
   * Edge detection flip flop.    
   * --------------------------------- */ 

  parameter              W    = 1;      // Width
  parameter      [W-1:0] INIT = 0;      // Initial value
  parameter              EAR  = 0;      // Enable asynchronous reset
  parameter              EHP  = 1;      // Enable high on positive edge
  parameter              EHN  = 0;      // Enable high on negative edge
  parameter              EVLD = 0;      // Enable valid
  input     wire [W-1:0] d;             // Input data
  output    wire [W-1:0] q;             // Output data
  input     wire         vld;           // Valid 
  input     wire         clk;           // Clock
  input     wire         rst;           // Reset
            wire [W-1:0] q_0;
  assign                 q = ( (EHP!=0) ? (d & ~q_0) : {W{1'd0}} ) |
                             ( (EHN!=0) ? (~d & q_0) : {W{1'd0}} );             
  
  powlib_flipflop #(.W(W),.INIT(INIT),.EAR(EAR),.EVLD(EVLD))  ff (.d(d),.q(q_0),.clk(clk),.rst(rst),.vld(vld));

endmodule

module powlib_pipe(d,q,clk,rst,vld);

  /* --------------------------------- 
   * Pipe / Delay.    
   * --------------------------------- */ 

  parameter              W    = 1;    // Width
  parameter      [W-1:0] INIT = 0;    // Initial value
  parameter              EAR  = 0;    // Enable asynchronous reset
  parameter              EVLD = 0;    // Enable valid
  parameter              S    = 4;    // Number of stages
  input     wire [W-1:0] d;           // Input data
  output    wire [W-1:0] q;           // Output data
  input     wire         clk;         // Clock
  input     wire         rst;         // Reset
  input     wire         vld;         // Valid
  
  if (S<1) begin
    assign q = d;
  end else begin
    powlib_ffsync #(.W(W),.INIT(INIT),.EAR(EAR),.EVLD(EVLD),.S(S-1)) ffs (.d(d),.q(q),.aclk(clk),.bclk(clk),.arst(rst),.brst(rst),.vld(vld));
  end
  
endmodule

module powlib_flag(q,set,clr,clk,rst);

  /* --------------------------------- 
   * Flag register.    
   * --------------------------------- */ 

  parameter      INIT = 0;    // Initial value
  parameter      EAR  = 0;    // Enable asynchronous reset 
  output    wire q;           // Output data  
  input     wire set;         // Sets the output q
  input     wire clr;         // Clears the output q 
  input     wire clk;         // Clock
  input     wire rst;         // Reset
  
  powlib_flipflop #(.W(1),.INIT(INIT),.EAR(EAR),.EVLD(1)) flag_inst (
    .d((clr) ? 1'd0 :
       (set) ? 1'd1 : 1'dz),
    .q(q),
    .clk(clk),
    .rst(rst),
    .vld(clr||set));
    
endmodule

module powlib_cntr(cntr,nval,adv,ld,dx,clr,clk,rst);

  /* --------------------------------- 
   * Counter.    
   * --------------------------------- */
  
  parameter              W     = 32; // Width
  parameter      [W-1:0] X     = 1;  // Increment / decrement value
  parameter      [W-1:0] INIT  = 0;  // Initialize value
  parameter              ELD   = 1;  // Enable load feature
  parameter              EDX   = 0;  // Enable dynamic increment / decrement.
  parameter              EAR   = 0;  // Enable asynchronous reset feature
  output    wire [W-1:0] cntr;       // Current counter value
  input     wire [W-1:0] nval;       // New value
  input     wire         adv;        // Advances the counter
  input     wire         ld;         // Loads a new value into counter
  input     wire [W-1:0] dx;         // Dynamic increment / decrement value.
  input     wire         clr;        // Clears the counter to INIT
  input     wire         clk;        // Clock
  input     wire         rst;        // Reset
   
            wire         ld0   = ld && (ELD!=0);
            wire [W-1:0] x0    = (EDX!=0) ? dx : X;        
  
  powlib_flipflop #(.W(W),.INIT(INIT),.EAR(EAR),.EVLD(1)) cntr_inst (
    .d((clr) ? INIT    : 
       (ld0) ? nval    :
       (adv) ? cntr+x0 : {W{1'bz}}),
    .q(cntr),
    .clk(clk),
    .rst(rst),
    .vld(clr||ld0||adv));
  
endmodule

module powlib_grayencodeff(d,q,clk,rst,vld);

  /* --------------------------------- 
   * Gray encoder flip flop.    
   * --------------------------------- */

`include "powlib_std.vh"

  parameter                       W    = 1;           // Width
  parameter      [W-1:0]          INIT = 0;           // Initial value
  parameter                       EAR  = 0;           // Enable asynchronous reset
  parameter                       EVLD = 0;           // Enable valid  
  input     wire [W-1:0]          d;                  // Input data
  input     wire                  vld;                // Valid  
  input     wire                  clk;                // Clock
  input     wire                  rst;                // Reset
  output    wire [W-1:0]          q;                  // Output data
  
            wire [`POWLIB_DW-1:0] d0 = powlib_grayencode(d); 
            wire [W-1:0]          d1 = d0[W-1:0];
  
  powlib_flipflop #(.W(W),.INIT(powlib_grayencode(INIT)),.EAR(EAR),.EVLD(EVLD)) ff_inst (
    .d(d1),.q(q),.vld(vld),.clk(clk),.rst(rst));
    
endmodule

module powlib_graydecodeff(d,q,clk,rst,vld);

  /* --------------------------------- 
   * Gray decoder flip flop.    
   * --------------------------------- */

`include "powlib_std.vh"

  parameter                       W    = 1;         // Width
  parameter      [W-1:0]          INIT = 0;         // Initial value
  parameter                       EAR  = 0;         // Enable asynchronous reset
  parameter                       EVLD = 0;         // Enable valid  
  input     wire [W-1:0]          d;                // Input data
  input     wire                  vld;              // Valid  
  input     wire                  clk;              // Clock
  input     wire                  rst;              // Reset
  output    wire [W-1:0]          q;                // Output data
  
            wire [`POWLIB_DW-1:0] d0 = powlib_graydecode(d); 
            wire [W-1:0]          d1 = d0[W-1:0];
  
  powlib_flipflop #(.W(W),.INIT(powlib_graydecode(INIT)),.EAR(EAR),.EVLD(EVLD)) ff_inst (
    .d(d1),.q(q),.vld(vld),.clk(clk),.rst(rst));
  
endmodule

module powlib_dpram(wridx,wrdata,wrvld,wrbe,rdidx,rddata,rdrdy,clk,wrclk,rdclk);

  /* --------------------------------- 
   * Dual-port ram.  
   * It should be noted the ERRD parameter must be
   * set in order to infer block RAMs instead of
   * distributed RAMs in an Xilinx design. Plus,
   * the D and W need to be sufficiently large
   * enough, as well. This was tested in Vivado 2017.4
   * --------------------------------- */

`include "powlib_std.vh"

  parameter                    W      = 32;               // Width
  parameter                    D      = 128;              // Depth
  parameter         [W*D-1:0]  INIT   = 0;                // Initializes the memory
  parameter                    WIDX   = powlib_clogb2(D); // Width of index
  parameter                    EWBE   = 0;                // Enable write bit enable
  parameter                    ERDRDY = 0;                // Enable read ready.
  parameter                    ERRD   = 0;                // Enable registered output.
  parameter                    EASYNC = 0;                // Enable asynchronous mode.
  parameter                    EDBG   = 0;                // Enable debug statements
  parameter                    ID     = "DPRAM";          // String identifier
  input     wire    [WIDX-1:0] wridx;                     // Write index 
  input     wire    [W-1:0]    wrdata;                    // Write data
  input     wire               wrvld;                     // Write data valid
  input     wire    [W-1:0]    wrbe;                      // Write bit enable
  input     wire    [WIDX-1:0] rdidx;                     // Read index
  output    reg     [W-1:0]    rddata;                    // Read data
  input     wire               rdrdy;                     // Read data ready
  input     wire               clk;                       // Clock (for synchronous mode)
  input     wire               wrclk;                     // Write Clock (for asynchronous mode)
  input     wire               rdclk;                     // Read Clock (for asynchronous mode)
            wire               wrclk0, rdclk0;
            reg     [W-1:0]    mem[D-1:0];                // Array (i.e. should be inferred as block ram)
            reg                rdrdy0;
            integer            i; 

  /* 
   * It's interesting to see clock re-assignment doesn't
   * appear to change the positive clock edge event to the wrong
   * event order. Potentially dangerous? Simulations still pass.
   */
  assign wrclk0 = (EASYNC!=0) ? wrclk : clk; 
  assign rdclk0 = (EASYNC!=0) ? rdclk : clk;
              
  always @(*) begin
    rdrdy0 <= rdrdy==1 || ERDRDY==0;
  end    
    
  if (ERRD!=0) begin
    always @(posedge rdclk0) begin
      if (rdrdy0==1) begin
        rddata <= mem[rdidx];
      end
    end
  end else begin
    always @(*) begin
      rddata <= mem[rdidx];
    end
  end
    
  initial begin
    for (i=0; i<D; i=i+1) begin
      mem[i] = INIT[W*i +: W]; 
    end    
  end
  
  always @(posedge wrclk0) begin               
    if (EWBE==0) begin
      if (wrvld==1) begin
        mem[wridx] <= wrdata;
      end
    end else begin
      for (i=0; i<W; i=i+1) begin
        if (wrbe[i]==1) begin
          mem[wridx][i] <= wrdata[i];
        end
      end
    end    
  end

  if (EDBG!=0) begin
    always @(posedge wrclk0) begin      
      for (i=0; i<D; i=i+1) begin
        $display("ID: %s, i: %d, mem[i]: %h", ID, i, mem[i]);        
      end     
    end
  end

endmodule
