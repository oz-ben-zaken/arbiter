class arbiter_env extends uvm_env;
  `uvm_component_utils(arbiter_env)

  arbiter_host_agent arb_agent_m;
  arbiter_host_agent arb_agent_s;
  arbiter_host_agent arb_agent_t;
  arbiter_host_agent arb_agent_e;
  arbiter_res_agent arb_agent_r;
  arbiter_scoreboard arb_scb;
  arbiter_coverage arb_cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    arb_agent_m = arbiter_host_agent::type_id::create("arb_agent_m" , this);
    arb_agent_s = arbiter_host_agent::type_id::create("arb_agent_s" , this);
    arb_agent_t = arbiter_host_agent::type_id::create("arb_agent_t" , this);
    arb_agent_e = arbiter_host_agent::type_id::create("arb_agent_e" , this);
    arb_agent_r =  arbiter_res_agent::type_id::create("arb_agent_r" , this);
    arb_scb	    = arbiter_scoreboard::type_id::create("arb_scb" , this);
    arb_cov     = arbiter_coverage::type_id::create("arb_cov" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    arb_agent_m.agent_ap.connect(arb_scb.scb_export_hosts[0]);
    arb_agent_s.agent_ap.connect(arb_scb.scb_export_hosts[1]);
    arb_agent_t.agent_ap.connect(arb_scb.scb_export_hosts[2]);
    arb_agent_e.agent_ap.connect(arb_scb.scb_export_hosts[3]);
    arb_agent_r.agent_ap.connect(arb_scb.scb_export_r);

    arb_agent_m.agent_cov_ap.connect(arb_cov.cov_export_hosts[0]);
    arb_agent_s.agent_cov_ap.connect(arb_cov.cov_export_hosts[1]);
    arb_agent_t.agent_cov_ap.connect(arb_cov.cov_export_hosts[2]);
    arb_agent_e.agent_cov_ap.connect(arb_cov.cov_export_hosts[3]);
  endfunction
endclass
