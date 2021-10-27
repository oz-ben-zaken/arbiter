//`uvm_analysis_imp_decl(_)
class arbiter_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(arbiter_scoreboard)
  
  typedef enum {MASTER, SLAVE, TEST, EXTRA} host;
  localparam hosts = 4;
  parameter IDLE = 5;
  uvm_analysis_export #(arbiter_transaction) scb_export_hosts[hosts];
  uvm_analysis_export #(arbiter_transaction) scb_export_r;

  uvm_tlm_analysis_fifo #(arbiter_transaction) fifo_hosts[hosts];
  uvm_tlm_analysis_fifo #(arbiter_transaction) fifo_r;

  arbiter_transaction trans_res;
  arbiter_transaction trans_host;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_host = new("transaction");
    trans_res = new("transaction");
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    for (int i = 0; i < hosts; i++) begin
      scb_export_hosts[i] = new($sformatf("scb_export_%d", i), this);
      fifo_hosts[i] = new($sformatf("fifo_%d", i), this);
    end
    scb_export_r = new("scb_export_r", this);
    fifo_r = new("fifo_r", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    for (int i = 0; i < hosts; i++)
      scb_export_hosts[i].connect(fifo_hosts[i].analysis_export);
    scb_export_r.connect(fifo_r.analysis_export);
  endfunction


  task run();
    int cur_host = SLAVE;
    forever begin


      wait(!fifo_hosts[MASTER].is_empty() || !fifo_hosts[SLAVE].is_empty() ||
           !fifo_hosts[TEST].is_empty()   || !fifo_hosts[EXTRA].is_empty())
      
      //removing zero's transactions
      clear_idle_trans();
      wait(!fifo_r.is_empty());
     
      for (int i = cur_host; i < hosts; i++) 
      begin
        if(!fifo_hosts[cur_host].is_empty()) 
        begin
          fifo_hosts[cur_host].get(trans_host);
          if(trans_host.rd || trans_host.wr)
          begin
            while(fifo_hosts[cur_host].is_empty()) 
            begin
              fifo_r.get(trans_res);
              steady_signals();
              wait(!fifo_r.is_empty() || !fifo_hosts[cur_host].is_empty());
            end
            fifo_hosts[cur_host].get(trans_host);
            compare();
            clear_idle_trans();
            //done with checking the current transaction


            //checking fifo states and if they are all empty we will wait for
            //the current host next transaction
            if(fifo_hosts[MASTER].is_empty() && fifo_hosts[SLAVE].is_empty() &&
               fifo_hosts[TEST].is_empty()   && fifo_hosts[EXTRA].is_empty())
              wait(!fifo_hosts[cur_host].is_empty());
            else begin
              clear_idle_trans();
              if(!fifo_hosts[MASTER].is_empty() || !fifo_hosts[SLAVE].is_empty() ||
                 !fifo_hosts[TEST].is_empty()   || !fifo_hosts[EXTRA].is_empty())
                wait(!fifo_r.is_empty());
            end
          end
        end
        cur_host = (cur_host+1)%4;
      end
    end
  endtask

  virtual function void clear_idle_trans();
    foreach (fifo_hosts[i]) 
    begin
      if (!fifo_hosts[i].is_empty()) 
      begin
        fifo_hosts[i].try_peek(trans_host);
        if(!trans_host.rd && !trans_host.wr)
          fifo_hosts[i].try_get(trans_host);
      end
    end
  endfunction

  virtual function void steady_signals();
    if (!(trans_host.rd == trans_res.rd   &&
        trans_host.wr   == trans_res.wr   &&
        trans_host.addr == trans_res.addr &&
        trans_host.be   == trans_res.be   &&
        trans_host.dwr  == trans_res.dwr)) begin
      `uvm_info("steady signals", {"Test: Fail!"}, UVM_LOW);
      $display("host: rd- %d, wr- %d, add- %d, drd- %d, dwr- %d, ack- %d,",trans_host.rd, trans_host.wr, trans_host.addr, trans_host.drd, trans_host.dwr, trans_host.ack);
      $display("res: rd- %d, wr- %d, add- %d, drd- %d, dwr- %d, ack- %d,", trans_res.rd,  trans_res.wr,  trans_res.addr,  trans_res.drd,  trans_res.dwr,  trans_res.ack);
    end
  endfunction


  virtual function void compare();
    if (!trans_res.ack && trans_host.ack[1] && trans_host.rd   == trans_res.rd   &&
         trans_host.wr == trans_res.wr      && trans_host.addr == trans_res.addr &&
         trans_host.be == trans_res.be      && trans_host.dwr  == trans_res.dwr) begin
      `uvm_info("compare (timeout occurred)", {"Test: OK!\n"}, UVM_LOW);
    end else if (trans_res.ack && trans_host.ack[0] && trans_host.drd == trans_res.drd &&
                 trans_host.rd == trans_res.rd      && trans_host.wr  == trans_res.wr  && 
                 trans_host.addr == trans_res.addr  && trans_host.be  == trans_res.be  &&
                 trans_host.dwr  == trans_res.dwr) begin
      `uvm_info("compare (no timeout)", {"Test: OK!\n"}, UVM_LOW);
    end else begin
      `uvm_info("compare (failed)", {"Test: Fail!\n"}, UVM_LOW);
    end
  endfunction

endclass
