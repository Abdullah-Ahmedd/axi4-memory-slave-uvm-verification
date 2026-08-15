`ifndef axi4_agent
`define axi4_agent

//`include "axi4_transaction.sv"
`include "axi4_monitor.sv"
`include "axi4_driver.sv"
`include "axi4_sequencer.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;

class axi4_agent extends uvm_agent;

  `uvm_component_utils( axi4_agent );
  
  axi4_monitor mon;
  axi4_sequencer seqer;
  axi4_driver driv;
  


  function new (  string name = "axi4_agent"  ,   uvm_component parent = null );

    super.new( name , parent );
    `uvm_info("[axi4_agent]", $sformatf("INSIDE the axi4_agent constructor"), UVM_LOW );

    //is_active is a built-in variable that determines whether this agent is active or passive
      this.is_active = UVM_ACTIVE;

  endfunction

  function void build_phase ( uvm_phase phase );

    super.build_phase ( phase );

    //building the monitor
    mon = axi4_monitor :: type_id :: create( "mon" , this );

    if(  is_active == UVM_ACTIVE  )
      begin

        //building the sequencer
        seqer = axi4_sequencer :: type_id :: create("seq" , this);
    
        //building the driver
        driv = axi4_driver :: type_id :: create("driv" , this );
      end

  endfunction

  function void connect_phase (uvm_phase phase );

    super.connect_phase( phase );

    if(  is_active == UVM_ACTIVE  )
      begin
        //connecting the sequencer and driver 
        driv.seq_item_port.connect( seqer.seq_item_export );
        `uvm_info("[axi4_agent]", $sformatf("connecting the sequencer and the driver"), UVM_LOW);
      end

  endfunction



endclass




`endif