//==========================================
//  Module: apb_mem_slave
//  Description: AMBA APB Memory Slave Interface
//  Author: Boris Teixeira
//  Date: 01/22/2026
//==========================================
module apb_mem_slave #(parameter ADDR_WIDTH = 7, parameter DATA_WIDTH = 32)
(
  input  logic                   i_rst_n    ,
  input  logic                   i_clk      ,
  input  logic [ADDR_WIDTH-1 :0] i_PADDR    ,
  input  logic                   i_PWRITE   ,
  input  logic                   i_PSEL     ,
  input  logic                   i_PENABLE  ,
  input  logic [DATA_WIDTH-1 :0] i_PWDATA   ,
  input  logic [DATA_WIDTH-1 :0] i_mem_rdata,
  input  logic                   i_mem_err  ,
  output logic                   o_PREADY   ,
  output logic [DATA_WIDTH-1 :0] o_PRDATA   ,
  output logic                   o_PSLVERR  ,
  output logic [ADDR_WIDTH-1 :0] o_mem_addr ,
  output logic [DATA_WIDTH-1 :0] o_mem_wdata,
  output logic                   o_mem_we   
);

  // State encoding
  localparam IDLE    = 1'b0,
             CMD_END = 1'b1;


  // State machine register
  reg cstate, nstate;

  // APB registers - captured during setup phase
  reg                   we_reg  ;
  reg [ADDR_WIDTH-1 :0] addr_reg;
  reg [DATA_WIDTH-1 :0] data_reg;

  // Next state combinational signals
  logic mem_we_next;
  logic mem_rd_next;

  assign mem_we_next = i_PSEL && i_PWRITE;
  assign mem_rd_next = i_PSEL && !i_PWRITE;

  // =================
  // = State Machine =
  // =================
  always_ff @(posedge i_clk) begin : state_proc
    if (!i_rst_n) begin
      cstate <= IDLE;
    end else begin
      cstate <= nstate;
    end
  end : state_proc

  always_comb begin : next_state_proc
    nstate = cstate;
    case (cstate)
      IDLE: begin
        if (i_PSEL && !i_PENABLE) begin
          nstate = CMD_END;
        end
      end
   
      CMD_END: begin
        nstate = IDLE;
      end
      
      default: nstate = IDLE;
    endcase
  end : next_state_proc

  // ====================
  // = Sequential Logic =
  // ====================
  always_ff @(posedge i_clk) begin : posedge_logic_proc
    if (!i_rst_n) begin
      we_reg   <= 1'b0;
      addr_reg <= {ADDR_WIDTH{1'b0}};
      data_reg <= {DATA_WIDTH{1'b0}};
      o_PREADY <= 1'b0;
    end else begin
      case (cstate)
		
        IDLE: begin
          if(mem_we_next) begin
			   o_PREADY <= 1'b1; // Ready for write
            addr_reg <= i_PADDR;
            data_reg <= i_PWDATA;
            we_reg   <= 1'b1;
          end else if(mem_rd_next) begin
			   o_PREADY <= 1'b1;
            addr_reg <= i_PADDR;
            we_reg   <= 1'b0;
			 end else begin
            o_PREADY <= 1'b0;
            we_reg   <= 1'b0;
          end
        end
		  
        CMD_END: begin
          we_reg   <= 1'b0;
          o_PREADY <= 1'b0;
        end
		  
      endcase
    end
  end : posedge_logic_proc

  // ==============================
  // = Combinational Output Logic =
  // ==============================
  assign o_mem_addr  = addr_reg;
  assign o_mem_wdata = data_reg;
  assign o_mem_we    = we_reg;
  
  assign o_PRDATA    = (o_PREADY && !we_reg) ? i_mem_rdata : {DATA_WIDTH{1'b0}};
  assign o_PSLVERR   = (i_mem_err && i_PSEL);

endmodule : apb_mem_slave
