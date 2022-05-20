module ll_mngr(
	      input logic 										clk,
	      input logic 										reset_n,
	      // requests from operation decoder ll_op_decode_unit //
			input logic 										req_del_node_at_node_num,
			input logic 										req_del_node_at_head,
			input logic 										req_del_node_at_tail,
			input logic 										req_add_node_at_node_num,
			input logic 										req_add_node_at_head,
			input logic 										req_add_node_at_tail,
	      input logic 										req_rd_ll_reg,
			input logic											req_cfg_delete_ll,
			input logic [NUM_LL_WIDTH-1:0] 				req_ll_num,
			input logic [DATAMEM_WIDTH-1:0]				req_data,
			input logic											req_cfg_num_actv_ll,
			input logic											req_cfg_set_hdptr,
			input logic [NODENUM_WIDTH-1:0]				req_hdptr_cfgrd_ndnum_value,
			input logic [NODENUM_WIDTH-1:0]				req_middle_node_pos,
			output logic 										ll_mngr_fsm_idle,
			output logic 										req_taken,
			// signals to nxt_avail_memptr_gen fo disabling avail ptrs corresponding to cfgd. hdptr //
			output logic [PTR_WD-1:0] 						hdptr_cfg_value,
			output logic 										hdptr_cfg_value_vld,
			output logic [PTR_WD-1:0]						pos_2_return_nxt_ptr,
			output logic 		   							return_nxt_ptr,
			// i/o to rd_ctrl //
			input logic 										rd_ctrl_ready,
			output logic										rd_ctrl_single_rd_req,
			output logic										rd_ctrl_traverse_ll,
			output logic										rd_ctrl_traverse_ll_for_middle_node_del,
			output logic										rd_ctrl_traverse,
			output logic 										rd_ctrl_count_down_nxtptr,
			output logic										rd_ctrl_traverse_ll_wrback_data,
			output logic										rd_ctrl_send_wrback_reg_value,
			output logic [HEADPTR_WIDTH-1:0]				rd_ctrl_ll_node_cnt,
			output logic [HEADPTR_WIDTH-1:0] 			rd_ctrl_ll_ptr,
			input logic [HEADPTR_WIDTH-1:0]				rd_ctrl_nxtptr_value,
			input logic											rd_ctrl_nxtptr_vld,
			input logic [DATAMEM_WIDTH-1:0]				rd_ctrl_data_value,
			input logic											rd_ctrl_data_vld,
			input logic [NXTPTR_MEM_WIDTH-1:0]			rd_ctrl_wrback_ptr,
			input logic											rd_ctrl_wrback_ptr_vld,
			output logic 										ll_mngr_resp_taken,
			input logic 										rd_ctrl_upd_nxtptr_for_mid_node_del,
			input logic [NXTPTR_MEM_WIDTH-1:0] 			rd_ctrl_nxtptr_N_rd_data,
			input logic [NXTPTR_MEM_WIDTH-1:0] 			rd_ctrl_nxtptr_Nminus1_rd_data,
			input logic [NXTPTR_MEM_WIDTH-1:0] 			rd_ctrl_nxtptr_Nminus2_rd_data,
			// i/o wr_ctrl //
			output logic										wr_ctrl_wrdata_ndptr_vld,
			output logic										wr_ctrl_direct_wr,
			output logic 										wr_ctrl_nxtptr_for_hdptr_update_taken,
			input logic											wr_ctrl_ready,
			input logic											wr_ctrl_req_taken,
			input logic											wr_ctrl_nxtptr_for_hdptr_update_vld,
			input logic [NXTPTR_MEM_WIDTH-1:0]			wr_ctrl_nxtptr_for_hdptr_update,
			output logic [HEADPTR_WIDTH-1:0]				wr_ctrl_nodeptr_for_write,
			output logic										wr_ctrl_nodeptr_vld,
			output logic [DATAMEM_WIDTH-1:0]				wr_ctrl_data,
			output logic 										wr_ctrl_data_vld,
			output logic										wr_ctrl_writeback_seq,
			output logic [DATAMEM_WIDTH-1:0]				wr_ctrl_wrback_data,
			output logic										wr_ctrl_wrback_data_vld,
			output logic [NXTPTR_MEM_WIDTH-1:0]			wr_ctrl_wrback_ptr,
			output logic										wr_ctrl_wrback_ptr_vld,
			output logic [NXTPTR_MEM_WIDTH-1:0]			wr_ctrl_ndptr_N,
			output logic [NXTPTR_MEM_WIDTH-1:0]			wr_ctrl_ndptr_Nminus2,
			output logic										wr_ctrl_del_mid_ndptrs_vld,
			// i/o to ll node counter mem //
			output logic 		  								node_cntr_wr_vld,
			output logic [HEADPTR_ADDR_WIDTH-1:0]  	node_cntr_wr_addr,
			output logic [HEADPTR_WIDTH-1:0]  			node_cntr_wr_data,
			input logic 		  								node_cntr_wr_done,	
			output logic 		  								node_cntr_rd_vld,
			output logic [HEADPTR_ADDR_WIDTH-1:0]  	node_cntr_rd_addr,
			input logic [HEADPTR_WIDTH-1:0] 				node_cntr_rd_data,
			input logic 		  								node_cntr_rd_data_out_vld,
			// output to HDPTR mem //
			output logic 		  								hdptr_wr_vld,
			output logic [HEADPTR_ADDR_WIDTH-1:0]  	hdptr_wr_addr,
			output logic [HEADPTR_WIDTH-1:0]  			hdptr_wr_data,
			input logic 		  								hdptr_wr_done,	
			output logic 		  								hdptr_rd_vld,
			output logic [HEADPTR_ADDR_WIDTH-1:0]  	hdptr_rd_addr,
			input logic [HEADPTR_WIDTH-1:0] 				hdptr_rd_data,
			input logic 		  								hdptr_rd_data_out_vld,		
			// output to resp gen unit //
			input logic											ll_mngr_resp_gen_req_taken,
			output logic										resp_done,
			output logic 										resp_tot_nodes,
			output logic [NODENUM_WIDTH-1:0] 			resp_num_nodes,
			output logic 										resp_ll_nodes,
			output logic [HEADPTR_ADDR_WIDTH-1:0] 		resp_ll_num,
			// heart beat top //
			output logic 										hb_pulse
	      );

 //-------------- Declarations ------------------//
 typedef enum logic[4:0] {
	IDLE, //0
	WR_MAX_LL_REG, //1
	WR_HDPTR_OR_NDCNTR_MEM, //2
	WR_CTRL_DIRECT_REQ, //3
	UPD_HDPTR_REGS_N_NXTPTR_AVAIL, //4
	RD_LL_REG, //5
	RD_HDPTR_CNTR_MEM, //6
	RDCTRL_TRAVERSE_LL_FWD_WRCTRL_REQ, //7
	UPD_NDCNTR_MEM_AFTR_WR, //8
	WRITE_BACK_FOR_INS_MID, //9
	RET_MIDDLE_NODE_PTR_FOR_DEL, //a
	RD_CTRL_SINGLE_RD_REQ, //b
	SEND_RESP, //c
	FWD_WR_REQ // d
 }t_hdptr_mngr_states;
 
 logic [NODENUM_WIDTH-1:0] 		tot_num_nodes;
 logic [NODENUM_WIDTH:0] 			tot_num_nodes_plus_1;
 logic [NODENUM_WIDTH-1:0] 		num_nodes_of_ll;
 logic [NUM_LL_WIDTH-1:0] 			ll_num;
 logic 									add_tot_nodes_pulse;
 logic 									req_add_tot_nodes_cur_ll;
 logic 									req_add_tot_nodes_prev;
 logic 									req_del_tot_nodes_cur_ll;
 logic 									req_del_tot_nodes_prev;
 logic [NUM_LL_WIDTH-1:0] 			num_active_ll;
 logic [NUM_LL_WIDTH-1:0] 			max_num_active_ll;
 logic [MAX_NUM_LL-1:0]				cur_active_lls;
 logic 									ll_reactv;
 logic 									cfg_req_rd_ll_reg_taken;
 logic 									cfg_req_num_actv_ll_taken;
 logic 									cfg_req_set_hdptr_taken;
 logic 									cfg_req_delete_ll_taken;
 logic									cfg_hdptr_set_flag;
 logic									cfg_hdptr_del_flag;
 t_hdptr_mngr_states					ll_hdptr_cur_state;
 t_hdptr_mngr_states					ll_hdptr_nxt_state;
 logic [NODENUM_WIDTH-1:0] 		rd_ll_reg_out;
 logic [HEADPTR_WIDTH-1:0] 		node_cntr_rd_data_int;
 logic [HEADPTR_WIDTH-1:0]			node_cntr_rd_data_int_plus1;
 logic [HEADPTR_WIDTH-1:0]			node_cntr_rd_data_int_minus1;
 logic [HEADPTR_WIDTH-1:0] 		hdptr_rd_data_int;
 logic 									node_cntr_rd_data_int_vld;
 logic  									hdptr_rd_data_int_vld;
 logic  									hdptr_n_nodecntr_int_vld;
 logic									insert_middle_node_traverse_req_vld;
 logic									delete_middle_node_traverse_req_vld;
 logic 									del_tot_nodes_pulse;
 logic [NODENUM_WIDTH-1:0] 		tot_num_nodes_minus_1;
 logic									upd_ll_node_cntr_after_adding_node_flag;
 logic									upd_ll_node_cntr_after_deling_node_flag;
 logic									upd_ll_node_cntr_after_adding_node;
 logic									upd_ll_node_cntr_after_deling_node;
 logic									req_add;
 logic									req_del;
 logic									hdptr_wr_done_int;
 logic									node_cntr_wr_done_int;
 logic [NXTPTR_MEM_WIDTH-1:0]		rd_ctrl_nxtptr_single_rd_int;
 logic									req_cfg_delete_hdptr;
 //--------------//
 





 //-----------------------------------------------------------//
 //--------------ll internal state regs-----------------------//
 //-----------------------------------------------------------//
 
 heart_beat i_heart_beat(
						.clk(clk),
						.reset_n(reset_n),
						// to top //
						.hb_pulse(hb_pulse)
						);
 
  //-----------------------------------------------------------//
 //------------------------------------------------------------//
 //------------------------------------------------------------//


 
 
 
 
 //-----------------------------------------------------------//
 //--------------ll internal state regs-----------------------//
 //-----------------------------------------------------------//
 
 
 
