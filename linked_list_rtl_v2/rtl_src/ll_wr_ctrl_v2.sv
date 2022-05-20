module ll_wr_ctrl_v2(
						input logic 									clk,
						input logic 									reset_n,
						// i/o with ll_mngr //
						output logic									wr_ctrl_ready,
						output logic									wr_ctrl_req_taken,
						output logic									wr_ctrl_nxtptr_for_hdptr_update_vld,
						output logic [NXTPTR_MEM_WIDTH-1:0]		wr_ctrl_nxtptr_for_hdptr_update,
						input logic 									wr_ctrl_nxtptr_for_hdptr_update_taken,
						input logic										wr_ctrl_direct_wr,
						input logic										wr_ctrl_wrdata_ndptr_vld,
						input logic										wr_ctrl_wrdata_only,
						input logic [HEADPTR_WIDTH-1:0]			wr_ctrl_nodeptr_for_write,
						input logic										wr_ctrl_nodeptr_vld,
						input logic [DATAMEM_WIDTH-1:0]			wr_ctrl_data,
						input logic 									wr_ctrl_data_vld,
						input logic [DATAMEM_WIDTH-1:0]			wr_ctrl_wrback_data,
						input logic										wr_ctrl_wrback_data_vld,
						input logic [NXTPTR_MEM_WIDTH-1:0]		wr_ctrl_wrback_ptr,
						input logic										wr_ctrl_wrback_ptr_vld,
						input logic [NXTPTR_MEM_WIDTH-1:0]		wr_ctrl_ndptr_N,
						input logic [NXTPTR_MEM_WIDTH-1:0]		wr_ctrl_ndptr_Nminus2,
						input logic										wr_ctrl_del_mid_ndptrs_vld,
						// i/o with data mem //
						output logic 		  				 			data_mem_wr_vld,
						output logic [DATAMEM_ADDR_WIDTH-1:0] 	data_mem_wr_addr,
						output logic [DATAMEM_WIDTH-1:0]  		data_mem_wr_data,
						input logic 		  							data_mem_wr_done,
						// i/o with nxtptr mem //
						output logic 		  							nxtptr_mem_wr_vld,
						output logic [NXTPTR_ADDR_WIDTH-1:0]  	nxtptr_mem_wr_addr,
						output logic [NXTPTR_MEM_WIDTH-1:0]  	nxtptr_mem_wr_data,
						input logic 		  							nxtptr_mem_wr_done,						
						// i/o with ll_nxt_avail_memptr_gen //
						input logic [PTR_WD-1:0] 					nxt_ptr_out,
						input logic 		   						ll_ptrs_empty,
						output logic 		   						upd_nxt_ptr
);


//---------- Declarations -----------------//
typedef enum logic[4:0]{
				IDLE,
				WR_DATA_NXTPTR_MEM,
				WR_DATA_MEM_FOR_INS_UPD,
				WR_NXTPTR_MEMONLY_FOR_DEL_MID,
				UPD_NXT_AVAIL_PTR,
				RETURN_CUR_NXTPTR_TO_LLMNGR,
				WR_BACK_AFTER_DATA_UPDATE,
				SEND
} t_wr_ctrl_states;

t_wr_ctrl_states 	ll_wr_ctrl_cur_state;
t_wr_ctrl_states 	ll_wr_ctrl_nxt_state;
logic					wr_data_n_nxtptr;
logic					direct_write_req;
logic [DATAMEM_WIDTH-1:0] wr_ctrl_data_reg;
logic [HEADPTR_WIDTH-1:0]			wr_ctrl_nodeptr_for_write_reg;
//------------------------------------------//


//----------- internal regs ----------------------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		wr_ctrl_data_reg <= 0;
	end
	else begin
		if(wr_ctrl_data_vld) wr_ctrl_data_reg <= wr_ctrl_data;
		else if(ll_wr_ctrl_cur_state == IDLE) wr_ctrl_data_reg <= 0;
		else wr_ctrl_data_reg <= wr_ctrl_data_reg;
	end
end


always_ff@(posedge clk) begin
	if(!reset_n) begin
		wr_ctrl_nodeptr_for_write_reg <= 0;
	end
	else begin
		if(wr_ctrl_nodeptr_vld) wr_ctrl_nodeptr_for_write_reg <= wr_ctrl_nodeptr_for_write;
		else if(ll_wr_ctrl_cur_state == IDLE) wr_ctrl_nodeptr_for_write_reg <= 0;
		else wr_ctrl_nodeptr_for_write_reg <= wr_ctrl_nodeptr_for_write_reg;
	end
end
//------------------------------------------------//


//--------------------------------------------------//
//----------------- WR_CTRL FSM --------------------//
//--------------------------------------------------//
always_ff@(posedge clk ) begin
	if(!reset_n) begin
		ll_wr_ctrl_cur_state <= IDLE;
	end
	else begin
		ll_wr_ctrl_cur_state <= ll_wr_ctrl_nxt_state;
	end
end

assign wr_data_n_nxtptr = (wr_ctrl_data_vld & wr_ctrl_nodeptr_vld) & wr_ctrl_wrdata_ndptr_vld;
assign direct_write_req = wr_ctrl_direct_wr & wr_ctrl_data_vld & wr_ctrl_nodeptr_vld;

