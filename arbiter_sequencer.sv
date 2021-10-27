class arbiter_sequencer extends uvm_sequencer#(arbiter_transaction);
  `uvm_component_utils(arbiter_sequencer)

  function new(string name, uvm_component parent);
    super.new(name);
  endfunction
  
endclass