//-------------- logic for counting total number of nodes ---------------//
assign tot_num_nodes_plus_1 = tot_num_nodes + 1;
assign tot_num_nodes_minus_1 = tot_num_nodes - 1;
assign req_add = (req_add_node_at_node_num | req_add_node_at_head | req_add_node_at_tail);
assign req_del = (req_del_node_at_node_num | req_del_node_at_head | req_del_node_at_tail);
assign req_add_tot_nodes_cur_ll = upd_ll_node_cntr_after_adding_node_flag & req_add;
assign req_del_tot_nodes_cur_ll = upd_ll_node_cntr_after_deling_node_flag & req_del;
assign add_tot_nodes_pulse = ~req_add_tot_nodes_prev & req_add_tot_nodes_cur_ll; // pulsed version for counter //
assign del_tot_nodes_pulse = ~req_del_tot_nodes_prev & req_del_tot_nodes_cur_ll; // pulsed version for counter //
assign req_cfg_delete_hdptr = req_cfg_delete_ll;

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		req_add_tot_nodes_prev <= 0;
	end
	else begin
		req_add_tot_nodes_prev <= req_add_tot_nodes_cur_ll; // for pulse generation //
	end
end

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		req_del_tot_nodes_prev <= 0;
	end
	else begin
		req_del_tot_nodes_prev <= req_del_tot_nodes_cur_ll; // for pulse generation //
	end