always@(*) begin
	// Defaults //
	wr_ctrl_ready = 0;
	ll_wr_ctrl_nxt_state = ll_wr_ctrl_cur_state;
	data_mem_wr_vld = 0;
	data_mem_wr_addr = 0;
	data_mem_wr_data = 0;
	nxtptr_mem_wr_vld = 0;
	nxtptr_mem_wr_addr = 0;
	nxtptr_mem_wr_data = 0;
	upd_nxt_ptr = 0;
	wr_ctrl_nxtptr_for_hdptr_update_vld = 0;
	wr_ctrl_nxtptr_for_hdptr_update = 0;
	//----------//
	
	case(ll_wr_ctrl_cur_state )
	
	
		//--------------------STATE---------------//
		IDLE: begin
			wr_ctrl_ready = 1;
			
			if(wr_data_n_nxtptr | direct_write_req) 				ll_wr_ctrl_nxt_state = WR_DATA_NXTPTR_MEM;
			if(wr_ctrl_wrdata_only) 			ll_wr_ctrl_nxt_state = WR_DATA_MEM_FOR_INS_UPD;
			if(wr_ctrl_del_mid_ndptrs_vld)	ll_wr_ctrl_nxt_state = WR_NXTPTR_MEMONLY_FOR_DEL_MID;
		end


		WR_NXTPTR_MEMONLY_FOR_DEL_MID: begin
			nxtptr_mem_wr_vld = 1;
			nxtptr_mem_wr_addr = wr_ctrl_ndptr_Nminus2;
			nxtptr_mem_wr_data = wr_ctrl_ndptr_N;	

			if(nxtptr_mem_wr_done) ll_wr_ctrl_nxt_state = IDLE;
		end
		
		//--------------------STATE---------------//
		WR_DATA_NXTPTR_MEM: begin
			data_mem_wr_vld = 1;
			data_mem_wr_addr = wr_ctrl_nodeptr_for_write_reg;
			data_mem_wr_data = wr_ctrl_data_reg;
			nxtptr_mem_wr_vld = 1;
			nxtptr_mem_wr_addr = wr_ctrl_nodeptr_for_write_reg;
			nxtptr_mem_wr_data = nxt_ptr_out;

			if(direct_write_req) begin
				data_mem_wr_vld = 1;
				data_mem_wr_addr = nxt_ptr_out;
				data_mem_wr_data = wr_ctrl_data_reg;
				nxtptr_mem_wr_vld = 1;
				nxtptr_mem_wr_addr = nxt_ptr_out;
				nxtptr_mem_wr_data = wr_ctrl_nodeptr_for_write_reg;			
			end
			
			if(data_mem_wr_done & nxtptr_mem_wr_done) begin
				if(direct_write_req) ll_wr_ctrl_nxt_state = UPD_NXT_AVAIL_PTR;
				else 						ll_wr_ctrl_nxt_state = UPD_NXT_AVAIL_PTR;
			end
		end
		
		
		RETURN_CUR_NXTPTR_TO_LLMNGR: begin
			wr_ctrl_nxtptr_for_hdptr_update_vld = 1;
			wr_ctrl_nxtptr_for_hdptr_update = nxt_ptr_out;
		
			if(wr_ctrl_nxtptr_for_hdptr_update_taken) ll_wr_ctrl_nxt_state = UPD_NXT_AVAIL_PTR;
		end
		
		//--------------------STATE---------------//
		WR_DATA_MEM_FOR_INS_UPD: begin
			data_mem_wr_vld = 1;
			data_mem_wr_addr = wr_ctrl_nodeptr_for_write_reg;
			data_mem_wr_data = wr_ctrl_data_reg;
			
			if(data_mem_wr_done) begin
				ll_wr_ctrl_nxt_state = WR_BACK_AFTER_DATA_UPDATE;
			end
		end	
		
		
		//--------------------STATE---------------//
		WR_BACK_AFTER_DATA_UPDATE: begin
			if(wr_ctrl_wrback_ptr_vld & wr_ctrl_wrback_data_vld) begin
				data_mem_wr_vld = 1;
				data_mem_wr_addr = wr_ctrl_wrback_ptr;
				data_mem_wr_data = wr_ctrl_wrback_data;
				nxtptr_mem_wr_vld = 1;
				nxtptr_mem_wr_addr = wr_ctrl_wrback_ptr;
				nxtptr_mem_wr_data = nxt_ptr_out;
			end

			if(data_mem_wr_done) begin
				ll_wr_ctrl_nxt_state = UPD_NXT_AVAIL_PTR;
			end	
		end
		
		
		//--------------------STATE---------------//
		UPD_NXT_AVAIL_PTR: begin
			upd_nxt_ptr = 1;
			wr_ctrl_nxtptr_for_hdptr_update_vld = 1;
			ll_wr_ctrl_nxt_state = IDLE;
		end
		
		
		//--------------------STATE---------------//
		default: begin
			ll_wr_ctrl_nxt_state = IDLE;
		end
	endcase
end
//--------------------------------------------------//
//--------------------------------------------------//
//--------------------------------------------------//

endmodule //------ ll_wr_ctrl_v2 --------------------//