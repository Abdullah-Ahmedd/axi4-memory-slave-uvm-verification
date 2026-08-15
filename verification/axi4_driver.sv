`ifndef axi4_driver 
`define axi4_driver

//`include "axi4_if.sv"

`include "axi4_transaction.sv"
`include "axi4_common_cfg.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;


class axi4_driver extends uvm_driver #( axi4_transaction );

  `uvm_component_utils(axi4_driver);

  virtual axi4_if vif;
  axi4_common_cfg c_cfg;

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          constructor                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////

  function new (  string name = "axi4_driver" ,  uvm_component parent = null  );
    super.new ( name , parent );
      `uvm_info("[axi4_driver]", $sformatf("inside axi4_driver"), UVM_LOW);
  endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          build_phase                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////  
  function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    
    if
    (
      !uvm_config_db#( virtual axi4_if ) :: get(this , "*" , "vif" , vif)
    )
      begin
        `uvm_fatal("[axi4_driver]", $sformatf("the interface was not retreived correctly"));
      end
    else
      begin
        `uvm_info("[axi4_driver]", $sformatf("the interface was retreived successfully"), UVM_LOW);
      end

    if
    (
      !uvm_config_db#( axi4_common_cfg ) :: get(this , "*" , "c_cfg" , c_cfg)
    )
      begin
        `uvm_fatal("[axi4_driver]", $sformatf("the common config was not retreived correctly"));
      end
    else
      begin
        `uvm_info("[axi4_driver]", $sformatf("the common config was retreived successfully"), UVM_LOW);
      end

  endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       reset task                                               //
////////////////////////////////////////////////////////////////////////////////////////////////////

task reset_signals();

    //0-clock and reset
    vif.ARESETn = 0;

  //1- Write address channel 
    vif.AWADDR = 0 ;
    vif.AWLEN = 0;
    vif.AWSIZE = 0;
    vif.AWVALID = 0;

  //2- Write data channel
    vif.WDATA = 0;
    vif.WLAST = 0;
    vif.WVALID = 0;

  // 3-Write responce channel
    vif.BREADY = 0;

  //4-Read address channel
    vif.ARADDR = 0;
    vif.ARLEN = 0;
    vif.ARSIZE = 0;
    vif.ARVALID = 0;    

 //5-Read data channel
  vif.RREADY = 0;

  //will wait for 2 clock cycles then turn off the reset
    repeat( 2 ) @( posedge vif.ACLK );
  //turning on the reset
    vif.ARESETn = 1;
  //will wait for two more clock cycles before we end the task to make sure the reset had been propgated correctly
    repeat( 2 ) @( posedge vif.ACLK );
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           drive task                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////
task drive ( axi4_transaction req );
  if( req.operation == 0 ) //read
    begin
      drive_read( req );
    end
  else if( req.operation == 1 ) //write
    begin
      drive_write( req );
    end
    c_cfg.current_tr = req;
    ->c_cfg.stimulus_done;
endtask

task drive_read (axi4_transaction req_read );
  repeat( req_read.ar_valid_delay ) @( negedge vif.ACLK ); //just waiting the randomized delay amount
      vif.ARADDR = req_read.address;
      vif.ARLEN = req_read.length;
      vif.ARSIZE = req_read.size;
      vif.ARVALID = 1'b1;

      while ( !vif.ARREADY  )
        begin
          @( negedge vif.ACLK );
        end

         @( negedge vif.ACLK );
        vif.ARVALID = 1'b0;
endtask

task drive_write ( axi4_transaction req_write );
  //storing the randomization in the input_burst
  for( int i = 0 ; i <= req_write.length ; i ++ )
    begin
        assert( req_write.randomize(data) )
          else `uvm_fatal("[axi4_driver]", $sformatf("there is a problem with randomization"));
          req_write.input_burst.push_back( req_write.data );
    end
    //waiting for delay
    repeat(req_write.aw_valid_delay) @(negedge vif.ACLK);
      vif.AWADDR = req_write.address;
      vif.AWLEN = req_write.length;
      vif.AWSIZE = req_write.size;
      vif.AWVALID = 1'b1;

    while ( !vif.AWREADY )
        begin
          @( negedge vif.ACLK );
        end

        @( negedge vif.ACLK );
        vif.AWVALID = 1'b0; 

        //now we will start driving data from input_burst to vif
        // the inputting will depend on if the 
        if(  (  req_write.address >> req_write.size  )  +  (  req_write.length + 1  )  > 1024 ) //the trnafser size is above the 4KB
          begin
             //waiting for delay
              repeat(req_write.w_valid_delay) @(negedge vif.ACLK);
            //we will just store the first burst as we cant store all
              vif.WDATA = req_write.input_burst[ 0 ];
              vif.WVALID = 1'b1;
              vif.WLAST = 1'b1;

              //waiting for WREADY
                while ( !vif.WREADY )
                    begin
                      @( negedge vif.ACLK );
                    end

                  @( negedge vif.ACLK );             
            
          end

        else //below the 4KB boundary
          begin
             //applying delay before we start write phase
              repeat(req_write.w_valid_delay) @(negedge vif.ACLK);
            for( int i = 0 ; i <= req_write.length ; i ++ )
              begin
                  vif.WDATA = req_write.input_burst[ i ];
                  vif.WVALID = 1'b1;
                  vif.WLAST = (i == req_write.length ); 
                  
                ///waiting  for WREADY
                while( !vif.WREADY )
                    begin
                      @( negedge vif.ACLK );
                    end

                    @( negedge vif.ACLK );
                    
                    if( i < req_write.length )
                      begin
                            // generating a random delay for every beat
                            assert( req_write.randomize(w_valid_delay) )
                              else `uvm_fatal("[axi4_driver]", $sformatf("there was a problem with randomizing w_valid_delay for every beat "));
                              vif.WVALID = 1'b0;
                          //applying delay before every write beat
                          repeat(req_write.w_valid_delay) @(negedge vif.ACLK);

                      end
              end
         
          end

      vif.WVALID = 1'b0;
      vif.WLAST = 1'b0;        

endtask


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            run_phase                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////
task run_phase(uvm_phase phase);

  //resetting signals
  reset_signals();

  forever
    begin
        axi4_transaction tr;

        seq_item_port.get_next_item(tr);
        
        drive(tr);
        
        seq_item_port.item_done();
    end

endtask


endclass












`endif