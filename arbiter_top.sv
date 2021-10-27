`include "arbiter_pkg.sv"
`include "arbiter.v"
`include "arbiter_host_if.sv"
`include "arbiter_res_if.sv"
module arbiter_top;
  import uvm_pkg::*;
  import arbiter_pkg::*;
   bit clk;
   bit rst;
  //Variable initialization
  
  initial begin
    clk = 1'b0;
    rst = 1'b1;
    #1 rst = 1'b0;
    #30 rst = 1'b1;
  end

  //Clock generation
  always #5 clk = ~clk;

  //Interface declaration
  arbiter_host_if m_vinf(clk, rst);
  arbiter_host_if s_vinf(clk, rst);
  arbiter_host_if t_vinf(clk, rst);
  arbiter_host_if e_vinf(clk, rst);

  arbiter_res_if r_vinf(clk, rst);

  //Connects the Interface to the DUT
  arbiter dut(
      // Master Host
      .mcpu(m_vinf.cpu),
      .maddr(m_vinf.addr),
      .mrd(m_vinf.rd),
      .mwr(m_vinf.wr),
      .mbe(m_vinf.be),
      .mdwr(m_vinf.dwr),
      .mdrd(m_vinf.drd),
      .mack(m_vinf.ack),
      // Slave Host
      .scpu(s_vinf.cpu),
      .saddr(s_vinf.addr),
      .srd(s_vinf.rd),
      .swr(s_vinf.wr),
      .sbe(s_vinf.be),
      .sdwr(s_vinf.dwr),
      .sdrd(s_vinf.drd),
      .sack(s_vinf.ack),
      // Test Host
      .tcpu(t_vinf.cpu),
      .taddr(t_vinf.addr),
      .trd(t_vinf.rd),
      .twr(t_vinf.wr),
      .tbe(t_vinf.be),
      .tdwr(t_vinf.dwr),
      .tdrd(t_vinf.drd),
      .tack(t_vinf.ack),
      // Extra Host
      .ecpu(e_vinf.cpu),
      .eaddr(e_vinf.addr),
      .erd(e_vinf.rd),
      .ewr(e_vinf.wr),
      .ebe(e_vinf.be),
      .edwr(e_vinf.dwr),
      .edrd(e_vinf.drd),
      .eack(e_vinf.ack),
      // device
      .add_bus(r_vinf.addr),
      .byte_en(r_vinf.be),
      .wr_bus(r_vinf.wr),
      .rd_bus(r_vinf.rd),
      .data_bus_wr(r_vinf.dwr),
      .data_bus_rd(r_vinf.drd),
      .ack_bus(r_vinf.ack),
      .cpu_bus(r_vinf.cpu),
      // General
      .clk(clk),
      .reset_n(rst)
      );


  initial begin
    //Registers the Interfaces in the configuration block so that other
    //blocks can use it
    uvm_config_db#(virtual arbiter_host_if)::set(null, "*.arb_agent_m.*", "arb_host_if", m_vinf);
    uvm_config_db#(string)::set(null, "*.arb_agent_m.*", "name", "master");
    uvm_config_db#(virtual arbiter_host_if)::set(null, "*.arb_agent_s.*", "arb_host_if", s_vinf);
    uvm_config_db#(string)::set(null, "*.arb_agent_s.*", "name", "slave");
    uvm_config_db#(virtual arbiter_host_if)::set(null, "*.arb_agent_t.*", "arb_host_if", t_vinf);
    uvm_config_db#(string)::set(null, "*.arb_agent_t.*", "name", "test");
    uvm_config_db#(virtual arbiter_host_if)::set(null, "*.arb_agent_e.*", "arb_host_if", e_vinf);
    uvm_config_db#(string)::set(null, "*.arb_agent_e.*", "name", "extra");

    m_vinf.cpu=1;
    s_vinf.cpu=0;
    t_vinf.cpu=0;
    e_vinf.cpu=0;
    uvm_config_db#(virtual arbiter_res_if)::set(null, "*" , "arb_res_if", r_vinf);

    factory.print(1);
    run_test("arbiter_test");
    //run_test();
  end

endmodule // memory_top


