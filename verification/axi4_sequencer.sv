`ifndef axi4_sequencer 
`define axi4_sequencer 

`include "axi4_transaction.sv"
`include "axi4_common_cfg.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;

class axi4_sequencer extends uvm_sequencer #( axi4_transaction );

  axi4_common_cfg c_cfg;

  `uvm_component_utils( axi4_sequencer );



  function new ( string name="axi4_sequencer" , uvm_component parent = null );
    super.new(  name  ,  parent  );
    `uvm_info("[axi4_sequencer]", $sformatf("INSIDE the axi4_sequencer"), UVM_LOW);
  endfunction

function void build_phase( uvm_phase phase );
  super.build_phase( phase );
  if(
    !uvm_config_db#( axi4_common_cfg ) :: get(this , "*" , c_cfg )
    )
      begin
        `uvm_fatal("[axi4_sequencer]","something is wrong as the axi4_common_cfg was not retrived sucessfully");
      end
  else
      begin
        `uvm_info("[axi4_sequencer]", "the axi4_common_cfg was retreived sucessfully" , UVM_LOW);
      end
endfunction



endclass




`endif 