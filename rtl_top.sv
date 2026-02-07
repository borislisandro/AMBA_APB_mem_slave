//==========================================
//  Module: rtl_top
//  Description: AMBA APB Memory Slave + 128x32 Memory Module
//  Author: Boris Teixeira
//  Date: 01/18/2026
//==========================================
module rtl_top #(parameter ADDR_WIDTH = 7, parameter DATA_WIDTH = 32)
(
  input  logic                   i_rst_n   ,
  input  logic                   i_clk     ,
  input  logic [ADDR_WIDTH-1 :0] i_PADDR   ,
  input  logic                   i_PWRITE  ,
  input  logic                   i_PSEL    ,
  input  logic                   i_PENABLE ,
  input  logic [DATA_WIDTH-1 :0] i_PWDATA  ,
  output logic                   o_PREADY  ,
  output logic [DATA_WIDTH-1 :0] o_PRDATA  ,
  output logic                   o_PSLVERR   
);

  // Internal signals
  logic [ADDR_WIDTH-1 :0] mem_addr ;
  logic [DATA_WIDTH-1 :0] mem_wdata;
  logic                   mem_we   ;
  logic [DATA_WIDTH-1 :0] mem_rdata;
  logic mem_err;

  apb_mem_slave #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) u_apb_mem_slave (
    .i_rst_n     (i_rst_n)   ,
    .i_clk       (i_clk)     ,
    .i_PADDR     (i_PADDR)   ,
    .i_PWRITE    (i_PWRITE)  ,
    .i_PSEL      (i_PSEL)    ,
    .i_PENABLE   (i_PENABLE) ,
    .i_PWDATA    (i_PWDATA)  ,
    .i_mem_rdata (mem_rdata) ,
    .i_mem_err   (mem_err)   ,
    .o_PREADY    (o_PREADY)  ,
    .o_PRDATA    (o_PRDATA)  ,
    .o_PSLVERR   (o_PSLVERR) ,
    .o_mem_addr  (mem_addr)  ,
    .o_mem_wdata (mem_wdata) ,
    .o_mem_we    (mem_we)
  );

  mem_128x32 #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) u_mem_128x32 (
    .i_rst_n (i_rst_n)   ,
    .i_clk   (i_clk)     ,
    .i_we    (mem_we)    ,
    .i_addr  (mem_addr)  ,
    .i_data  (mem_wdata) ,
    .o_data  (mem_rdata) ,
    .o_mem_err(mem_err)
  );

endmodule : rtl_top