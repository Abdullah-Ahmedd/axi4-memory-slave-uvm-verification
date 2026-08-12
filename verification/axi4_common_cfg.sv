`ifndef axi4_common_cfg
`define axi4_common_cfg


`include "axi4_transaction.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;

class axi4_common_cfg extends uvm_object;

  `uvm_object_utils( axi4_common_cfg );

  event stimulus_done;
  event monitor_done;


  axi4_transaction current_tr;


  function new ( string name="axi4_common_cfg" );

    super.new( name );
      `uvm_info("[axi4_common_cfg]", "INSIDE axi4_common_cfg CLASS", UVM_LOW );

  endfunction


endclass


`endif