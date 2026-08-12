`timescale 1ns/1ps 

`include "axi4_if.sv"
`include "axi4_pkg.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;

import axi4_pkg ::*;

module axi4_tb;
//parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 16;
    parameter MEMORY_DEPTH = 1024;
    parameter LEN_WIDTH = 8;
    parameter SIZE_WIDTH = 3;


//interface instantiation
axi4_if 
(
.DATA_WIDTH ( DATA_WIDTH ),
.ADDR_WIDTH ( ADDR_WIDTH ),
.LEN_WIDTH ( LEN_WIDTH ),
.SIZE_WIDTH ( SIZE_WIDTH )
)
vif
();

//DUT instantiation
axi4 
#(   
   .DATA_WIDTH ( DATA_WIDTH ),
   .ADDR_WIDTH ( ADDR_WIDTH ),
   .MEMORY_DEPTH ( MEMORY_DEPTH )   
  )
DUT
(
    .ACLK( vif.ACLK ),
    .ARESETn( vif.ARESETn ),

    // Write address channel
   .AWADDR( vif.AWADDR ),
   .AWLEN( vif.AWLEN ),
   .AWSIZE( vif.AWSIZE ),
   .AWVALID( vif.AWVALID ),
   .AWREADY( vif.AWREADY ),

    // Write data channel
    .WDATA( vif.WDATA ),
    .WVALID( vif.WVALID ),
    .WLAST( vif.WLAST ),
    .WREADY( vif.WREADY ),

    // Write response channel
    .BRESP( vif.BRESP ),
    .BVALID( vif.BVALID ),
    .BREADY( vif.BREADY ),

    // Read address channel
    .ARADDR( vif.ARADDR ),
    .ARLEN( vif.ARLEN ),
    .ARSIZE( vif.ARSIZE ),
    .ARVALID( vif.ARVALID ),
    .ARREADY( vif.ARREADY ),

    // Read data channel
   .RDATA( vif.RDATA ),
   .RRESP( vif.RRESP ),
   .RVALID( vif.RVALID ),
   .RLAST( vif.RLAST ),
   .RREADY( vif.RREADY )
);

//assertions instantiation
axi4_assertions check
( vif );

//clock generation
initial
  begin
    vif.ACLK = 0 ; //inital value of the clock
      forever
        begin
          #5 vif.ACLK = ~ vif.ACLK; //clock period is 10ns
        end
  end

//config and run tests
initial
  begin
    //config the interface 
    uvm_config_db #( virtual vif ) :: set("*","axi4_if", vif);

    //run tests
    run_test("axi4_test");
  end


endmodule
