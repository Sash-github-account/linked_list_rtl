module ll_rd_ctrl_v2(
							input logic 										clk,
							input logic 										reset_n,
							// interface with ll_mngr //
							output logic										rd_ctrl_ready,
							input logic 										rd_ctrl_traverse_ll,
							input logic											rd_ctrl_single_rd_req,
							input logic											rd_ctrl_traverse_ll_wrback_data,
							input logic											rd_ctrl_send_wrback_reg_value,
							input logic [HEADPTR_WIDTH-1:0]				rd_ctrl_ll_node_cnt,
							input logic [HEADPTR_WIDTH-1:0] 				rd_ctrl_ll_ptr,
							output logic [NXTPTR_MEM_WIDTH-1:0] 		rd_ctrl_nxtptr_N_rd_data,
							output logic [NXTPTR_MEM_WIDTH-1:0] 		rd_ctrl_nxtptr_Nminus1_rd_data,
							output logic [NXTPTR_MEM_WIDTH-1:0] 		rd_ctrl_nxtptr_Nminus2_rd_data,							
							output logic 										rd_ctrl_upd_nxtptr_for_mid_node_del,
							input logic											rd_ctrl_traverse_ll_for_middle_node_del,
							output logic [HEADPTR_WIDTH-1:0]				rd_ctrl_nxtptr_value,
							output logic										rd_ctrl_nxtptr_vld,
							output logic [DATAMEM_WIDTH-1:0]				rd_ctrl_data_value,
							output logic										rd_ctrl_data_vld,
							output logic [NXTPTR_MEM_WIDTH-1:0]			rd_ctrl_wrback_ptr,
							output logic										rd_ctrl_wrback_ptr_vld,
							input logic 										ll_mngr_resp_taken,
							// interface with nxtptrMem //
							output logic 		  								nxtptr_mem_rd_vld,
							output logic [NXTPTR_ADDR_WIDTH-1:0]  		nxtptr_mem_rd_addr,
							input logic [NXTPTR_MEM_WIDTH-1:0] 			nxtptr_mem_rd_data,
							input logic 		  								nxtptr_mem_rd_data_out_vld,
							// interface with dataMem   //
							output logic 		  								data_mem_rd_vld,
							output logic [DATAMEM_ADDR_WIDTH-1:0]  	data_mem_rd_addr,
							input logic [DATAMEM_WIDTH-1:0] 				data_mem_rd_data,
							input logic 		  								data_mem_rd_data_out_vld
							);
							
							
//---------------- Declarations ------------------//
typedef enum logic[4:0]{
		IDLE,//0
		TRAVERSE_NXPTR_MEM,//1
		RD_DATAMEM_STR_WRBACK,//2
		READ_SINGLE_NXTPTR_MEM,//3
		RESP_TO_LL_MANAGER//4
} t_ll_rd_ctrl_state;

t_ll_rd_ctrl_state 					ll_rd_ctrl_cur_state;
t_ll_rd_ctrl_state 					ll_rd_ctrl_nxt_state;
logic [HEADPTR_WIDTH-1:0] 			nxtptr_rd_cntr;
logic [HEADPTR_WIDTH:0] 			nxtptr_rd_cntr_plus1;
logic										rd_cntr_update;
logic [DATAMEM_WIDTH-1:0] 			rd_data_wrback_reg;
logic 		  							rd_data_wrback_reg_vld;
logic [NXTPTR_MEM_WIDTH-1:0] 		rd_nxtptr_wrback_reg;
logic [NXTPTR_MEM_WIDTH-1:0] 		rd_nxtptr_prev_addr_reg;
logic 		  							rd_nxtptr_wrback_reg_vld;
logic										rd_ctrl_traverse_req;
logic										rd_ctrl_traverse_req_reg;
logic										rd_ctrl_traverse_ll_reg;
logic [NXTPTR_ADDR_WIDTH-1:0]  	nxtptr_mem_rd_addr_int;
logic [NXTPTR_ADDR_WIDTH-1:0]  	rd_nxtptr_prev_reg;
logic [NXTPTR_MEM_WIDTH-1:0] 		nd_ptr_at_N;
logic [NXTPTR_MEM_WIDTH-1:0] 		nd_ptr_at_Nmin1;
logic [NXTPTR_MEM_WIDTH-1:0] 		nd_ptr_at_Nmin2;
logic [HEADPTR_WIDTH-1:0]			rd_ctrl_ll_node_cnt_int;
//---------------------------------//


