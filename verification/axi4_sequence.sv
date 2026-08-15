`ifndef axi4_sequence
`define axi4_sequence

`include "axi4_transaction.sv"
`include "axi4_common_cfg.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;

class axi4_sequence extends uvm_sequence #( axi4_transaction );

  `uvm_object_utils( axi4_sequence );

  //number of transactions
  parameter NUM_TRANSACTIONS = 50;

  axi4_common_cfg c_cfg;

  function new ( string name = "axi4_sequence" );
    super.new( name );
    `uvm_info("[axi4_sequence]", $sformatf("INSIDE the axi4_sequence"), UVM_LOW);
  endfunction

  task body();

         axi4_transaction tr;

         if
      (
        !uvm_config_db#( axi4_common_cfg ) :: get(null , get_full_name() , "c_cfg" ,c_cfg)
      )
        begin
          `uvm_fatal("[axi4_sequence]", $sformatf("the axi4_common_cfg could not be retreived sucessfully"));
        end
      else
        begin
            `uvm_info("[axi4_sequence]", $sformatf("the axi4_common_cfg was retreived sucessfully "), UVM_LOW );
        end

    repeat( NUM_TRANSACTIONS )
        begin
          tr= axi4_transaction::type_id::create("tr");

          start_item( tr );

          assert( tr.randomize() )
          else `uvm_fatal("[axi4_sequence]", $sformatf("transaction randomization failed"));

          finish_item( tr );

          //will wait not to start the next randomization till the we make sure the monitor has seen the new values
          @( c_cfg.monitor_done );
        end
        `uvm_info("[axi4_sequence]", $sformatf("axi4_sequence has finished generating the trnasactions"), UVM_NONE);

  endtask



endclass




`endif