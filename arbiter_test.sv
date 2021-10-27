class arbiter_test extends uvm_test;
	`uvm_component_utils(arbiter_test)

	arbiter_env arb_env;
	arbiter_sequence_normal arb_seq1[4];
	arbiter_sequence_burst arb_seq2[4];
	arbiter_sequence_no_idle arb_seq3[4];

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    	arb_env = arbiter_env::type_id::create("arb_env" , this);
    	
    	arb_seq1[0] = arbiter_sequence_normal::type_id::create("arb_seq_master");
		arb_seq1[1] = arbiter_sequence_normal::type_id::create("arb_seq_slave");
    	arb_seq1[2] = arbiter_sequence_normal::type_id::create("arb_seq_test");
    	arb_seq1[3] = arbiter_sequence_normal::type_id::create("arb_seq_extra");

    	arb_seq2[0] = arbiter_sequence_burst::type_id::create("arb_seq_master");
    	arb_seq2[1] = arbiter_sequence_burst::type_id::create("arb_seq_slave");
    	arb_seq2[2] = arbiter_sequence_burst::type_id::create("arb_seq_test");
    	arb_seq2[3] = arbiter_sequence_burst::type_id::create("arb_seq_exstra");

    	arb_seq3[0] = arbiter_sequence_no_idle::type_id::create("arb_seq_master");
    	arb_seq3[1] = arbiter_sequence_no_idle::type_id::create("arb_seq_slave");
    	arb_seq3[2] = arbiter_sequence_no_idle::type_id::create("arb_seq_test");
    	arb_seq3[3] = arbiter_sequence_no_idle::type_id::create("arb_seq_exstra");

	endfunction

	task run_phase(uvm_phase phase);

		phase.raise_objection(.obj(this));
		assert (arb_seq1[0].randomize());
		assert (arb_seq1[1].randomize());
		assert (arb_seq1[2].randomize());
		assert (arb_seq1[3].randomize());

		assert (arb_seq2[0].randomize());
		assert (arb_seq2[1].randomize());
		assert (arb_seq2[2].randomize());
		assert (arb_seq2[3].randomize());

		assert (arb_seq3[0].randomize());
		assert (arb_seq3[1].randomize());
		assert (arb_seq3[2].randomize());
		assert (arb_seq3[3].randomize());
    	
    	fork
        	arb_seq1[0].start(arb_env.arb_agent_m.arb_seqer);
        	arb_seq1[1].start(arb_env.arb_agent_s.arb_seqer);
        	arb_seq1[2].start(arb_env.arb_agent_t.arb_seqer);
        	arb_seq1[3].start(arb_env.arb_agent_e.arb_seqer);
      	join

      	fork
        	arb_seq3[0].start(arb_env.arb_agent_m.arb_seqer);
        	arb_seq3[1].start(arb_env.arb_agent_s.arb_seqer);
        	arb_seq3[2].start(arb_env.arb_agent_t.arb_seqer);
        	arb_seq3[3].start(arb_env.arb_agent_e.arb_seqer);
      	join
      	fork
        	arb_seq2[0].start(arb_env.arb_agent_m.arb_seqer);
        	arb_seq2[1].start(arb_env.arb_agent_s.arb_seqer);
        	arb_seq2[2].start(arb_env.arb_agent_t.arb_seqer);
        	arb_seq2[3].start(arb_env.arb_agent_e.arb_seqer);
      	join

    	#369
		phase.drop_objection(.obj(this));
	endtask
endclass
