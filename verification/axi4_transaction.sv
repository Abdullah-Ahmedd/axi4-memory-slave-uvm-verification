`ifndef axi4_transaction
`define axi4_transaction



`include "uvm_macros.svh"
import uvm_pkg ::*;

class axi4_transaction extends uvm_sequence_item;



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        signals declaration                                     //
////////////////////////////////////////////////////////////////////////////////////////////////////

  //important input signals that need randomization
    rand logic [ 15 : 0 ] address;
    rand logic [ 31 : 0 ] data;
    rand logic [ 2 : 0 ] size;
    rand logic [ 7 : 0 ] length;
  //variable to determine the operation is read or write 
    rand logic [ 1 : 0 ] operation; //operation = 0 ---read --- , operation = 1 --- write ---
  //will randomize the delay of valid signals so see how the design behave when these input signals are late
    rand logic [ 2 : 0 ] aw_valid_delay;
    rand logic [ 2 : 0 ] w_valid_delay;
    rand logic [ 2 : 0 ] ar_valid_delay;
    rand logic [ 2 : 0 ] r_ready_delay;
    rand logic [ 2 : 0 ] b_ready_delay;
  // will declare two queues one to store the burst input data and one to store the output burst data 
    logic [ 31 : 0 ] input_burst [ $ ]; //will be needed in driver
    logic [ 31 : 0 ] output_burst [ $ ]; // will be needed in monitor 
  //declaring a variable for responce to be able store the resp
  logic [ 1 : 0 ] resp; //will be needed in the monitor
  //variable to determine the address is a normal address or a corner case
    rand int unsigned address_mode; //address_mode = 0 --- normal --- , address_mode=1 --- corner case ---
  //variable to determine the data is a  normal data or a corner case
    rand int unsigned data_mode; //data_mode = 0,1,2  --- normal --- , data_mode = 1 --- corner case --- //did more than one normal as the range of the data is large and we want to cover it all
  //variable to determine the len is a  normal len or a corner case
    rand int unsigned len_mode; //len_mode = 0  --- normal --- , len_mode = 1 --- corner case ---
  //variable to determine the operation is bleow 4kB or no
    rand int unsigned below_4; //below_4 = 1  --- normal --- , below_4 = 0 --- below case ---


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        constraints                                             //
////////////////////////////////////////////////////////////////////////////////////////////////////    

//1- operation constraint
constraint operation_c
{  operation dist { 1 := 50  , 0 := 50 };  }

//2- delay constraint
constraint delay_c
{
            //reasonable range of the delay is 0 to 7 clock cycles
aw_valid_delay inside { [ 0 : 7 ] };  
w_valid_delay inside { [ 0 : 7 ] };  
ar_valid_delay inside { [ 0 : 7 ] };  
r_ready_delay inside { [ 0 : 7 ] };  
b_ready_delay inside { [ 0 : 7 ] }; 
}

//3- size constraint
constraint size_c
{
size == 3'b010; //to make sure the bytes in transfer is 4KB as required
}

//4-below 4KB
constraint below_4_range_c
{
below_4 dist {  1 := 80  ,  0:=20  };
}
constraint below_4_normal
{
  if( below_4 == 1 )
    ( address >> 2 ) + ( length + 1 ) <= 1024;
}
constraint below_4_corner
{
  if( below_4 == 0 )
    ( address >> 2 ) + ( length + 1 ) > 1024;
}

//5-len constraint
constraint len_mode_c
{
len_mode dist {  0 := 80  ,  1 := 20  };
}
constraint len_normal
{
  if(len_mode == 0 )  
    length inside { [ 8'd0 : 8'd255 ] };
}
constraint len_corner
{
  if(len_mode == 1 )
    length inside { 8'd0 , 8'd1 , 8'd2 , 8'd4 , 8'd8 , 8'd16 , 8'd32 , 8'd64 , 8'd128 , 8'd255 };
}

//6- address constraint 
constraint address_mode_c
{
address_mode dist { 0 := 80  ,  1 := 20 };
}
constraint address_normal
{
  if( address_mode == 0 )
    address inside { [ 16'd0 : 16'd65534 ] };
}
constraint address_corner
{
  if( address_mode == 1 )
    address inside { 16'd0 , 16'd1 , 16'd1024 , 16'd2048 ,16'd4096 };
}
//7- data constraint 
constraint data_mode_c
{
data_mode dist { 0 := 30 ,  1 := 30 , 2 := 30 , 3 := 10  };
}
constraint data_normal_c0
{
if(  data_mode == 0  )
data inside {[ 32'h0000_0000 : 32'hffff_ffff ]}; //normal full range
}
constraint data_normal_c1
{
if(  data_mode == 1  )
data inside 
{
  [ 32'h0000_0000 : 32'h0000_00ff ] , //only one byte active
  [ 32'h0000_0000 : 32'h0000_ffff ], //only two bytes active
  [ 32'h0000_0000 : 32'h00ff_ffff ], //only three bytes active
  [ 32'h0000_0000 : 32'hffff_ffff ] //only four bytes active
}; 
}
constraint data_normal_c2
{
if(  data_mode == 2  )
data inside 
{
  [ 32'h0000_0000 : 32'h0000_000f ] , //small range of zeros
  [ 32'hffff_fff0 : 32'hffff_ffff ] //small rnage of ones
}; 
}
constraint data_corner
{
if(  data_mode == 3  )
data inside 
{
32'h0000_0000, //all zeros
32'hffff_ffff ,//all ones
32'haaaa_aaaa , //alternating 101010
32'h5555_5555  //inverse alternating 0101010
}; 
}


//uvm_object_utils_begin
`uvm_object_utils_begin ( axi4_transaction )
  //normal input signals 
    `uvm_field_int(address, UVM_DEFAULT);
    `uvm_field_int(data, UVM_DEFAULT);
    `uvm_field_int(size, UVM_DEFAULT);
    `uvm_field_int(length, UVM_DEFAULT);
  //delay signals
    `uvm_field_int(aw_valid_delay, UVM_DEFAULT);
    `uvm_field_int(aw_valid_delay, UVM_DEFAULT);
    `uvm_field_int(ar_valid_delay, UVM_DEFAULT);
    `uvm_field_int(r_ready_delay, UVM_DEFAULT);
    `uvm_field_int(b_ready_delay, UVM_DEFAULT);

`uvm_object_utils_end

//constructor
function new(string name ="axi4_transaction");
  super.new(name);
    `uvm_info("[axi4_transaction]", "INSIDE axi4_transaction", UVM_LOW);
endfunction


endclass



`endif