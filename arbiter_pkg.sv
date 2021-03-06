package arbiter_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "arbiter_transaction.sv"
	//`include "arbiter_sequence.sv"
	`include "arbiter_sequence_normal.sv"
	`include "arbiter_sequence_no_idle.sv"
	`include "arbiter_sequence_burst.sv"
	`include "arbiter_sequencer.sv"
	`include "arbiter_res_monitor.sv"
	`include "arbiter_host_monitor.sv"
	`include "arbiter_res_driver.sv"
	`include "arbiter_host_driver.sv"
	`include "arbiter_res_agent.sv"
	`include "arbiter_host_agent.sv"
	`include "arbiter_scoreboard.sv"
	`include "arbiter_coverage.sv"
	`include "arbiter_config.sv"
	`include "arbiter_env.sv"
	`include "arbiter_test.sv"
endpackage