// Counter for traversing nodes //
assign nxtptr_rd_cntr_plus1 = nxtptr_rd_cntr + 1;
assign rd_cntr_update = (ll_rd_ctrl_nxt_state == TRAVERSE_NXPTR_MEM)  & nxtptr_mem_rd_data_out_vld;
assign rd_ctrl_traverse_req = rd_ctrl_traverse_ll | rd_ctrl_traverse_ll_wrback_data | 	rd_ctrl_traverse_ll_for_middle_node_del;

always_ff@(posedge clk) begin
	if(!reset_n) begin
		rd_ctrl_traverse_ll_reg <= 0;
	end
	else begin
		if(rd_ctrl_traverse_ll) 					rd_ctrl_traverse_ll_reg <= 1;
		else if(ll_rd_ctrl_cur_state == IDLE)  rd_ctrl_traverse_ll_reg <= 0;
		else												rd_ctrl_traverse_ll_reg <= rd_ctrl_traverse_ll_reg;
	end
end


always_ff@(posedge clk) begin
	if(!reset_n) begin
		rd_ctrl_ll_node_cnt_int <= 0;
		rd_ctrl_traverse_req_reg <= 0;
	end
	else begin
		if(rd_ctrl_traverse_req) begin
			rd_ctrl_ll_node_cnt_int <=  rd_ctrl_ll_node_cnt;
			rd_ctrl_traverse_req_reg <= 1;
		end	
		else begin
			rd_ctrl_ll_node_cnt_int <=  rd_ctrl_ll_node_cnt_int;
			if(ll_rd_ctrl_cur_state == IDLE) rd_ctrl_traverse_req_reg <= 0;
			else 							 rd_ctrl_traverse_req_reg <= rd_ctrl_traverse_req_reg;
		end
	end
end


always_ff@(posedge clk ) begin
	if(!reset_n) begin
		nxtptr_rd_cntr <= 0;
	end
	else begin
		if(rd_cntr_update) begin
			nxtptr_rd_cntr <= nxtptr_rd_cntr_plus1;
		end
		else if(ll_rd_ctrl_nxt_state == IDLE) begin
			nxtptr_rd_cntr <= 0;			
		end
		else begin
			nxtptr_rd_cntr <= nxtptr_rd_cntr;		
		end
	end
end
//-------------------------------//


// nxtptr addr generation for node traversing //

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		nxtptr_mem_rd_addr_int <= 0;
	end
	else begin
		if(nxtptr_rd_cntr == 0) begin
			nxtptr_mem_rd_addr_int <= rd_ctrl_ll_ptr;	
		end
		else begin
			if(nxtptr_mem_rd_data_out_vld) begin
				nxtptr_mem_rd_addr_int <= nxtptr_mem_rd_data;	
			end
		end
	end
end


always_ff@(posedge clk ) begin
	if(!reset_n) begin
		rd_nxtptr_prev_reg <= 0;
		rd_nxtptr_prev_addr_reg <= 0;
	end
	else begin
		if(nxtptr_mem_rd_data_out_vld) begin
			rd_nxtptr_prev_reg <= nxtptr_mem_rd_addr_int;
		end
		if(nxtptr_mem_rd_vld)	begin
			rd_nxtptr_prev_addr_reg <= nxtptr_mem_rd_addr;
		end	
	end
end
//---------------------------------------//


