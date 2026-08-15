`ifndef axi4_scoreboard
`define axi4_scoreboard

`include "axi4_transaction.sv"

`include "uvm_macros.svh"
import uvm_pkg ::*;


class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils( axi4_scoreboard );


uvm_analysis_imp  #( axi4_transaction , axi4_scoreboard ) analysis_port;  

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        variables                                               //
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
regarding the technique we use for the golden model:

the simplest method is just going in a circle as what we write is supposed to be
what we read
**write**
golden memory will store the written value
**read**
the golden memory will pop the stored value in expected_value which hold the expected value to be read
*/

logic [ 31 : 0 ] golden_memory [ 1023 : 0 ];
/*
1) for write we store the value of tr in golden_memory
2) for the read we push the value of the golden memory inside the expected queue 
3)so it is sort of golden_memory for both read and write
*/
logic [ 31 : 0 ] expected_value [ $ ] ; //holds the expected value to be read
logic [ 1 : 0 ] expected_resp; 
logic [ 31 : 0 ] failed_cases [ $ ] ; //will include the "number" of the test cases that fail eg. test case number 2 fail to push 2 in failed_cases

int total_cases , total_passed_cases, total_failed_cases;
real pass_percentage;


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        constructor                                              //
////////////////////////////////////////////////////////////////////////////////////////////////////


function new(string name = "axi4_scoreboard", uvm_component parent = null);
  super.new( name , parent );

  //variables
  total_cases = 0;
  total_passed_cases = 0;
  total_failed_cases = 0;
  pass_percentage = 0;

  //initializing the memory
    foreach( golden_memory[ i ] )
      begin
        golden_memory[ i ] = 32'h0000_0000;
      end


  //analysis port constructing 
  analysis_port = new("analysis_port" , this);

endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        report_phase()                                          //
////////////////////////////////////////////////////////////////////////////////////////////////////
function void report_phase(uvm_phase phase );
  super.report_phase( phase ) ;

$display("///////////////////////////////////// FINAL RESUTLS /////////////////////////////////////");
`uvm_info("[axi4_scoreboard--report_phase]", $sformatf("total number of cases: %0d", total_cases), UVM_NONE);
`uvm_info("[axi4_scoreboard--report_phase]", $sformatf("total number of passed cases: %0d", total_passed_cases), UVM_NONE);
`uvm_info("[axi4_scoreboard--report_phase]", $sformatf("total number of failed cases: %0d", total_failed_cases), UVM_NONE);

if( failed_cases.size() > 0 )
  begin
    for(  int i = 0  ;  i < failed_cases.size()  ;  i++  ) 
      begin       
          `uvm_info("[axi4_scoreboard--report_phase]", $sformatf("case number: %0d failed ", failed_cases[ i ] ), UVM_NONE);
      end
  end

if( total_cases > 0 )
  begin
      pass_percentage = real'( total_passed_cases )/ real'( total_cases )  * 100; 
      `uvm_info("[axi4_scoreboard--report_phase]", $sformatf("the percentage of the passed cases is: %0d %% ", pass_percentage ), UVM_NONE);
  end



endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        write function                                          //
////////////////////////////////////////////////////////////////////////////////////////////////////
function void write( axi4_transaction tr );

  total_cases++; //incrementing the total number of cases

  expected_value.delete(); //deleting the previous stored values
  expected_resp = 0; //making resp be the default value which is 0 --> " okay "

  golden_model( tr ); //running the golden model

  if( tr.operation == 0  ) //read
    begin
      check_read( tr );
    end
  
  if ( tr.operation == 1 ) //write
    begin
      check_write( tr );
    end

endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   golden_model function                                        //
////////////////////////////////////////////////////////////////////////////////////////////////////
function void golden_model ( axi4_transaction tr );
  if
  (
    (tr.address >> tr.size ) + (tr.length + 1 ) > 1024
  )
    begin
      expected_resp = 2'b10 ; //as this is above the 4KB boundary so the resp should be SLVERR
    end
  else
    begin
      expected_resp = 2'b00; // as we are now within the boundary so we should be "OKAY"

      if( tr.operation == 0  ) //read
        begin
          for(int i = 0  ; i <= tr.length ;i++)
            begin
              expected_value.push_back( golden_memory[ ( tr.address >> tr.size ) + i ] );
            end
        end
      
      if ( tr.operation == 1 ) //write
        begin
          for(int i = 0  ; i <= tr.length ;i++)
            begin
              golden_memory [ i + ( tr.address >> tr.size ) ] = tr.input_burst[ i ] ; 
            end
        end
    end

endfunction


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   check_read function                                          //
////////////////////////////////////////////////////////////////////////////////////////////////////
function void check_read( axi4_transaction tr );

  `uvm_info("[axi4_scoreboard--check_read]", $sformatf("checking a read operation , test number : %0d",total_cases ), UVM_LOW );

  //handeling the 4KB boundary condition
  if
  (
    (tr.address >> tr.size ) + (tr.length + 1 ) > 1024
  )
    begin
        if(  expected_resp  ==  tr.resp  ) //just checking that the expected response is the same as the actual one "both should be SLVERR"
          report_pass( total_cases , "Read" );
        else report_fail( total_cases , "Read" );
        return; //as there is no need to continue the rest of the function
    end
  
  //now we will deal with the normal case 
  if ( expected_value.size() != tr.output_burst.size() )
    begin
      report_fail( total_cases , "Read" );
      return; //as there is no need to continue the rest of the function
    end
  if(   (expected_value == tr.output_burst) && (expected_resp == tr.resp)   )
    begin
      report_pass( total_cases , "Read" );
      return; //as there is no need to continue the rest of the function
    end
  else
    begin
      report_fail( total_cases , "Read" );
      //no need to write return as we are already at the end of the function
    end
  
endfunction


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   check_write function                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////
function void check_write( axi4_transaction tr );

  `uvm_info("[axi4_scoreboard--check_write]", $sformatf("checking a write operation , test number : %0d",total_cases), UVM_LOW);

  if( tr.resp == expected_resp )
    begin
      report_pass(total_cases , "Write" );
    end
  else
    begin
      report_fail(total_cases , "Write" );
    end
endfunction



////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   report_pass function                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////
function void report_pass( int test_number , string operation_name );

  total_passed_cases++; //incrementing the number of failed cases

  `uvm_info("[axi4_scoreboard--report_pass]", $sformatf("operation %0s has passed successfully", operation_name ), UVM_LOW);
  `uvm_info("[axi4_scoreboard--report_pass]", $sformatf("test case %0d has passed successfully", total_cases), UVM_LOW);
  `uvm_info("[axi4_scoreboard--report_pass]", $sformatf("the actual response is %0d whereas the expected response is %0d ", expected_resp , expected_resp ), UVM_LOW);

endfunction


////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   report_fail function                                         //
////////////////////////////////////////////////////////////////////////////////////////////////////

function void report_fail( int test_number , string operation_name );

  total_failed_cases++; //incrementing the number of passed cases 
  failed_cases.push_back( test_number ); //pushing the number of the test case as this test case had failed 
  
  `uvm_info("[axi4_scoreboard--report_fail]", $sformatf("operation %0s has failed", operation_name ), UVM_LOW);
  `uvm_info("[axi4_scoreboard--report_fail]", $sformatf("test case %0d has failed", total_cases), UVM_LOW);

endfunction



endclass




`endif