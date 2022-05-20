module rom_dma_ll_intf(
								input logic 										clk,
								input logic 										reset_n,
								// rom data fifo intf //
								output logic 							 			rom_data_fifo_fifo_data_pop,
								input logic [FIFO_DATA_WIDTH-1:0] 			rom_data_fifo_fifo_data_out,
								input logic							  				rom_data_fifo_fifo_data_out_vld,
								input 									  			rom_data_fifo_fifo_full,
								input									  				rom_data_fifo_fifo_empty,
								// interface with ll_engine //
								output logic 		           				  	req_vld,
								output t_mainop_types     					  	req_main_op,
								output t_specifier_types  					  	req_spec,
								output logic [HEADPTR_ADDR_WIDTH-1:0]     req_ll_num_in,
								output logic [NODENUM_WIDTH-1:0]     	  	req_pos,
								output logic [DATA_WIDTH-1:0]  			  	req_data,
								input logic									  		intf_ready,
								input logic									  		resp_gen_cmpltd
								);
								
								
//--------------- Declarations --------------------//
typedef enum logic[2:0]{
			IDLE,
			CHK_INS_SIZE_N_RD_FIFO,
			SEND_LL_REQ_N_WAIT
} t_rom_dma_ll_intf_st;

t_rom_dma_ll_intf_st 					rom_dma_ll_intf_cur_st;
t_rom_dma_ll_intf_st 					rom_dma_ll_intf_nxt_st;
logic [3:0]									fifo_pop_cntr_for_inst_constrn;
logic [3:0]									fifo_pop_cntr_for_inst_constrn_plus1;
logic [FIFO_DATA_WIDTH-1:0] 			rom_data_fifo_fifo_data_out_int;
logic											start_inst_constrn_pop_cntr;
logic											pop_cntr_reachd_max;
logic[FIFO_DATA_WIDTH-1:0] 			fifo_data_word_int[0:NUM_OF_ROM_FIFO_RD_PER_INST-1]; 
//-------------------------------------------------//

always_comb begin
  case(fifo_data_word_int[0][7:4])
		0: req_main_op = NO_OP;
		1: req_main_op = CONFIG_HDPTR;
		2: req_main_op = READ_LL_REGS;
		3: req_main_op = INSERT;
		4: req_main_op = DELETE;
		5: req_main_op = UPDATE;
		6: req_main_op = READ_NODE;
		7: req_main_op = POP;
		8: req_main_op = EMPTY_LL;
		default: req_main_op = NO_OP;
	endcase
end

always_comb begin	
  case(fifo_data_word_int[0][3:0])
		0: req_spec = NONE;
		1: req_spec = AT_HEAD;
		2: req_spec = ALL_LIST;
		3: req_spec = SET_NUM_LL;
		4: req_spec = NO_NODES_LL;
		5: req_spec = AT_TAIL;
		6: req_spec = SPEC_LIST;
		7: req_spec = SET_HDPTR;
		8: req_spec = AT_NODE_NUM;
		9: req_spec = DEL_LL;
		default:  req_spec = NONE;
	endcase
end

//assign req_main_op = `t_mainop_types(fifo_data_word_int[0][2:0]);
//assign req_spec	 = `t_specifier_types(fifo_data_word_int[0][6:3]);
  assign req_ll_num_in = fifo_data_word_int[1][7:6];
assign req_pos			= fifo_data_word_int[1][5:2];
  assign req_data[7:6]		= fifo_data_word_int[1][1:0];
  assign req_data[5:0]		= fifo_data_word_int[2][7:2];

always_ff@(posedge clk) begin
	if(!reset_n) begin
		for(int i=0; i<NUM_OF_ROM_FIFO_RD_PER_INST; i++) begin
			fifo_data_word_int[i] <= 0;
		end
	end
	else begin 
		if(rom_data_fifo_fifo_data_out_vld & !pop_cntr_reachd_max) fifo_data_word_int[fifo_pop_cntr_for_inst_constrn] <= rom_data_fifo_fifo_data_out;
	end
end


assign fifo_pop_cntr_for_inst_constrn_plus1 = fifo_pop_cntr_for_inst_constrn + 1;
assign pop_cntr_reachd_max = (fifo_pop_cntr_for_inst_constrn == NUM_OF_ROM_FIFO_RD_PER_INST);
assign rom_data_fifo_fifo_data_pop = start_inst_constrn_pop_cntr & rom_data_fifo_fifo_data_out_vld;
/*
always_ff@(posedge clk) begin
	if(reset_n) begin
		rom_data_fifo_fifo_data_pop <= 0;
	end
	else begin 
		if(start_inst_constrn_pop_cntr & rom_data_fifo_fifo_data_out_vld) rom_data_fifo_fifo_data_pop <= 1;
		else 																					rom_data_fifo_fifo_data_pop <= 0;
	end
end*/



always_ff@(posedge clk) begin
	if(!reset_n) begin
		fifo_pop_cntr_for_inst_constrn <= 0;
	end
	else begin
		if(start_inst_constrn_pop_cntr & rom_data_fifo_fifo_data_out_vld & !pop_cntr_reachd_max) 	begin
			fifo_pop_cntr_for_inst_constrn <= fifo_pop_cntr_for_inst_constrn_plus1;
		end
		else if(resp_gen_cmpltd) fifo_pop_cntr_for_inst_constrn <= 0;
		else	begin
			fifo_pop_cntr_for_inst_constrn <= fifo_pop_cntr_for_inst_constrn;
		end
	end
end

always_ff@(posedge clk) begin
	if(!reset_n) begin
		rom_dma_ll_intf_cur_st <= IDLE;
	end
	else begin
		rom_dma_ll_intf_cur_st <= rom_dma_ll_intf_nxt_st;
	end
end

always@(*) begin
	// Defaults //
	rom_dma_ll_intf_nxt_st = rom_dma_ll_intf_cur_st;
	req_vld = 0;
	start_inst_constrn_pop_cntr = 0;
	//----------//
	
	// FSM transitions //
	case(rom_dma_ll_intf_cur_st)
		IDLE: begin
			if(rom_data_fifo_fifo_data_out_vld & intf_ready) rom_dma_ll_intf_nxt_st = CHK_INS_SIZE_N_RD_FIFO;
		end
		
		CHK_INS_SIZE_N_RD_FIFO: begin
			start_inst_constrn_pop_cntr = 1;
			if(pop_cntr_reachd_max)  rom_dma_ll_intf_nxt_st = SEND_LL_REQ_N_WAIT;
		end
		
		SEND_LL_REQ_N_WAIT: begin
			req_vld = 1;
			if(resp_gen_cmpltd)  rom_dma_ll_intf_nxt_st = IDLE;
		end
		
		default: begin
			rom_dma_ll_intf_nxt_st = IDLE;
		end
	endcase
	//-----------------//

end

endmodule // rom_dma_ll_intf.sv //