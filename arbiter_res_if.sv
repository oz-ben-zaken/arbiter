interface arbiter_res_if(input logic clk, rst);
  
  logic        rd;
  logic        wr;
  logic        cpu;
  logic [3:0]  be;
  logic [31:0] addr;
  logic [31:0] dwr;
  logic [31:0] drd;
  logic        ack;
  
endinterface
