`timescale 1ns/1ps // Specify the time scale

module tb_top;

  parameter ADDR_WIDTH = 7 ;
  parameter DATA_WIDTH = 32;

  // Clock and Reset 
  reg clk   = 1'b0;
  reg rst_n = 1'b0;
  
  // APB Interface Signals
  reg [ADDR_WIDTH-1:0]  PADDR   = '0  ;
  reg                   PWRITE  = 1'b0;
  reg                   PSEL    = 1'b0;
  reg                   PENABLE = 1'b0;
  reg [DATA_WIDTH-1:0]  PWDATA  = '0  ;
  wire                  PREADY;
  wire [DATA_WIDTH-1:0] PRDATA;
  wire                  PSLVERR;

  // Instantiate rtl_top
  rtl_top #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) u_rtl_top (
    .i_rst_n   (rst_n),
    .i_clk     (clk),
    .i_PADDR   (PADDR),
    .i_PWRITE  (PWRITE),
    .i_PSEL    (PSEL),
    .i_PENABLE (PENABLE),
    .i_PWDATA  (PWDATA),
    .o_PREADY  (PREADY),
    .o_PRDATA  (PRDATA),
    .o_PSLVERR (PSLVERR)
  );

  // Clock generation
  always #5 clk = ~clk;
  
  // Test sequence
  initial begin
    // Dump VCD file
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_top);
    
    // Initialize
    $display("Starting APB Memory Test");
    repeat(2) @(posedge clk);
    
    // Release reset
    @(posedge clk) rst_n = 1'b1;
    repeat(2) @(posedge clk);
    
    // Test 1: Write to address 0x00
    $display("Test 1: Write 0xDEADBEEF to address 0x00");
    apb_write(7'h00, 32'hDEADBEEF);

    repeat(2) @(posedge clk);
    
    // Test 2: Read from address 0x00
    $display("Test 2: Read from address 0x00");
    apb_read(7'h00);
    
    repeat(2) @(posedge clk);

    // Test 3: Write to address 0x10
    $display("Test 3: Write 0xCAFEBABE to address 0x10");
    apb_write(7'h10, 32'hCAFEBABE);
    
    repeat(2) @(posedge clk);

    // Test 4: Read from address 0x10
    $display("Test 4: Read from address 0x10");
    apb_read(7'h10);
    
    repeat(2) @(posedge clk);

    // Test 5: Write to address 0x7F (last valid address)
    $display("Test 5: Write 0x12345678 to address 0x7F");
    apb_write(7'h7F, 32'h12345678);
    
    repeat(2) @(posedge clk);

    // Test 6: Read from address 0x7F
    $display("Test 6: Read from address 0x7F");
    apb_read(7'h7F);
    
    repeat(2) @(posedge clk);

    // Test 7: Verify address 0x00 still has original data
    $display("Test 7: Re-read from address 0x00");
    apb_read(7'h00);
    
    repeat(5) @(posedge clk);
    $display("All tests completed");
    $finish; // End the simulation
  end
  
  // Task for APB Write Transaction
  task apb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
    begin
      @(posedge clk);
      PADDR   <= addr;
      PWRITE  <= 1'b1;
      PSEL    <= 1'b1;
      PENABLE <= 1'b0;
      PWDATA  <= data;
      
      @(posedge clk);
      PENABLE <= 1'b1;

      @(posedge PREADY);
      @(posedge clk);
      PSEL    <= 1'b0;
      PENABLE <= 1'b0;
      $display("  Write complete: addr=0x%0h, data=0x%0h", addr, data);
      @(posedge clk);
    end
  endtask
  
  // Task for APB Read Transaction
  task apb_read(input [ADDR_WIDTH-1:0] addr);
    begin
      @(posedge clk);
      PADDR   <= addr;
      PWRITE  <= 1'b0;
      PSEL    <= 1'b1;
      PENABLE <= 1'b0;
      
      @(posedge clk);
      PENABLE <= 1'b1;

      @(posedge PREADY);
      $display("  Read complete: addr=0x%0h, data=0x%0h", addr, PRDATA);
      @(posedge clk);
      PSEL    <= 1'b0;
      PENABLE <= 1'b0;
      @(posedge clk);
    end
  endtask
  
endmodule: tb_top