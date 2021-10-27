class arbiter_transaction extends uvm_sequence_item;
  
  rand bit        rd;
  rand bit        wr;
  rand bit [31:0] addr;
  rand bit [3:0]  be;
  rand bit [31:0] dwr;
       bit [31:0] drd;
       bit [1:0]  ack;

  constraint rd_wr { rd + wr <= 1; }

	function new(string name = "");
		super.new(name);
	endfunction: new

	`uvm_object_utils_begin(arbiter_transaction)
	`uvm_field_int(rd,   UVM_ALL_ON)
	`uvm_field_int(wr,   UVM_ALL_ON)
	`uvm_field_int(addr, UVM_ALL_ON)
	`uvm_field_int(be,   UVM_ALL_ON)
	`uvm_field_int(dwr,  UVM_ALL_ON)
	`uvm_field_int(drd,  UVM_ALL_ON)
	`uvm_field_int(ack,  UVM_ALL_ON)
	`uvm_object_utils_end
endclass