end

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		tot_num_nodes <= 0;
	end
	else begin
		if(add_tot_nodes_pulse) begin
			tot_num_nodes <= tot_num_nodes_plus_1; // counter incerment //
		end
		else if(del_tot_nodes_pulse) begin
			tot_num_nodes <= tot_num_nodes_minus_1; // counter decrement //		
		end
		else begin
			tot_num_nodes <= tot_num_nodes;
		end
	end
end
//------------------------------------------//
 
 
 
//-------------------- Logic to control num of active linked lists ------------------------//
always_ff@(posedge clk ) begin
	if(!reset_n) begin
		max_num_active_ll <= 0;
		cfg_req_num_actv_ll_taken <= 0;
	end
	else begin
		if(ll_hdptr_nxt_state == WR_MAX_LL_REG) begin
			max_num_active_ll <= req_ll_num; 
			cfg_req_num_actv_ll_taken <= 1;
		end
		else begin
			max_num_active_ll <= max_num_active_ll; 
			cfg_req_num_actv_ll_taken <= 0;
		end
	end
end 
 
always_ff@(posedge clk ) begin
	 if(!reset_n) begin
		num_active_ll <= 0;
		cfg_req_delete_ll_taken <= 0;
		cfg_req_set_hdptr_taken <= 0;
		cur_active_lls <= 0;
	 end
	 else begin
		if (cfg_hdptr_set_flag) begin
			num_active_ll <= num_active_ll + 1;
			cur_active_lls[req_ll_num] <= 1;
			cfg_req_set_hdptr_taken <= 1;
		end
		else if (cfg_hdptr_del_flag) begin
			num_active_ll <= num_active_ll - 1;
			cur_active_lls[req_ll_num] <= 0;
			cfg_req_delete_ll_taken <= 1;
		end
		else begin
			num_active_ll <= num_active_ll;
			cfg_req_delete_ll_taken <= 0;
			cfg_req_set_hdptr_taken <= 0;
		end
	 end
 end 
