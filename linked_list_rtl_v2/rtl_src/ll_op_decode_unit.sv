//TODO list: 
// 1. reduce number of states by using appropriate MUXes at the output //
// 2. logic for error response //

module ll_op_decode_unit(
			input logic 		      clk,
			input logic 		      reset_n,
			// Inputs from top //
			input logic 		           				  req_vld,
			input t_mainop_types     					  req_main_op,
			input t_specifier_types  					  req_spec,
			input logic [HEADPTR_ADDR_WIDTH-1:0]     req_ll_num_in,
			input logic [NODENUM_WIDTH-1:0]     	  req_pos,
			input logic [DATA_WIDTH-1:0]  			  req_data,
			// i/o to ll manager //
			output logic 									req_del_node_at_node_num,
			output logic 									req_del_node_at_head,
			output logic 									req_del_node_at_tail,
			output logic 									req_add_node_at_node_num,
			output logic 									req_add_node_at_head,
			output logic 									req_add_node_at_tail,
	      output logic 									req_rd_ll_reg,
			output logic									req_delete_ll,
			output logic [NUM_LL_WIDTH-1:0] 			req_ll_num,
			output logic									req_cfg_num_actv_ll,
			output logic									req_cfg_set_hdptr,
			output logic [NODENUM_WIDTH-1:0]			req_hdptr_cfgrd_ndnum_value,
			output logic [NODENUM_WIDTH-1:0]			req_middle_node_pos,
			output logic [DATAMEM_WIDTH-1:0]			req_data_out,
			input logic										req_taken,
			input logic 									ll_mngr_fsm_idle,
			// i/p interface ready indication to top//
			output logic 		            	intf_ready,
			// i/o to resp_gen unit //
			input logic								resp_gen_cmpltd,
			output logic							resp_no_op,
			output logic							resp_gen_decode_err,
			output logic							resp_gen_decode_err_type
			);

// Declarations //
typedef enum logic[3:0] {
							  IDLE,//0
							  FWD_NO_OP,//1
							  FWD_CFG_REQ_TO_HDPTR,//2
							  FWD_READ_LL_REGS_REQ,//3
							  FWD_INSERT_NODE_REQ,//4
							  FWD_DELETE_NODE_REQ,//5
							  WAIT_FOR_RESP_CMPL,//6
							  DECODE_ERROR//7
							  } t_req_resp_fsm_st;

t_req_resp_fsm_st		ll_ctrl_cur_st; 
t_req_resp_fsm_st		ll_ctrl_nxt_st;
//----------------//


//---------------------------------------------------------//
//---------- Linked list request controller FSM -----------//
//---------------------------------------------------------//
always_ff@(posedge clk ) begin
	if(!reset_n) begin
		ll_ctrl_cur_st <= IDLE;
	end
	else begin
		ll_ctrl_cur_st <= ll_ctrl_nxt_st;
	end
end




always@(*) begin

