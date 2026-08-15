`ifndef axi4_monitor
`define axi4_monitor

`include "axi4_transaction.sv"
`include "axi4_common_cfg.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;

class axi4_monitor extends uvm_monitor;
    `uvm_component_utils ( axi4_monitor );

  //virtual handler
  virtual axi4_if vif;
  //common config
  axi4_common_cfg c_cfg;
  //analysis port
  uvm_analysis_port#( axi4_transaction ) analysis_port;

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          constructor                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////  
  function new ( string name = "axi4_monitor" , uvm_component parent = null );
    super.new( name , parent );
  endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          build_phase                                           //
//////////////////////////////////////////////////////////////////////////////////////////////////// 
  function void build_phase ( uvm_phase phase );
    super.build_phase( phase );

    //building the analysis port
    analysis_port = new("analysis_port" , this);

        if
    (
      !uvm_config_db#( virtual axi4_if ) :: get(this , "*" , "vif" , vif)
    )
      begin
        `uvm_fatal("[axi4_monitor]", $sformatf("the interface was not retreived correctly"));
      end
    else
      begin
        `uvm_info("[axi4_monitor]", $sformatf("the interface was retreived successfully"), UVM_LOW);
      end

    if
    (
      !uvm_config_db#( axi4_common_cfg ) :: get(this , "*" , "c_cfg" , c_cfg)
    )
      begin
        `uvm_fatal("[axi4_monitor]", $sformatf("the common config was not retreived correctly"));
      end
    else
      begin
        `uvm_info("[axi4_monitor]", $sformatf("the common config was retreived successfully"), UVM_LOW);
      end
  endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          monitor_tasks                                         //
//////////////////////////////////////////////////////////////////////////////////////////////////// 
task monitor_read( axi4_transaction tr_read );
    vif.RREADY = 1; //initial value
  //for loop to itterate through bursts
  for(int i = 0 ; i <=  tr_read.length ; i++ )
    begin
      tr_read.resp = 0; //initial value 
      assert(tr_read.randomize( r_ready_delay ))
      else `uvm_fatal("[axi4_monitor]", $sformatf("the delay was not randomized correctly"));
      @( negedge vif.ACLK );
      if( tr_read.r_ready_delay > 0 )
        begin
          vif.RREADY = 0;
          repeat( tr_read.r_ready_delay ) @( negedge vif.ACLK ); //delay between every read
          vif.RREADY = 1;       
        end
        //waiting between for arvalid
        forever
          begin
            @( posedge vif.ACLK );
            if( vif.RVALID && vif.RREADY )
              begin
                  @( posedge vif.ACLK );
                  //storing the read data and the resp 
                    tr_read.output_burst.push_back( vif.RDATA );
                    tr_read.resp = vif.RRESP;
                    
                    break;
              end
          end

    end

    @( negedge vif.ACLK );    
    vif.RREADY = 1; //default value

endtask

task monitor_write ( axi4_transaction tr_write );

  assert( tr_write.randomize( b_ready_delay ) )
  else `uvm_fatal("[axi4_monitor]", $sformatf("there was a problem with generating the randomization of the "));

  //tr_write.resp = vif.BRESP;
  vif.WVALID = 0;
  vif.WLAST = 0;

  @(negedge vif.ACLK);
  if(  tr_write.b_ready_delay > 0 ) 
    begin
        vif.BREADY = 0;
        repeat(tr_write.b_ready_delay) @(negedge vif.ACLK);
    end

  vif.BREADY = 1;

  forever
    begin
      @( posedge vif.ACLK);
      if( vif.BVALID && vif.BREADY )
        begin
          tr_write.resp = vif.BRESP;
          break;
        end
    end

    @( negedge vif.ACLK );
    vif.BREADY = 0;

endtask



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          run_phase                                             //
//////////////////////////////////////////////////////////////////////////////////////////////////// 
task run_phase(uvm_phase phase);

  axi4_transaction tr; //to store the current transaction in 

  forever
    begin
        //waiting for the stimulus to be done 
          @( c_cfg.stimulus_done );
      tr = c_cfg.current_tr; 
      tr.output_burst.delete(); //deleting the previous monitored value
      tr.resp = 0;

      if(tr.operation == 0) //read
        begin
          monitor_read( tr );
        end
      if(tr.operation == 1) //write
        begin
          monitor_write( tr );
        end

        //now we need to send the monitored value in the analysis port 
          analysis_port.write( tr );
        //now we will raise the monitor done
        ->c_cfg.monitor_done;
    end

endtask




endclass


`endif