module rom_dma_ctrl(
								input logic 								clk,
								input logic 								reset_n,
								// input fifo interface //
								output logic [FIFO_DATA_WIDTH-1:0] 	rom_data_fifo_fifo_data_in,
								output logic 							  	rom_data_fifo_fifo_data_push,
								input 									  	rom_data_fifo_fifo_full,
								input									  	  	rom_data_fifo_fifo_empty,
								// interface with ROM //
								output logic [ROM_ADDR_WIDTH-1:0]	rom_rd_addr,
								output logic 								CE_bar,
								output logic								OE_bar,
								output logic								WE_bar,
								input logic [ROM_DATA_WIDTH-1:0]		rom_rd_data,
								// dma config in //
								input logic									start_rd,
								input logic									cfg_ready,
								input logic [ROM_ADDR_WIDTH-1:0]		cfg_dma_base_addr,
								input logic [ROM_ADDR_WIDTH-1:0]		cfg_dma_num_bytes,
								output logic								batch_dma_done
								);
								
								
//------------ Declarations ------------------//
localparam  CYC_FOR_STABILIZATION = 8;
localparam  STABILIZATION_CNTR_WIDTH = $clog2(CYC_FOR_STABILIZATION);
typedef enum logic[2:0]{
		IDLE,
		READ_SEQ_START,
		FIFO_PUSH
} t_rom_dma_states;

t_rom_dma_states 														rom_dma_cur_st;
t_rom_dma_states 														rom_dma_nxt_st;
logic [ROM_ADDR_WIDTH-1:0] 										addr_cntr_int;
logic [ROM_ADDR_WIDTH-1:0] 										addr_cntr_int_plus1;
logic 																	wait_for_rd_data_stabilization;
logic	[STABILIZATION_CNTR_WIDTH-1:0]							stabilization_cntr;
logic	[STABILIZATION_CNTR_WIDTH-1:0]							stabilization_cntr_plus1;
logic [ROM_DATA_WIDTH-1:0]											rom_rd_data_in;
logic [ROM_ADDR_WIDTH-1:0]											cfg_dma_base_addr_int;
//--------------------------------------------//

// Notes: one cycle = 20 ns
//			 CE_bar is set to high (as default) will put rom in standby: OE_bar and WE_var are high//
//        read sequence: set WE_bar to high, place addr on bus and make CE_bar and OE_bar low //
//			 write sequence: 

assign stabilization_cntr_plus1 = stabilization_cntr + 1;
assign rd_data_stbl = (stabilization_cntr == 7) ? 1: 0;

always_ff@(posedge clk) begin
	if(!reset_n) begin
		stabilization_cntr <= 0;
	end
	else begin
		if(wait_for_rd_data_stabilization ) stabilization_cntr <= stabilization_cntr_plus1;
		else if(rom_dma_cur_st == IDLE)														  stabilization_cntr <= 0;
		else																stabilization_cntr <= stabilization_cntr;
	end

end

always_ff@(posedge clk) begin
	if(!reset_n) begin
		rom_rd_data_in <= 0;
	end
	else begin
		if(rd_data_stbl) 								rom_rd_data_in <= rom_rd_data;
		else if(rom_dma_cur_st == IDLE) 			rom_rd_data_in <= 0;
		else				  								rom_rd_data_in <= rom_rd_data_in;
	end

end

assign addr_cntr_int_plus1 = addr_cntr_int + 1;
assign batch_dma_done = (addr_cntr_int == cfg_dma_num_bytes);


always_ff@(posedge clk) begin
	if(!reset_n) begin
		addr_cntr_int <= 0;
		cfg_dma_base_addr_int <= 0;
	end
	else begin
		if(!start_rd & !cfg_ready) begin
			addr_cntr_int <= 0;
			cfg_dma_base_addr_int <= cfg_dma_base_addr;
		end
		else if(rom_data_fifo_fifo_data_push == 1) begin
			addr_cntr_int <= addr_cntr_int_plus1;
			cfg_dma_base_addr_int <= cfg_dma_base_addr_int;
		end
		else begin
			addr_cntr_int <= addr_cntr_int;
			cfg_dma_base_addr_int <= cfg_dma_base_addr_int;
		end
	end

end

always_ff@(posedge clk) begin
	if(!reset_n) begin
		rom_dma_cur_st <= IDLE;
	end
	else begin
		rom_dma_cur_st <= rom_dma_nxt_st;
	end
end


always@(*) begin
	// Default //
	rom_dma_nxt_st = rom_dma_cur_st;
	CE_bar = 1;
	OE_bar = 1;
	WE_bar = 1;
	rom_rd_addr = 0;
	rom_data_fifo_fifo_data_in = 0;
	rom_data_fifo_fifo_data_push = 0;
	wait_for_rd_data_stabilization = 0;
	//---------//

	// FSM transitions //
	case(rom_dma_cur_st)
		IDLE: begin
          if(start_rd & cfg_ready & !batch_dma_done) rom_dma_nxt_st = READ_SEQ_START;
		end
		
		READ_SEQ_START: begin
			// after 20 ns //
			CE_bar = 0;
			OE_bar = 0;
			WE_bar = 1;
			rom_rd_addr = addr_cntr_int + cfg_dma_base_addr_int;
			wait_for_rd_data_stabilization = 1;
			
			if(rd_data_stbl) rom_dma_nxt_st = FIFO_PUSH;
		end
	
		FIFO_PUSH: begin
			if(!rom_data_fifo_fifo_full) begin
				rom_data_fifo_fifo_data_in = rom_rd_data_in;
				rom_data_fifo_fifo_data_push = 1;
				rom_dma_nxt_st = IDLE;
			end
			else begin
				rom_data_fifo_fifo_data_in = rom_rd_data_in;
				rom_data_fifo_fifo_data_push = 0;
				rom_dma_nxt_st = FIFO_PUSH;			
			end
		end
		
		default: begin
			rom_dma_nxt_st = IDLE;
		end
	endcase
	//-----------------//
end

endmodule // rom_dma_ctrl.sv //