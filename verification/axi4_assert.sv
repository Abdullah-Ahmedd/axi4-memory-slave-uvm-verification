`ifndef axi4_assert
`define axi4_assert

`include "axi4_if.sv"

`include "uvm_macros.svh"
import uvm_pkg :: *;


module axi4_assert ( axi4_if vif  );

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     RESET ASSERTIONS                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////



  property AWREADY_reset;
    @( posedge vif.ACLK ) !vif.ARESETn |-> vif.AWREADY == 1'b1;
  endproperty

  AWREADY_rst_assert: assert property ( AWREADY_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of AWREADY after reset"));
  AWREADY_rst_coverage: cover property ( AWREADY_reset );


  
  property WREADY_reset;
    @( posedge vif.ACLK ) !vif.ARESETn |-> vif.WREADY == 1'b0;
  endproperty

  WREADY_rst_assert: assert property ( WREADY_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of WREADY after reset"));
  WREADY_rst_coverage: cover property ( WREADY_reset ); 
  
 
  
  property BRESP_reset;
    @( posedge vif.ACLK ) !vif.ARESETn |-> vif.BRESP == 2'b00;
  endproperty

  BRESP_reset_assert: assert property ( BRESP_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of BRESP after reset"));
  BRESP_reset_coverage: cover property ( BRESP_reset ); 



  property BVALID_reset;
    @( posedge vif.ACLK ) !vif.ARESETn |-> vif.BVALID == 1'b0;
  endproperty

  BVALID_reset_assert: assert property ( BVALID_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of BVALID after reset"));
  BVALID_reset_coverage: cover property ( BVALID_reset );   



property ARREADY_reset;
  @( posedge vif.ACLK ) !vif.ARESETn |-> vif.ARREADY == 1'b1;
endproperty

  ARREADY_reset_assert: assert property ( ARREADY_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of ARREADY after reset"));
  ARREADY_reset_coverage: cover property ( ARREADY_reset ); 



property RDATA_reset;
  @( posedge vif.ACLK ) !vif.ARESETn |-> vif.RDATA == 32'h0000_0000;
endproperty

  RDATA_reset_assert: assert property ( RDATA_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of RDATA after reset"));
  RDATA_reset_coverage: cover property ( RDATA_reset );   



property RRESP_reset;
  @( posedge vif.ACLK ) !vif.ARESETn |-> vif.RRESP == 2'b00;
endproperty

  RRESP_reset_assert: assert property ( RRESP_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of RRESP after reset"));
  RRESP_reset_coverage: cover property ( RRESP_reset );     



property RVALID_reset;
  @( posedge vif.ACLK ) !vif.ARESETn |-> vif.RVALID == 1'b0;
endproperty

  RVALID_reset_assert: assert property ( RVALID_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of RVALID after reset"));
  RVALID_reset_coverage: cover property ( RVALID_reset );       



property RLAST_reset;
  @( posedge vif.ACLK ) !vif.ARESETn |-> vif.RLAST == 1'b0;
endproperty

  RLAST_reset_assert: assert property ( RLAST_reset )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of RLAST after reset"));
  RLAST_reset_coverage: cover property ( RLAST_reset );  



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     AWREADY ASSERTIONS                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////



//AWREADY should go low on the clock cycle next to the one when AWVALID && AWREADY are high 
property AWVALID_AWREADY;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  (vif.AWVALID && vif.AWREADY) |=> ( vif.AWREADY == 1'b0 );
endproperty

  AWVALID_AWREADY_assert: assert property ( AWVALID_AWREADY )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of AWVALID_AWREADY "));
  AWVALID_AWREADY_coverage: cover property ( AWVALID_AWREADY );  

 
  
//all writr signals should remain stable at the writing stage (AWVALID && ! AWREADY)
property AWADDR_STABLE;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.AWVALID && !vif.AWREADY ) |=> ( $stable( vif.AWADDR ) );
endproperty

  AWADDR_STABLE_assert: assert property ( AWADDR_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of AWADDR_STABLE "));
  AWADDR_STABLE_coverage: cover property ( AWADDR_STABLE ); 

 
property AWLEN_STABLE;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.AWVALID && !vif.AWREADY ) |=> ( $stable( vif.AWLEN ) );
endproperty

  AWLEN_STABLE_assert: assert property ( AWLEN_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of AWLEN_STABLE "));
  AWLEN_STABLE_coverage: cover property ( AWLEN_STABLE );  


property AWSIZE_STABLE;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.AWVALID && !vif.AWREADY ) |=> ( $stable( vif.AWSIZE ) );
endproperty

  AWSIZE_STABLE_assert: assert property ( AWSIZE_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of AWLEN_STABLE "));
  AWSIZE_STABLE_coverage: cover property ( AWSIZE_STABLE );  




////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     WDATA ASSERTIONS                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////

//WDATA should be stable on the clock cycle of writing which is the clock cycle next to the clock cycle 
//where WVALID && !WREADY (exactly same concept as the above assertions)
property WDATA_STABLE;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.AWVALID && !vif.AWREADY ) |=> ( $stable( vif.WDATA ) );
endproperty

  WDATA_STABLE_assert: assert property ( WDATA_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of WDATA_STABLE "));
  WDATA_STABLE_coverage: cover property ( WDATA_STABLE );




////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     WLAST ASSERTIONS                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////  
//WLAST SHOULD BE ASSERTED 0 AT LAST one clock cycle after it become high
property WLAST_AT_LAST;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.WREADY && vif.WVALID && vif.WLAST ) |=> (  !vif.WLAST  );
endproperty

  WLAST_AT_LAST_assert: assert property ( WLAST_AT_LAST )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of WLAST_AT_LAST "));
  WLAST_AT_LAST_coverage: cover property ( WLAST_AT_LAST );

 
 
////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BVALID ASSERTIONS                                           //
//////////////////////////////////////////////////////////////////////////////////////////////////// 


//BVALID SHOULD BE HIGH AFTER WLAST WVALID WREADY
property BVALID_ASSERT;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( $rose( vif.BVALID ) ) |-> ( $past( vif.WREADY && vif.WVALID && vif.WLAST )  );
endproperty

  BVALID_ASSERT_assert: assert property ( BVALID_ASSERT )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of BVALID_ASSERT "));
  BVALID_ASSERT_coverage: cover property ( BVALID_ASSERT );



//"The slave can assert the BVALID signal only when it drives a valid 
//write response. BVALID must remain asserted until the master accepts the write response and asserts BREADY"
property BVALID_DEASSERT;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.BVALID && vif.BREADY ) |=> ( !vif.BVALID  );
endproperty

  BVALID_DEASSERT_assert: assert property ( BVALID_DEASSERT )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of BVALID_DEASSERT "));
  BVALID_DEASSERT_coverage: cover property ( BVALID_DEASSERT );


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BRESP ASSERTIONS                                             //
////////////////////////////////////////////////////////////////////////////////////////////////////   
//BRESP should be stable when BVALID AND BREADY IS HIGH
property BRESP_STABLE;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.BVALID && vif.BREADY ) |-> ( $stable( vif.BRESP )  );
endproperty

  BRESP_STABLE_assert: assert property ( BRESP_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of BRESP_STABLE"));
  BRESP_STABLE_coverage: cover property ( BRESP_STABLE );



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     ARREADY ASSERTIONS                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////



//ARREADY should go low on the clock cycle next to the one when ARVALID && ARREADY are high 
property ARVALID_AWREADY;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  (vif.ARVALID && vif.ARREADY) |=> ( vif.ARREADY == 1'b0 );
endproperty

  ARVALID_AWREADY_assert: assert property ( ARVALID_AWREADY )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of ARVALID_AWREADY"));
  ARVALID_AWREADY_coverage: cover property ( ARVALID_AWREADY );   


//all read signals should remain stable at the reading stage (ARVALID && ! ARREADY)
property ARADDR_STABLE;
  @( negedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.ARVALID && !vif.ARREADY ) |=> ##[ 1 : $ ] ( $stable( vif.ARADDR ) );
endproperty

  ARADDR_STABLE_assert: assert property ( ARADDR_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of ARADDR_STABLE "));
  ARADDR_STABLE_coverage: cover property ( ARADDR_STABLE ); 

 
property ARLEN_STABLE;
  @( negedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.ARVALID && !vif.ARREADY ) |=> ( $stable( vif.ARLEN ) );
endproperty

  ARLEN_STABLE_assert: assert property ( ARLEN_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of ARLEN_STABLE "));
  ARLEN_STABLE_coverage: cover property ( ARLEN_STABLE );  


property ARSIZE_STABLE;
  @( negedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.ARVALID && !vif.ARREADY ) |=> ( $stable( vif.ARSIZE ) );
endproperty

  ARSIZE_STABLE_assert: assert property ( ARSIZE_STABLE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of ARLEN_STABLE "));
  ARSIZE_STABLE_coverage: cover property ( ARSIZE_STABLE );  



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    RVALID ASSERTIONS                                           //
//////////////////////////////////////////////////////////////////////////////////////////////////// 



//RVALID SHOULD BE HIGH AFTER WLAST WVALID WREADY
property RVALID_ASSERT;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  (  vif.RVALID && !vif.RREADY ) |=> (  vif.RVALID );
endproperty

  RVALID_ASSERT_assert: assert property ( RVALID_ASSERT )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of RVALID_ASSERT "));
  RVALID_ASSERT_coverage: cover property ( RVALID_ASSERT );  




////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     RLAST ASSERTIONS                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////  
//RLAST SHOULD BE ASSERTED 0 AT LAST one clock cycle after it become high
property RLAST_AT_LAST;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.RREADY && vif.RVALID && vif.RLAST ) |=> (  !vif.RLAST  );
endproperty

  RLAST_AT_LAST_assert: assert property ( RLAST_AT_LAST )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of RLAST_AT_LAST "));
  RLAST_AT_LAST_coverage: cover property ( RLAST_AT_LAST );

 

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     BRESP ASSERTIONS                                           //
//////////////////////////////////////////////////////////////////////////////////////////////////// 
//BRESP SHOULD BE OKAY OR SLVERR ON THE NEXT CLOCK CYCLE WHEN BVALID && BREADY
property BRESP_ASSERT;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.BVALID && vif.BREADY ) |-> (  vif.BRESP ==2'b00 || vif.BRESP ==2'b10  );
endproperty

  BRESP_ASSERT_assert: assert property ( BRESP_ASSERT )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of BRESP_ASSERT "));
  BRESP_ASSERT_coverage: cover property ( BRESP_ASSERT );



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     4KB_CHECK ASSERTIONS                                       //
////////////////////////////////////////////////////////////////////////////////////////////////////   
//Checking that a write with a 4KB would make BRESP == SLVERR
property boundary_4KB_WRITE;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.BVALID && ( ( vif.AWADDR >> vif.AWSIZE ) + ( vif.AWLEN + 1 ) > 1024 ) ) |-> (  vif.BRESP == 2'b10  );
endproperty

  boundary_4KB_WRITE_assert: assert property ( boundary_4KB_WRITE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of boundary_4KB_WRITE "));
  boundary_4KB_WRITE_coverage: cover property ( boundary_4KB_WRITE );

//Checking that a read with a 4KB would make BRESP == SLVERR
property boundary_4KB_READ;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.RVALID && ( ( vif.ARADDR >> vif.ARSIZE ) + ( vif.ARLEN + 1 ) > 1024 ) ) |-> (  vif.RRESP == 2'b10  );
endproperty

  boundary_4KB_READ_assert: assert property ( boundary_4KB_READ )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of boundary_4KB_READ "));
  boundary_4KB_READ_coverage: cover property ( boundary_4KB_READ );  



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    MEMORY_RANGE_CHECK ASSERTIONS                               //
////////////////////////////////////////////////////////////////////////////////////////////////////
//Checking that a write with an out of memory range would make BRESP == SLVERR
property MEMORY_RANGE_WRITE;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.BVALID && ( ( vif.AWADDR >> vif.AWSIZE ) >= 1024 ) ) |-> (  vif.BRESP == 2'b10  );
endproperty

  MEMORY_RANGE_WRITE_assert: assert property ( MEMORY_RANGE_WRITE )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of MEMORY_RANGE_WRITE "));
  MEMORY_RANGE_WRITE_coverage: cover property ( MEMORY_RANGE_WRITE ); 

//Checking that a read with an out of memory range would make BRESP == SLVERR
property MEMORY_RANGE_READ;
  @( posedge vif.ACLK ) disable iff( !vif.ARESETn )
  ( vif.RVALID && ( ( vif.ARADDR >> vif.ARSIZE ) >= 1024 ) ) |-> (  vif.RRESP == 2'b10  );
endproperty

  MEMORY_RANGE_READ_assert: assert property ( MEMORY_RANGE_READ )
  else `uvm_error("[axi4_assert]", $sformatf("There is a problem with the assertion of MEMORY_RANGE_READ "));
  MEMORY_RANGE_READ_coverage: cover property ( MEMORY_RANGE_READ );   


endmodule 



`endif