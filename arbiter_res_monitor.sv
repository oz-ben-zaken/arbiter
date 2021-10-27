class arbiter_res_monitor extends uvm_monitor;
  `uvm_component_utils(arbiter_res_monitor)

  uvm_analysis_port#(arbiter_transaction) mon_ap;

  virtual arbiter_res_if vinf;
  arbiter_transaction arbiter_tran;

  bit just_arrived;
  
  function new(string name, uvm_component parent);
		super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual arbiter_res_if)::get(this , "" , "arb_res_if" , vinf);
		mon_ap= new("mon_ap" , this);
  endfunction
  
  task run_phase(uvm_phase phase);
    arbiter_tran = arbiter_transaction::type_id::create("arbiter_tran", this);
    

		forever begin
      @(posedge vinf.clk);
      #1;
      if(vinf.rd || vinf.wr || vinf.ack) begin
        arbiter_tran.wr   = vinf.wr;
        arbiter_tran.rd   = vinf.rd;
        arbiter_tran.dwr  = vinf.dwr;
        arbiter_tran.be   = vinf.be;
        arbiter_tran.addr = vinf.addr;
        arbiter_tran.ack  = vinf.ack;
        arbiter_tran.drd  = vinf.drd;
        mon_ap.write(arbiter_tran);
        if (just_arrived) begin
          `uvm_info(" ", $sformatf("Monitor(res) got rd-%0d, wr-%0d, dwr-%0d, drd-%0d",vinf.rd, vinf.wr, vinf.dwr, vinf.drd), UVM_MEDIUM)
          just_arrived = 0;
        end
      end
      if (vinf.ack) begin
        `uvm_info(" ", $sformatf("Monitor(res) sent rd-%0d, wr-%0d, dwr-%0d, drd-%0d",arbiter_tran.rd, arbiter_tran.wr, arbiter_tran.dwr, arbiter_tran.drd), UVM_MEDIUM)
		    just_arrived = 1;
      end
    end
  endtask
endclass