// defaults //
ll_ctrl_nxt_st = ll_ctrl_cur_st;
req_cfg_num_actv_ll = 0;
req_ll_num = 0;
intf_ready = 0;
req_cfg_set_hdptr = 0;
req_delete_ll = 0;
req_hdptr_cfgrd_ndnum_value = 0;
req_rd_ll_reg = 0;
resp_gen_decode_err = 0;
resp_gen_decode_err_type = 0;
req_add_node_at_node_num = 0;
req_add_node_at_head = 0;
req_add_node_at_tail = 0;
req_del_node_at_node_num = 0;
req_del_node_at_head = 0;
req_del_node_at_tail = 0;
req_middle_node_pos = 0;
resp_no_op = 0;
req_data_out = 0;
//----------------//


	//----------------FSM transitions-------------------//
	case(ll_ctrl_cur_st)

	
		//--------------------STATE---------------//
		IDLE: begin
			intf_ready = 1;
		
			if(req_vld & ll_mngr_fsm_idle) begin
				case(req_main_op)
					NO_OP: begin
						ll_ctrl_nxt_st = FWD_NO_OP;
					end
					
					CONFIG_HDPTR : begin
						ll_ctrl_nxt_st = FWD_CFG_REQ_TO_HDPTR;								
					end
					
					READ_LL_REGS : begin
						ll_ctrl_nxt_st = FWD_READ_LL_REGS_REQ;
					end
					
					INSERT : begin
						ll_ctrl_nxt_st = FWD_INSERT_NODE_REQ;
					end
					
					DELETE : begin
						ll_ctrl_nxt_st = FWD_DELETE_NODE_REQ;					
					end
					//UPDATE :
					//READ_NODE :
					//POP :
					//EMPTY_LL :
					default:		ll_ctrl_nxt_st = IDLE;		
				endcase
			end				
			else begin
				ll_ctrl_nxt_st = IDLE;
			end
		end //--------------- IDLE -----------------//
			
			
			
		FWD_NO_OP: begin
			resp_no_op = 1;
			ll_ctrl_nxt_st = WAIT_FOR_RESP_CMPL;
		end
		
			
			
		//--------------------STATE---------------//
		FWD_CFG_REQ_TO_HDPTR: begin
		
			if(req_taken) begin
				ll_ctrl_nxt_st = WAIT_FOR_RESP_CMPL;					
			end
			else begin
				ll_ctrl_nxt_st = ll_ctrl_cur_st;
			end
			
			case(req_spec)
				SET_NUM_LL: begin
					req_cfg_num_actv_ll = 1;
					req_ll_num = req_ll_num_in;
				end
				
				SET_HDPTR: begin
					req_cfg_set_hdptr = 1;
					req_ll_num =  req_ll_num_in;
					req_hdptr_cfgrd_ndnum_value = req_pos; //req_data[DATA_WIDTH-1:0];
				end
				
				DEL_LL: begin
					req_delete_ll = 1;
					req_ll_num =  req_ll_num_in;
				end
				
				default: begin
					ll_ctrl_nxt_st = DECODE_ERROR;							
				end					
			endcase		
		end //------- FWD_CFG_REQ_TO_HDPTR ---------//
		
		
		
		//--------------------STATE---------------//
		FWD_READ_LL_REGS_REQ: begin
			req_rd_ll_reg = 1;
			req_ll_num = req_ll_num_in;
			req_hdptr_cfgrd_ndnum_value = req_data; 
			
			if(req_taken) ll_ctrl_nxt_st = WAIT_FOR_RESP_CMPL;
		end //---------- FWD_RETURN_SIZE_REQ --------//
		

		
		//--------------------STATE---------------//
		FWD_INSERT_NODE_REQ: begin
			req_ll_num = req_ll_num_in;
			req_data_out = req_data;
			req_middle_node_pos = req_pos;
			
			case(req_spec)
				AT_HEAD: begin
					req_add_node_at_head = 1;
				end
				
				AT_TAIL: begin
					req_add_node_at_tail = 1;				
				end
				
				AT_NODE_NUM: begin
					req_add_node_at_node_num = 1;
				end
				
				default: begin
					ll_ctrl_nxt_st = DECODE_ERROR;					
				end
			endcase
			
			if(req_taken)  ll_ctrl_nxt_st = WAIT_FOR_RESP_CMPL;
		
		end //------ FWD_INSERT_NODE_REQ -----------//

		
		
		
		//--------------------STATE---------------//
		FWD_DELETE_NODE_REQ: begin
			req_ll_num = req_ll_num_in;
			req_middle_node_pos = req_pos;
			
			case(req_spec)
				AT_HEAD: begin
					req_del_node_at_head = 1;
				end
				
				AT_TAIL: begin
					req_del_node_at_tail = 1;				
				end
				
				AT_NODE_NUM: begin
					req_del_node_at_node_num = 1;
				end
				
				default: begin
					ll_ctrl_nxt_st = DECODE_ERROR;					
				end
			endcase
			
			if(req_taken)  ll_ctrl_nxt_st = WAIT_FOR_RESP_CMPL;		
		end //-------------- FWD_DELETE_NODE_REQ ---------------//
		
		
		
		
		//--------------------STATE---------------//
		WAIT_FOR_RESP_CMPL: begin
			if(resp_gen_cmpltd) ll_ctrl_nxt_st = IDLE;
		end //------ WAIT_FOR_RESP_CMPL ----------//
		
		
		
		//--------------------STATE---------------//
		DECODE_ERROR: begin
			resp_gen_decode_err = 1;
			resp_gen_decode_err_type = 0;	
	
			 ll_ctrl_nxt_st = IDLE;
		
		end //--------- DECODE_ERROR -------------//
		
		
		
		//--------------------STATE---------------//
		default: begin
			ll_ctrl_nxt_st = IDLE;
		end //------------- default ---------------//
		
		

	endcase // case (ll_ctrl_cur_st)
end // always_comb   
//---------------------------------------------------------//
//---------------------------------------------------------//
//---------------------------------------------------------//


endmodule // ll_req_resp_intf

