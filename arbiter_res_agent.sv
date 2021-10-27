class arbiter_res_agent extends uvm_agent;
  `uvm_component_utils(arbiter_res_agent)

  uvm_analysis_port#(arbiter_transaction) agent_ap;

  arbiter_res_driver	 arb_drv;
  arbiter_res_monitor arb_mon;

  function new(string name, uvm_component parent);
		super.new(name, parent);
  endfunction
  
 	function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
  	agent_ap = new("agent_ap" , this);
  	arb_drv		= arbiter_res_driver::type_id::create("arb_res_drv" , this);
  	arb_mon = arbiter_res_monitor::type_id::create("arb_res_mon" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    arb_mon.mon_ap.connect(agent_ap);
  endfunction
endclass