//------- write back reg ----------------//

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		rd_data_wrback_reg <= 0;
		rd_data_wrback_reg_vld <= 0;
	end
	else begin
		if((ll_rd_ctrl_cur_state == RD_DATAMEM_STR_WRBACK) & data_mem_rd_data_out_vld) begin
			rd_data_wrback_reg <= data_mem_rd_data;
			rd_data_wrback_reg_vld <= 1;			
		end
		else if(ll_rd_ctrl_nxt_state == IDLE) begin
			rd_data_wrback_reg_vld <= 0;			
		end
		else begin
			rd_data_wrback_reg <= rd_data_wrback_reg;
			rd_data_wrback_reg_vld <= rd_data_wrback_reg_vld;			
		end
	end 
end

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		rd_nxtptr_wrback_reg <= 0;
		rd_nxtptr_wrback_reg_vld <= 0;
	end
	else begin
		if((ll_rd_ctrl_nxt_state == RD_DATAMEM_STR_WRBACK) & nxtptr_mem_rd_data_out_vld) begin
			rd_nxtptr_wrback_reg <= nxtptr_mem_rd_data;
			rd_nxtptr_wrback_reg_vld <= 1;			
		end
		else if(ll_rd_ctrl_nxt_state == IDLE) begin
			rd_nxtptr_wrback_reg_vld <= 0;			
		end
		else begin
			rd_nxtptr_wrback_reg <= rd_nxtptr_wrback_reg;
			rd_nxtptr_wrback_reg_vld <= rd_nxtptr_wrback_reg_vld;			
		end
	end 
end
//---------------------------------------//


//-------------- node ptr at N, N-1, N-2 for del_at_node_num op ----------------//
logic level_delMidNode;

assign nd_ptrs_upd_en = rd_ctrl_traverse_ll_for_middle_node_del & (ll_rd_ctrl_cur_state != IDLE);


pulse_to_level i_p2l_delMidNode(
								  .clk(clk),
								  .reset_n(reset_n),
								  .pulse(nd_ptrs_upd_en),
								  .enable((ll_rd_ctrl_cur_state != IDLE)),
								  .clear((ll_rd_ctrl_nxt_state == RESP_TO_LL_MANAGER)),
								  .level(level_delMidNode)
								);

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		nd_ptr_at_N <= 0;
		nd_ptr_at_Nmin1 <= 0;
		nd_ptr_at_Nmin2 <= 0;
	end
	else begin
		if(level_delMidNode & nxtptr_mem_rd_data_out_vld) begin
			nd_ptr_at_N <= nxtptr_mem_rd_data;
			nd_ptr_at_Nmin1 <= nd_ptr_at_N;
			nd_ptr_at_Nmin2 <= nd_ptr_at_Nmin1;
		end
		else if(ll_rd_ctrl_cur_state == IDLE) begin
			nd_ptr_at_N <= 0;
			nd_ptr_at_Nmin1 <= 0;
			nd_ptr_at_Nmin2 <= 0;		
		end
		else begin
			nd_ptr_at_N <= nd_ptr_at_N;
			nd_ptr_at_Nmin1 <= nd_ptr_at_Nmin1;
			nd_ptr_at_Nmin2 <= nd_ptr_at_Nmin2;		
		end
	end
end

//----------------------------------------//


//------------------ RD ctrl FSM ---------------------//
always_ff@(posedge clk ) begin
	if(!reset_n) begin
		ll_rd_ctrl_cur_state <= IDLE;
	end
	else begin
		ll_rd_ctrl_cur_state <= ll_rd_ctrl_nxt_state;
	end
end