//---------------------------------------------//


//-------------------------------- Logic to read ll registers ----------------------------------// 
always_ff@(posedge clk ) begin
	if(!reset_n) begin
		rd_ll_reg_out <= 0;
	end
	else begin	
		if(ll_hdptr_cur_state == RD_LL_REG) begin			
			case(req_hdptr_cfgrd_ndnum_value)
				0: rd_ll_reg_out <= tot_num_nodes;
				1: rd_ll_reg_out <= node_cntr_rd_data;
				2: rd_ll_reg_out <= num_active_ll;
				3: rd_ll_reg_out <= cur_active_lls;
				4: rd_ll_reg_out <= max_num_active_ll;
				default: rd_ll_reg_out <= max_num_active_ll;
			endcase
		end
		else begin
			rd_ll_reg_out <= rd_ll_reg_out;
		end
	end
end
//---------------------------------------------//


 
//---------------------- temp storage for hdptr and ll_cntr values -------------------------------//
assign hdptr_n_nodecntr_int_vld = node_cntr_rd_data_int_vld & hdptr_rd_data_int_vld;

always_ff@(posedge clk ) begin
	if(!reset_n) begin
		node_cntr_rd_data_int <= 0;
		hdptr_rd_data_int <= 0;
		node_cntr_rd_data_int_vld <= 0;
		hdptr_rd_data_int_vld <= 0;
	end
	else begin
		if(node_cntr_rd_data_out_vld) begin
			node_cntr_rd_data_int <= node_cntr_rd_data;
			node_cntr_rd_data_int_vld <= 1;
		end
		else if(ll_hdptr_cur_state == IDLE) begin
			node_cntr_rd_data_int_vld <= 0;		
		end
		else begin
			node_cntr_rd_data_int <= node_cntr_rd_data_int;
		end
		
		if(hdptr_rd_data_out_vld) begin
			hdptr_rd_data_int <=	hdptr_rd_data;
			hdptr_rd_data_int_vld <= 1;
		end
		else if(ll_hdptr_cur_state == IDLE) begin
			hdptr_rd_data_int_vld <= 0;		
		end
		else begin
			hdptr_rd_data_int <=	hdptr_rd_data_int;
			node_cntr_rd_data_int_vld <= node_cntr_rd_data_int_vld;
			hdptr_rd_data_int_vld <= hdptr_rd_data_int_vld;	
		end	 
	end
end

