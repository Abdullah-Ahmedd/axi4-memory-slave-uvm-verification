`ifndef axi4_env
`define axi4_env


`include "axi4_agent.sv"
`include "axi4_scoreboard.sv"
`include "axi4_coverage.sv"

`include "uvm_macros.svh"
import uvm_pkg :: *;


class axi4_env extends uvm_env;

  `uvm_component_utils( axi4_env );


  axi4_agent agt;
  axi4_scoreboard sb;
  axi4_coverage cov;

  function new(  string name = "axi4_env " ,  uvm_component parent = null  );
    super.new( name , parent );

    `uvm_info("[axi4_env]", $sformatf("INSIDE the constructor of axi4_env"), UVM_LOW);

  endfunction

  function void build_phase ( uvm_phase phase );
    super.build_phase( phase );

    //building agent
    agt = axi4_agent :: type_id :: create("agt" , this );
    //building scoreboard
    sb = axi4_scoreboard :: type_id :: create ("sb" , this );
    //building coverage 
    cov = axi4_coverage :: type_id :: create("cov" , this );

  endfunction

 function void connect_phase ( uvm_phase phase );
  super.connect_phase( phase );

  //connecting the monitor and coverage directly
  agt.mon.analysis_port.connect( cov.analysis_port );

 //connecting the monitor and scoreboard directly
  agt.mon.analysis_port.connect( sb.analysis_port );
  
 endfunction 


endclass


`endif 