always@(*) begin
	//---- Defaults -----//
	ll_rd_ctrl_nxt_state = ll_rd_ctrl_cur_state;
	rd_ctrl_ready = 0;
	data_mem_rd_vld = 0;
	data_mem_rd_addr = 0;
	nxtptr_mem_rd_vld = 0;
	nxtptr_mem_rd_addr = 0;
	rd_ctrl_nxtptr_value = 0;
	rd_ctrl_nxtptr_vld = 0;
	rd_ctrl_data_value = 0;
	rd_ctrl_data_vld = 0;
	rd_ctrl_wrback_ptr = 0;
	rd_ctrl_wrback_ptr_vld = 0;
	rd_ctrl_upd_nxtptr_for_mid_node_del = 0;
	rd_ctrl_nxtptr_N_rd_data = 0;
	rd_ctrl_nxtptr_Nminus1_rd_data = 0;
	rd_ctrl_nxtptr_Nminus2_rd_data = 0;
	//---------------//



	//--------------------- FSM transitions -------------------------------//	
	case(ll_rd_ctrl_cur_state)
		//--------------------STATE---------------//
		IDLE: begin
			rd_ctrl_ready = 1;
			if(rd_ctrl_traverse_req) 	ll_rd_ctrl_nxt_state = TRAVERSE_NXPTR_MEM;
			if(rd_ctrl_single_rd_req) 	ll_rd_ctrl_nxt_state = READ_SINGLE_NXTPTR_MEM;
		end
		
		
		//--------------------STATE---------------//
		TRAVERSE_NXPTR_MEM: begin
			nxtptr_mem_rd_addr = nxtptr_mem_rd_addr_int;
			nxtptr_mem_rd_vld = 1;				
			
			if((nxtptr_rd_cntr == rd_ctrl_ll_node_cnt_int) & !rd_ctrl_traverse_ll_for_middle_node_del) begin
				if(rd_ctrl_traverse_ll_reg) 									ll_rd_ctrl_nxt_state = RESP_TO_LL_MANAGER;
				else if(rd_ctrl_traverse_ll_wrback_data)				ll_rd_ctrl_nxt_state = RD_DATAMEM_STR_WRBACK;
			end
			else if(rd_ctrl_traverse_ll_for_middle_node_del & (nxtptr_rd_cntr == rd_ctrl_ll_node_cnt_int + 3))	ll_rd_ctrl_nxt_state = RESP_TO_LL_MANAGER;

		end
		
		
		//--------------------STATE---------------//
		RD_DATAMEM_STR_WRBACK: begin
			data_mem_rd_vld = 1;
			data_mem_rd_addr = nxtptr_mem_rd_addr_int;
			nxtptr_mem_rd_vld = 1;
			nxtptr_mem_rd_addr = nxtptr_mem_rd_addr_int;
			
			if(rd_nxtptr_wrback_reg_vld & rd_data_wrback_reg_vld)	ll_rd_ctrl_nxt_state = RESP_TO_LL_MANAGER;
		end
		
		
		//--------------------STATE---------------//
		READ_SINGLE_NXTPTR_MEM: begin
			nxtptr_mem_rd_vld = 1;
			nxtptr_mem_rd_addr = rd_ctrl_ll_ptr;
			if(nxtptr_mem_rd_data_out_vld) ll_rd_ctrl_nxt_state = RESP_TO_LL_MANAGER;
		end
		
		
		//--------------------STATE---------------//
		RESP_TO_LL_MANAGER: begin
			rd_ctrl_nxtptr_value = nxtptr_mem_rd_addr_int;
			rd_ctrl_nxtptr_vld = 1;
			
			if(rd_ctrl_send_wrback_reg_value & rd_data_wrback_reg_vld & rd_nxtptr_wrback_reg_vld) begin
				rd_ctrl_data_value = rd_data_wrback_reg;
				rd_ctrl_data_vld = 1;
				rd_ctrl_wrback_ptr = rd_nxtptr_wrback_reg;
				rd_ctrl_wrback_ptr_vld = 1;				
			end
			else if (rd_ctrl_traverse_ll_for_middle_node_del) begin
				rd_ctrl_upd_nxtptr_for_mid_node_del = 1;
				rd_ctrl_nxtptr_N_rd_data = nd_ptr_at_N;
				rd_ctrl_nxtptr_Nminus1_rd_data = nd_ptr_at_Nmin1;
				rd_ctrl_nxtptr_Nminus2_rd_data = nd_ptr_at_Nmin2;
			end
			
			if(ll_mngr_resp_taken)  ll_rd_ctrl_nxt_state = IDLE;
		end
		
		
		//--------------------STATE---------------//
		default: begin
			 ll_rd_ctrl_nxt_state = IDLE;
		end
		
	endcase
end
//-------------------------------------------------------------------------//
							
							
							
endmodule // ll_rd_ctrl_v2