//-------------------------------------------//
 
 
 //---------------------- Handling node cntr updation after adding noe at tail or middle ---------------------//
 always_ff@(posedge clk ) begin
	if(!reset_n) begin
		upd_ll_node_cntr_after_adding_node <= 0;
	end
	else begin
		if(upd_ll_node_cntr_after_adding_node_flag) 
			upd_ll_node_cntr_after_adding_node <= 1;
		else if((ll_hdptr_nxt_state == SEND_RESP) & (ll_hdptr_cur_state == WR_HDPTR_OR_NDCNTR_MEM))
			upd_ll_node_cntr_after_adding_node <= 0;
		else
			upd_ll_node_cntr_after_adding_node <= upd_ll_node_cntr_after_adding_node;

	end
 end
 
  always_ff@(posedge clk ) begin
	if(!reset_n) begin
		upd_ll_node_cntr_after_deling_node <= 0;
	end
	else begin
		if(upd_ll_node_cntr_after_deling_node_flag) 
			upd_ll_node_cntr_after_deling_node <= 1;
		else if((ll_hdptr_nxt_state == SEND_RESP | ll_hdptr_nxt_state == UPD_HDPTR_REGS_N_NXTPTR_AVAIL) & (ll_hdptr_cur_state == WR_HDPTR_OR_NDCNTR_MEM))
			upd_ll_node_cntr_after_deling_node <= 0;
		else
			upd_ll_node_cntr_after_deling_node <= upd_ll_node_cntr_after_deling_node;

	end
 end
 //-----------------------------------------------------------//

 
 //---------- done signals stored internally -----------------------//
 always_ff@(posedge clk ) begin
	if(!reset_n) begin
		hdptr_wr_done_int <= 0;
	end
	else begin
		if(hdptr_wr_done & hdptr_wr_done_int == 0) begin
			hdptr_wr_done_int <= 1;
		end
		else if(ll_hdptr_cur_state == SEND_RESP & hdptr_wr_done_int == 1) begin
			hdptr_wr_done_int <= 0;		
		end
		else begin
			hdptr_wr_done_int <= hdptr_wr_done_int;		
		end
	end
 end
 
 always_ff@(posedge clk ) begin
	if(!reset_n) begin
		node_cntr_wr_done_int <= 0;
	end
	else begin
		if(node_cntr_wr_done & node_cntr_wr_done_int == 0) begin
			node_cntr_wr_done_int <= 1;
		end
		else if(ll_hdptr_cur_state == SEND_RESP & node_cntr_wr_done_int == 1) begin
			node_cntr_wr_done_int <= 0;
		end
		else begin
			node_cntr_wr_done_int <= node_cntr_wr_done_int;
		end
	end
 end
 //------------------------------------------------------------------//
 
 
 always_ff@(posedge clk ) begin
	if(!reset_n) begin
		rd_ctrl_nxtptr_single_rd_int <= 0;
	end
	else begin
		if(rd_ctrl_nxtptr_vld) begin
			rd_ctrl_nxtptr_single_rd_int <= rd_ctrl_nxtptr_value;	
		end
		else if(ll_hdptr_cur_state == IDLE) begin
			rd_ctrl_nxtptr_single_rd_int <= 0;			
		end
		else begin
			rd_ctrl_nxtptr_single_rd_int <= rd_ctrl_nxtptr_single_rd_int;			
		end
	end
 
 end
 
 //----------------------------------------// //----------------------------------------//
 //----------------------------------------// //----------------------------------------//
 //----------------------------------------// //----------------------------------------//
 
 
 
 
 
 //-----------------------------------------------------------//
 //--------------ll exec control FSM--------------------------//
 //-----------------------------------------------------------//
 always_ff@(posedge clk ) begin
	 if(!reset_n) begin
		ll_hdptr_cur_state <= IDLE;
	 end
	 else begin
		ll_hdptr_cur_state <= ll_hdptr_nxt_state; 
	 end
 end
 
 
 assign insert_middle_node_traverse_req_vld = req_add_node_at_node_num & (req_hdptr_cfgrd_ndnum_value < node_cntr_rd_data_int);
 assign delete_middle_node_traverse_req_vld = req_del_node_at_node_num & (req_hdptr_cfgrd_ndnum_value < node_cntr_rd_data_int);
 
 
 always@(*) begin
 
 // set defaults //
 ll_hdptr_nxt_state = ll_hdptr_cur_state;
 ll_mngr_fsm_idle = 0;
 hdptr_wr_vld = 0;
 hdptr_wr_addr = 0;
 hdptr_wr_data = 0;
 cfg_hdptr_del_flag = 0;
 cfg_hdptr_set_flag = 0;
 node_cntr_wr_vld = 0;
 node_cntr_wr_addr = 0;
 node_cntr_wr_data = 0;
 node_cntr_rd_vld = 0;
 node_cntr_rd_addr = 0;
 cfg_req_rd_ll_reg_taken = 0;
 hdptr_rd_vld = 0;
 hdptr_rd_addr = 0;
 ll_mngr_resp_taken = 0;
 upd_ll_node_cntr_after_adding_node_flag = 0;
 upd_ll_node_cntr_after_deling_node_flag = 0;
 node_cntr_rd_data_int_plus1 = node_cntr_rd_data_int + 1;
 node_cntr_rd_data_int_minus1 = node_cntr_rd_data_int - 1;
 rd_ctrl_traverse_ll = 0;
 rd_ctrl_ll_node_cnt = 0;
 rd_ctrl_ll_ptr = 0;
 wr_ctrl_data = 0;
 wr_ctrl_data_vld = 0;
 wr_ctrl_wrdata_ndptr_vld = 0;
 rd_ctrl_traverse_ll_wrback_data = 0;
 wr_ctrl_writeback_seq = 0;
 wr_ctrl_wrback_data = 0;
 wr_ctrl_wrback_data_vld = 0;
 wr_ctrl_wrback_ptr = 0;
 wr_ctrl_wrback_ptr_vld = 0;
 wr_ctrl_direct_wr = 0;
 wr_ctrl_nxtptr_for_hdptr_update_taken = 0;
 req_taken = 0;
 hdptr_cfg_value = 0;
 hdptr_cfg_value_vld = 0;
 rd_ctrl_single_rd_req = 0;
 rd_ctrl_traverse_ll_for_middle_node_del = 0;
 pos_2_return_nxt_ptr = 0;
 return_nxt_ptr = 0;
 wr_ctrl_ndptr_N = 0;
 wr_ctrl_ndptr_Nminus2 = 0;
 wr_ctrl_del_mid_ndptrs_vld = 0;
 resp_done = 0;
 wr_ctrl_nodeptr_vld = 0;

 
 //--------------------- FSM transitions -------------------------------//
	case(ll_hdptr_cur_state)
	
		//--------------------STATE---------------//
		IDLE: begin
			ll_mngr_fsm_idle = 1;
			
			if(req_cfg_num_actv_ll) 												ll_hdptr_nxt_state = WR_MAX_LL_REG;
			if(req_cfg_set_hdptr) 													ll_hdptr_nxt_state = WR_HDPTR_OR_NDCNTR_MEM;
			if(req_cfg_delete_ll) 													ll_hdptr_nxt_state = UPD_HDPTR_REGS_N_NXTPTR_AVAIL;
			if(req_rd_ll_reg)															ll_hdptr_nxt_state = RD_LL_REG;
			if(req_add | req_del) 													ll_hdptr_nxt_state = RD_HDPTR_CNTR_MEM;
		end


		//--------------------STATE---------------//		
		WR_MAX_LL_REG: begin
			 ll_hdptr_nxt_state = SEND_RESP;
		end


		//--------------------STATE---------------//		
		WR_HDPTR_OR_NDCNTR_MEM: begin
			node_cntr_wr_vld = 1;
 			node_cntr_wr_addr = req_ll_num;
			if(upd_ll_node_cntr_after_adding_node) node_cntr_wr_data = node_cntr_rd_data_int_plus1;
			else if(upd_ll_node_cntr_after_deling_node) node_cntr_wr_data = node_cntr_rd_data_int_minus1;
				
			if(!(upd_ll_node_cntr_after_adding_node | upd_ll_node_cntr_after_deling_node)) begin
				node_cntr_wr_addr = req_ll_num;
				node_cntr_wr_data = 0;
				hdptr_wr_vld = 1;
				hdptr_wr_addr = req_ll_num;
				hdptr_wr_data = req_hdptr_cfgrd_ndnum_value;
				hdptr_cfg_value = req_hdptr_cfgrd_ndnum_value;
				hdptr_cfg_value_vld = 1;
			end
			else if (upd_ll_node_cntr_after_deling_node) begin
				return_nxt_ptr = 1;
				if(req_del_node_at_head)	pos_2_return_nxt_ptr = rd_ctrl_nxtptr_single_rd_int;	
				else if (req_del_node_at_node_num) 						pos_2_return_nxt_ptr = rd_ctrl_nxtptr_Nminus1_rd_data;
				else								pos_2_return_nxt_ptr = rd_ctrl_nxtptr_value;
			end
			else if(wr_ctrl_nxtptr_for_hdptr_update_vld) begin
				hdptr_wr_vld = 1;
				hdptr_wr_addr = req_ll_num;
				hdptr_wr_data = wr_ctrl_nxtptr_for_hdptr_update;				
			end
			
			if(hdptr_wr_done_int | node_cntr_wr_done_int) begin 
				if(upd_ll_node_cntr_after_adding_node)  ll_hdptr_nxt_state = SEND_RESP;
				else 												 ll_hdptr_nxt_state = UPD_HDPTR_REGS_N_NXTPTR_AVAIL;
			end
		end

		

		//--------------------STATE---------------//		
		UPD_HDPTR_REGS_N_NXTPTR_AVAIL: begin
			if(req_cfg_set_hdptr) 		cfg_hdptr_set_flag = 1;
			if(req_cfg_delete_hdptr) 	cfg_hdptr_del_flag = 1;

			ll_hdptr_nxt_state = SEND_RESP;
		end
		


		//--------------------STATE---------------//		
		RD_LL_REG: begin
			case(req_hdptr_cfgrd_ndnum_value)
				1: begin
					node_cntr_rd_vld = 1;
					node_cntr_rd_addr = req_ll_num;
					
					if(node_cntr_rd_data_out_vld) begin
						ll_hdptr_nxt_state = SEND_RESP;
						cfg_req_rd_ll_reg_taken = 1;
					end
					else ll_hdptr_nxt_state = RD_LL_REG;
				end
				
				default: begin
					ll_hdptr_nxt_state = SEND_RESP;
					cfg_req_rd_ll_reg_taken = 1;
				end
			endcase
		end
		

		
		//--------------------STATE---------------//
		RD_HDPTR_CNTR_MEM: begin
			hdptr_rd_vld = 1;
			hdptr_rd_addr = req_ll_num;
			node_cntr_rd_vld = 1;
			node_cntr_rd_addr = req_ll_num;
			
			if(hdptr_n_nodecntr_int_vld & rd_ctrl_ready & !(req_add_node_at_head | req_del_node_at_head)) ll_hdptr_nxt_state = RDCTRL_TRAVERSE_LL_FWD_WRCTRL_REQ;
			if(hdptr_n_nodecntr_int_vld & req_add_node_at_head & wr_ctrl_ready)	ll_hdptr_nxt_state = WR_CTRL_DIRECT_REQ;
			if(hdptr_n_nodecntr_int_vld & req_del_node_at_head & wr_ctrl_ready)	ll_hdptr_nxt_state = RD_CTRL_SINGLE_RD_REQ;
		end		
		

		
		//--------------------STATE---------------//
		RD_CTRL_SINGLE_RD_REQ: begin
			rd_ctrl_single_rd_req = 1;
			rd_ctrl_ll_ptr = hdptr_rd_data_int;
			
			if(rd_ctrl_nxtptr_vld) ll_hdptr_nxt_state = UPD_NDCNTR_MEM_AFTR_WR;
		end
		
		

		//--------------------STATE---------------//		
		RDCTRL_TRAVERSE_LL_FWD_WRCTRL_REQ: begin
			rd_ctrl_ll_ptr = hdptr_rd_data_int;
			
			if(insert_middle_node_traverse_req_vld) begin	
				rd_ctrl_ll_node_cnt = req_middle_node_pos;
				rd_ctrl_traverse_ll_wrback_data = 1;
				rd_ctrl_send_wrback_reg_value = 1;
			end
			else if(delete_middle_node_traverse_req_vld) begin
				rd_ctrl_ll_node_cnt = req_middle_node_pos;
				rd_ctrl_traverse_ll_for_middle_node_del = 1;			
			end
			else if(req_add_node_at_tail | req_del_node_at_tail) begin				
				rd_ctrl_ll_node_cnt = node_cntr_rd_data_int;
				rd_ctrl_traverse_ll = 1;
			end
			
			
			if(rd_ctrl_nxtptr_vld  & wr_ctrl_ready & !req_del) begin
				ll_hdptr_nxt_state = FWD_WR_REQ;
			end			
			else if(rd_ctrl_nxtptr_vld & req_del_node_at_tail) begin
				ll_hdptr_nxt_state = UPD_NDCNTR_MEM_AFTR_WR;
			end
			else if(rd_ctrl_upd_nxtptr_for_mid_node_del & req_del_node_at_node_num) begin
				ll_hdptr_nxt_state = RET_MIDDLE_NODE_PTR_FOR_DEL;			
			end
			else begin
				ll_hdptr_nxt_state = RDCTRL_TRAVERSE_LL_FWD_WRCTRL_REQ;
			end
		end
	
	
	
		
		//--------------------STATE---------------//						
		FWD_WR_REQ: begin
			if(insert_middle_node_traverse_req_vld) begin
				wr_ctrl_writeback_seq = 1;
				if(rd_ctrl_data_vld) begin
					wr_ctrl_wrback_data = rd_ctrl_data_value;
					wr_ctrl_wrback_data_vld = 1;
				end
				if(rd_ctrl_wrback_ptr_vld) begin
					wr_ctrl_wrback_ptr = rd_ctrl_wrback_ptr;
					wr_ctrl_wrback_ptr_vld = 1;
				end
			end
			else if(req_add_node_at_tail) wr_ctrl_wrdata_ndptr_vld = 1;
			
			wr_ctrl_nodeptr_for_write = rd_ctrl_nxtptr_value;
			wr_ctrl_nodeptr_vld = 1;
			wr_ctrl_data = req_data;
			wr_ctrl_data_vld = 1;

			
			if(wr_ctrl_ready  & !req_del) begin
				if(req_add_node_at_tail) begin
					ll_mngr_resp_taken = 1;
					ll_hdptr_nxt_state = UPD_NDCNTR_MEM_AFTR_WR;
				end
				else if(insert_middle_node_traverse_req_vld) begin
					ll_hdptr_nxt_state = UPD_NDCNTR_MEM_AFTR_WR;				
				end
			end
		
		end
		

		
		
		//--------------------STATE---------------//						
		RET_MIDDLE_NODE_PTR_FOR_DEL: begin
			 wr_ctrl_ndptr_N = rd_ctrl_nxtptr_N_rd_data;
			 wr_ctrl_ndptr_Nminus2 = rd_ctrl_nxtptr_Nminus2_rd_data;
			 wr_ctrl_del_mid_ndptrs_vld = 1;

			 if(wr_ctrl_ready) begin
				ll_hdptr_nxt_state = UPD_NDCNTR_MEM_AFTR_WR;
			 end
		end
		
		
		
		//--------------------STATE---------------//				
		WR_CTRL_DIRECT_REQ: begin
			wr_ctrl_direct_wr = 1;
			
			if(node_cntr_rd_data_int_vld & hdptr_rd_data_int_vld) begin
				wr_ctrl_nodeptr_for_write = hdptr_rd_data_int;
				wr_ctrl_nodeptr_vld = 1;
				wr_ctrl_data = req_data;
				wr_ctrl_data_vld = 1;
			end
			
			if(wr_ctrl_nxtptr_for_hdptr_update_vld) ll_hdptr_nxt_state = UPD_NDCNTR_MEM_AFTR_WR;
		end

		

		//--------------------STATE---------------//		
		UPD_NDCNTR_MEM_AFTR_WR: begin
			if(req_add) upd_ll_node_cntr_after_adding_node_flag = 1;
			if(req_del) upd_ll_node_cntr_after_deling_node_flag = 1;
			if(wr_ctrl_ready) ll_hdptr_nxt_state = WR_HDPTR_OR_NDCNTR_MEM;
		end
		
		
		
		//--------------------STATE---------------//
		SEND_RESP: begin
			req_taken = 1;
			resp_done = 1;
			wr_ctrl_nxtptr_for_hdptr_update_taken = 1;
			ll_mngr_resp_taken = 1;
			if(ll_mngr_resp_gen_req_taken) ll_hdptr_nxt_state = IDLE;
		end
		
		
		
		//--------------------STATE---------------//
		default: begin
			ll_hdptr_nxt_state = IDLE;
		end
	endcase
 
 end

 //----------------------------------------// //----------------------------------------//
 //----------------------------------------// //----------------------------------------//
 //----------------------------------------// //----------------------------------------//
  
endmodule // ll_mngr