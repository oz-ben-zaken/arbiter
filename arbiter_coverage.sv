class arbiter_coverage extends uvm_scoreboard;
  `uvm_component_utils(arbiter_coverage)

  typedef enum {MASTER, SLAVE, TEST, EXTRA} host;
  localparam hosts = 4;

  uvm_analysis_export #(arbiter_transaction) cov_export_hosts[hosts];
  uvm_tlm_analysis_fifo #(arbiter_transaction) fifo_hosts[hosts];
  arbiter_transaction trans[hosts];

  covergroup arb_input_cov();
    M_RD_WR : coverpoint {trans[MASTER].rd,trans[MASTER].wr}{
      bins idle = {0};
      bins write = {1};
      bins read = {2};
      illegal_bins ib = {3};
      }
    S_RD_WR : coverpoint {trans[SLAVE].rd,trans[SLAVE].wr}{
      bins idle = {0};
      bins write = {1};
      bins read = {2};
      illegal_bins ib = {3};
      }
    T_RD_WR : coverpoint {trans[TEST].rd,trans[TEST].wr}{
      bins idle = {0};
      bins write = {1};
      bins read = {2};
      illegal_bins ib = {3};
      }
    E_RD_WR : coverpoint {trans[EXTRA].rd,trans[EXTRA].wr}{
      bins idle = {0};
      bins write = {1};
      bins read = {2};
      illegal_bins ib = {3};
      }
    cross M_RD_WR, S_RD_WR, T_RD_WR, E_RD_WR;
  endgroup : arb_input_cov

  function new(string name, uvm_component parent);
    super.new(name, parent);
    arb_input_cov = new();
    foreach (trans[i])
      trans[i] = new("transaction");
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    for (int i = 0; i < hosts; i++) begin
      cov_export_hosts[i] = new($sformatf("cov_export_%d", i), this);
      fifo_hosts[i] = new($sformatf("fifo%d", i), this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    for (int i = 0; i < hosts; i++)
      cov_export_hosts[i].connect(fifo_hosts[i].analysis_export);
  endfunction


  task run();
    foreach (trans[i]) begin
      wait(!fifo_hosts[i].is_empty());
      fifo_hosts[i].get(trans[i]);
    end
    arb_input_cov.sample();

    forever begin
      wait(!fifo_hosts[MASTER].is_empty() || !fifo_hosts[SLAVE].is_empty() ||
           !fifo_hosts[TEST].is_empty()   || !fifo_hosts[EXTRA].is_empty())

      for (int i = 0; i < hosts; i++) begin
        if(!fifo_hosts[i].is_empty()) begin
          fifo_hosts[i].get(trans[i]);
          arb_input_cov.sample();
        end
      end
    end
  endtask
endclass
