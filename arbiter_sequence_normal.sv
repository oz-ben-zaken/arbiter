class arbiter_sequence_normal extends uvm_sequence#(arbiter_transaction);
	`uvm_object_utils(arbiter_sequence_normal)
	
	
	//TO DO: more sequences for a few modes(only rd/wr -- with no rd/wr  -- equal random)

	rand int index;
	constraint count_limit {
		index <  50;
		index >= 20;
	}
	function new(string name = "");
		super.new(name);
	endfunction

	task body();
		arbiter_transaction arbiter_tran;
		arbiter_tran = arbiter_transaction::type_id::create("arbiter_tran");

		arbiter_tran.rd_wr.constraint_mode(0);

		repeat(index) begin
			start_item(arbiter_tran);
			assert(arbiter_tran.randomize());
			randcase 
        		7 : {arbiter_tran.rd,arbiter_tran.wr} = 2'b10;
        		7 : {arbiter_tran.rd,arbiter_tran.wr} = 2'b01;
        		3 : {arbiter_tran.rd,arbiter_tran.wr} = 2'b00;
        	endcase	
			finish_item(arbiter_tran);
		end
	endtask
endclass

