class arbiter_host_driver extends uvm_driver#(arbiter_transaction);
  `uvm_component_utils(arbiter_host_driver)

  virtual arbiter_host_if vinf;
  string host_name;
  int delay;
  arbiter_transaction arbiter_tran;
  arbiter_transaction arbiter_tran_cov;

  function new(string name, uvm_component parent);
	  super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
	  super.build_phase(phase);
    uvm_config_db#(virtual arbiter_host_if)::get(this , "" , "arb_host_if", vinf);
    uvm_config_db#(string)::get(this , "" , "name" , host_name);
  endfunction

  task run_phase(uvm_phase phase);
	  drive();
  endtask

  virtual task drive();
	  forever begin
	  	if(vinf.rst == 1'b1) begin
        //Gets a transaction from the sequencer and stores it in the variable 'arbiter_tran'
        seq_item_port.get_next_item(arbiter_tran);
        @(negedge vinf.clk);
        //`uvm_info("arb_host_driver", arbiter_tran.sprint(), UVM_LOW);
        vinf.addr = arbiter_tran.addr;
        vinf.be = arbiter_tran.be;
        vinf.rd = arbiter_tran.rd;
        vinf.wr = arbiter_tran.wr;
        vinf.dwr = arbiter_tran.dwr;
        `uvm_info(" ", $sformatf("Driver(%s) got rd-%0d, wr-%0d, dwr-%0d\n",host_name, arbiter_tran.rd, arbiter_tran.wr, arbiter_tran.dwr), UVM_MEDIUM)
        //for the coverage thats in environment
        arbiter_tran_cov = arbiter_tran;
        if(arbiter_tran.rd || arbiter_tran.wr) begin
          @(posedge vinf.ack[0]);
          vinf.rd = 0;
          vinf.wr = 0;
          @(negedge vinf.ack[0]);
        end else begin
          delay = $urandom_range(80,30);
          repeat(delay) @(posedge vinf.clk);
        end
        //Informs the sequencer that the current operation with the transaction was finished 
        seq_item_port.item_done();
      end else begin
        vinf.wr ='b0;
        vinf.rd ='b0;
        vinf.drd ='b0;
        vinf.dwr ='b0;
        vinf.ack ='b0;
        vinf.addr ='b0;
        vinf.be ='b0;
        @(posedge vinf.rst);
      end
	  end
  endtask
endclass
