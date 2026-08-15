//////////////////////////////////////////////////////////////////////////////////////
//         Will include only the axi ports here                                     //
//         meaning the ports connected between the memory                           //    
//         and axi will be done using normal ports not                              //
//         using an inteface                                                        //
/////////////////////////////////////////////////////////////////////////////////////

interface axi4_if
#(
parameter DATA_WIDTH = 32,
parameter ADDR_WIDTH = 16,
parameter LEN_WIDTH = 8,
parameter SIZE_WIDTH = 3
) 
();
///////////////////////////////////////////
//          Signal declarations         //
//////////////////////////////////////////



  //0-clock and reset
    logic ACLK;
    logic ARESETn;

  //1- Write address channel 
    logic [ ADDR_WIDTH - 1 : 0 ] AWADDR;
    logic [ LEN_WIDTH - 1 : 0 ] AWLEN;
    logic [ SIZE_WIDTH - 1 : 0 ] AWSIZE;
    logic AWVALID;
    logic AWREADY;



  //2- Write data channel
    logic [ DATA_WIDTH - 1 : 0 ] WDATA ;
    logic WLAST;
    logic WVALID;
    logic WREADY;


  // 3-Write responce channel
    logic [ 1 : 0 ] BRESP;
    logic BVALID;
    logic BREADY;



  //4-Read address channel
    logic [ ADDR_WIDTH - 1 : 0 ] ARADDR;
    logic [ LEN_WIDTH - 1 : 0 ] ARLEN;
    logic [ SIZE_WIDTH - 1 : 0 ] ARSIZE;
    logic ARVALID;
    logic ARREADY;    



 //5-Read data channel
  logic [ DATA_WIDTH - 1 : 0 ] RDATA;
  logic [ 1 : 0 ] RRESP;
  logic RLAST;
  logic RVALID;
  logic RREADY;


endinterface
