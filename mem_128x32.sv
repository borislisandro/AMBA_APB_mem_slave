//==========================================
//  Module: mem_128x32
//  Description: 128x32-bit memory with synchronous write and combinational read
//  Author: Boris Teixeira
//  Date: 01/18/2026
//==========================================
module mem_128x32 #(parameter ADDR_WIDTH = 7, parameter DATA_WIDTH = 32)
(
  input  logic                  i_rst_n     ,
  input  logic                  i_clk       ,
  input  logic                  i_we        ,
  input  logic [ADDR_WIDTH-1:0] i_addr      ,
  input  logic [DATA_WIDTH-1:0] i_data      ,
  output logic [DATA_WIDTH-1:0] o_data      ,
  output logic                  o_mem_err
);

  // Declare a memory array of 128 words, each 32 bits wide
  logic [DATA_WIDTH-1:0] mem_array [0:(2**ADDR_WIDTH)-1] = '{default:{DATA_WIDTH{1'b0}}};

  // Defines whether the location is read-only or read-write
  // 0 - Read-Only 
  // 1 - Write-Only
  logic rw_policy [0:(2**ADDR_WIDTH)-1] = '{default:1'b1};

  // Synchronous write operation
  always_ff @(posedge i_clk) begin : wr_proc
    if (!i_rst_n) begin
      // Reset logic 
      integer i;
      for (i = 0; i < (2**ADDR_WIDTH); i = i + 1) begin
        mem_array[i] <= i;
        if(i < (2**ADDR_WIDTH)/2) begin
          // First half locations are Read-Only
          rw_policy[i] <= 1'b0;
        end else begin
          // Default all locations to Read-Write
          rw_policy[i] <= 1'b1;
        end
      end
    end else if (i_we && rw_policy[i_addr]) begin
      mem_array[i_addr] <= i_data;
    end
  end : wr_proc

  // Combinational read operation
  always_comb begin : rd_proc
    o_data = mem_array[i_addr];
  end : rd_proc

  assign o_mem_err = (!rw_policy[i_addr] && i_we) ? 1'b1 : 1'b0;
  
endmodule : mem_128x32