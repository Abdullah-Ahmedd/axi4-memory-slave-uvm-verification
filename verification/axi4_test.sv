`ifndef axi4_test
`define axi4_test


`include "axi4_sequence.sv"
`include "axi4_env.sv"
`include "axi4_common_cfg.sv"


class axi4_test extends uvm_test;
    `uvm_component_utils( axi4_test );

    axi4_sequence seq;
    axi4_env env;
    axi4_common_cfg c_cfg;

    function new (  string name = "axi4_test" , uvm_component parent );
        super.new( name , parent );

        `uvm_info("[axi4_test]", $sformatf("INSIDE axi4_test constructor"), UVM_LOW );    
    endfunction

    function  void build_phase( uvm_phase phase );
        super.build_phase( phase );
		
		//building the c_cfg
		c_cfg = new("c_cfg");

        //building the sequence
            seq = axi4_sequence :: type_id :: create( "seq" , this ); 
        //building the environment
            env = axi4_env :: type_id :: create( "env" ,  this );
        //setting the common config
            uvm_config_db #( axi4_common_cfg ) :: set( this , "*" , "c_cfg" , c_cfg );
    endfunction

task run_phase (uvm_phase phase );

        phase.raise_objection( this );

        seq.start(env.agt.seqer); //////////////////////////////////////////////////////////////////////////////////

        phase.drop_objection ( this ) ;
endtask    

endclass

`endif