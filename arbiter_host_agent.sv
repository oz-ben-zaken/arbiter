class arbiter_host_agent extends uvm_agent;
  `uvm_component_utils(arbiter_host_agent)

  uvm_analysis_port#(arbiter_transaction) agent_ap;
  uvm_analysis_port#(arbiter_transaction) agent_cov_ap;

  string h_name;

  arbiter_sequencer		 arb_seqer;
  arbiter_host_driver	 arb_drv;
  arbiter_host_monitor arb_mon;

  function new(string name, uvm_component parent);
		super.new(name, parent);
  endfunction
  
 	function void build_phase(uvm_phase phase);
  	super.build_phase(phase);

    uvm_config_db#(string)::get(this , "" , "name" , h_name);

  	agent_ap = new("agent_ap" , this);
    agent_cov_ap = new("agent_cov_ap" , this);
  	arb_seqer	= arbiter_sequencer::type_id::create(h_name , this);
  	arb_drv		= arbiter_host_driver::type_id::create("arb_host_drv" , this);
  	arb_mon = arbiter_host_monitor::type_id::create("arb_host_mon" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    arb_drv.seq_item_port.connect(arb_seqer.seq_item_export);
    arb_mon.mon_ap.connect(agent_ap);
    arb_mon.cov_ap.connect(agent_cov_ap);
  endfunction
endclass

