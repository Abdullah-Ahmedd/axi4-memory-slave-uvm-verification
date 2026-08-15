`ifndef axi4_coverage
`define axi4_coverage

`include "axi4_transaction.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;

class axi4_coverage extends uvm_component;

`uvm_component_utils( axi4_coverage );

//analysis port
uvm_analysis_imp #( axi4_transaction , axi4_coverage) analysis_port;

//transaction
axi4_transaction tr;

////////////////////////////////////////////////////////////////////////////////////////////////////
//                              coverage + cross coverage                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////
covergroup axi4_cov(ref  axi4_transaction tr);

  //coverage

    //1-length
    len:coverpoint tr.length
    {
     bins corner0 = {8'd0};
     bins corner1 = {8'd2};
     bins corner2 = {8'd2};
     bins corner3 = {8'd4};
     bins corner4 = {8'd8};
     bins corner5 = {8'd16};
     bins corner6 = {8'd32};
     bins corner7 = {8'd64};
     bins corner8 = {8'd128};
     bins corner9 = {8'd255};
     bins auto_bins [ 8 ] = { [ 8'd0 : 8'd255 ] };
    }
    //2-size
    siz: coverpoint tr.size 
    {  
      bins fixed_size = { 3'b010 };
      illegal_bins other_sizes = default;
    }
    //3-data
    dat: coverpoint tr.data
    {
      bins corner0 = { 32'h0000_0000 };
      bins corner1 = { 32'hffff_ffff };
      bins corner2 = { 32'haaaa_aaaa };
      bins corner3 = { 32'h5555_5555 };
      bins auto_bins [ 8 ] = { [ 32'h0000_0000 :32'hffff_ffff ] };
    }

    //4-address
    add: coverpoint tr.address
    {
      bins corner0 = { 16'd0 };
      bins corner1 = { 16'd1 };
      bins corner2 = { 16'd1024 };
      bins corner3 = { 16'd2048 };
      bins corner4 = { 16'd4096 };
      bins auto_bins [ 8 ] = {[ 16'd0 : 16'd65534 ]};
    }

    //5-delay
    coverpoint tr.aw_valid_delay {bins aw_valid_delayy ={[ 0 : 7 ]};}  
    coverpoint tr.w_valid_delay {bins w_valid_delayy ={[ 0 : 7 ]};} 
    coverpoint tr.ar_valid_delay {bins ar_valid_delayy ={[ 0 : 7 ]};} 
    coverpoint tr.r_ready_delay {bins r_ready_delayy ={[ 0 : 7 ]};} 
    coverpoint tr.b_ready_delay {bins b_ready_delayy ={[ 0 : 7 ]};} 
    
    //6- 4KB bounds
    coverpoint ( tr.address >> 2 )+ ( tr.length + 1 ) 
    {
      bins valid_bound = { [ 0 : 1024 ] };
      bins invalid_bound = { [ 1025 : $ ] };
    }


  //cross
    //1- len addr
    length_X_address : cross len , add;
    //2- len data
    length_X_data : cross len , dat;
    //3- data addr
    address_X_data : cross dat , add ;
    //4- size data
    data_X_size : cross siz , dat;
  
endgroup



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  constructor and phases                                        //
////////////////////////////////////////////////////////////////////////////////////////////////////

  function new (string name="axi4_coverage", uvm_component parent = null);
      super.new( name , parent);
      axi4_cov = new( tr );
      analysis_port = new("analysis_port",this);
  endfunction

  function void build_phase( uvm_phase phase );
    super.build_phase(phase);
          //analysis_port = new("analysis_port",this);
      `uvm_info("[axi4_coverage]", "INSIDE axi4_coverage build_phase", UVM_LOW);
  endfunction



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       write function                                           //
////////////////////////////////////////////////////////////////////////////////////////////////////
function void write(axi4_transaction tr_wr);

  tr = tr_wr;
  axi4_cov.sample();
  
endfunction


endclass




`endif