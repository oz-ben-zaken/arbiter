class arbiter_host_monitor extends uvm_monitor;
  `uvm_component_utils(arbiter_host_monitor)

  uvm_analysis_port#(arbiter_transaction) mon_ap;
  uvm_analysis_port#(arbiter_transaction) cov_ap;

  virtual arbiter_host_if vinf;
  string host_name;

  arbiter_transaction arbiter_tran;
  arbiter_transaction arbiter_tran_cov;
  bit sent_cov_zero_tran; 
  bit sent_scb_zero_tran; 
  
  covergroup tran_cov();
    READ : coverpoint arbiter_tran_cov.rd;
    WRITE : coverpoint arbiter_tran_cov.wr;
  endgroup : tran_cov 

  function new(string name, uvm_component parent);
		super.new(name, parent);
    tran_cov = new();
    arbiter_tran_cov = new("transaction");
  endfunction

  function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual arbiter_host_if)::get(this , "" , "arb_host_if" , vinf);
		mon_ap= new("mon_ap" , this);
    cov_ap= new("cov_ap" , this);
    uvm_config_db#(string)::get(this , "" , "name" , host_name);
  endfunction
  
  task run_phase(uvm_phase phase);
    sent_cov_zero_tran=0;
    sent_scb_zero_tran=0;
		forever begin

      @(posedge vinf.clk)
      //#1;
      if(!vinf.rd && !vinf.wr && !sent_cov_zero_tran)begin
        sent_cov_zero_tran++;
        arbiter_tran_cov.wr = vinf.wr;
        arbiter_tran_cov.rd = vinf.rd;
        cov_ap.write(arbiter_tran_cov);
      end else begin
        if(vinf.rd || vinf.wr) begin
          arbiter_tran_cov.wr = vinf.wr;
          arbiter_tran_cov.rd = vinf.rd;
          cov_ap.write(arbiter_tran_cov);
          sent_cov_zero_tran=0;
        end
      end

      if(vinf.rd || vinf.wr || sent_scb_zero_tran==0) begin
        sent_scb_zero_tran=1;
        arbiter_tran     = arbiter_transaction::type_id::create("arbiter_tran", this);
        arbiter_tran.wr   = vinf.wr;
        arbiter_tran.rd   = vinf.rd;
        arbiter_tran.dwr  = vinf.dwr;
        arbiter_tran.be   = vinf.be;
        arbiter_tran.addr = vinf.addr;
        //@(posedge vinf.clk);
        mon_ap.write(arbiter_tran);

        `uvm_info(" ", $sformatf("Monitor(%s)(start) got rd-%0d, wr-%0d, dwr-%0d",host_name, arbiter_tran.rd, arbiter_tran.wr, arbiter_tran.dwr), UVM_MEDIUM)
        if(arbiter_tran.rd || arbiter_tran.wr) begin
          sent_scb_zero_tran = 0;
          @(posedge vinf.ack[0]);
          arbiter_tran.drd = vinf.drd;
          arbiter_tran.ack = vinf.ack;
          mon_ap.write(arbiter_tran);
          arbiter_tran_cov = arbiter_tran;
          `uvm_info(" ", $sformatf("Monitor(%s)(done)  got rd-%0d, wr-%0d, drd-%0d, ack-%0d",host_name, arbiter_tran.rd, arbiter_tran.wr, arbiter_tran.drd, arbiter_tran.ack), UVM_MEDIUM)
          @(negedge vinf.ack[0]);
        end
        tran_cov.sample();
      end

		end
  endtask
endclass
