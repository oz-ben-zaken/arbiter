class arbiter_res_driver extends uvm_driver#(arbiter_transaction);
  `uvm_component_utils(arbiter_res_driver)

  bit [15:0] cycle_to_wait;
  bit [15:0] timeout = {16{1'b1}};
  
  virtual arbiter_res_if vinf;

  function new(string name, uvm_component parent);
	  super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
	  super.build_phase(phase);
    uvm_config_db#(virtual arbiter_res_if)::get(this , "" , "arb_res_if", vinf);
  endfunction

  task run_phase(uvm_phase phase);
	  drive();
  endtask

  virtual task drive();

    vinf.ack='b0;

	  forever begin
      @(vinf.rd || vinf.wr);
      randcase 
        1 : cycle_to_wait = 2;
        1 : cycle_to_wait = 3;
        1 : cycle_to_wait = 4;
        //1 : cycle_to_wait = timeout; 
      endcase

      vinf.drd = 'b0;
      repeat(cycle_to_wait) @(posedge vinf.clk);
      
      if(vinf.rd && cycle_to_wait!= timeout)
        vinf.drd = $random();

      if(cycle_to_wait != timeout && (vinf.rd || vinf.wr))begin
        vinf.ack = 1'b1;
        @(posedge vinf.clk);
        vinf.ack = 1'b0;
      end
	  end
  endtask
endclass
