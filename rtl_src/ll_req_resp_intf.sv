//TODO list: 
// 1. reduce number of states by using appropriate MUXes at the output //
// 2. logic for error response //

module ll_req_resp_intf(
			input logic 		      clk,
			input logic 		      reset_n,
			// Inputs from top //
			input logic 		      req_vld,
			input 			      t_req_types req_type,
			input logic [PTR_WD-1:0]      req_pos,
			input logic [WR_DATA_WD-1:0]  req_data,
			input logic 		      resp_taken,
			// Output to top //
			output logic 		      resp_vld,
			output 			      t_resp_types resp_type,
			output logic [WR_DATA_WD-1:0] resp_data,
			output logic 		      resp_data_vld,
			// output to top to indicate FSM ready //
			output logic 		      intf_ready,
			// linked list empty/size indication from nxt_ptr_logic//
			input logic 		      ll_empty,
			input logic [PTR_WD-1:0]      ll_size,
			// Output to write controller //
			output logic 		      wr_vld,
			output logic 		      wr_insert,
			output logic [WR_DATA_WD-1:0] wr_data_nxt_ptr,
			// indicate position of new node to nxt_ptr_logic //
			output logic [WR_ADDR_WD-1:0] wr_pos,
			// Inputs from read controller //
			input logic 		      rd_ctrl_ready_in,
			input logic 		      rd_ctrl_data_out_vld,
			input logic [WR_DATA_WD-1:0]  rd_ctrl_data_out,
			// output to read controller //
			output logic 		      rd_vld,
			output logic 		      rd_pop,
			output logic [RD_ADDR_WD-1:0] rd_addr,
			// indicate linked list to be made empty to system //
			output logic 		      make_ll_empty,
			// fsm ready idication from wr_ctrl //
			input logic 		      wr_ctrl_fsm_ready_in
			);




   // Declarations //
   typedef enum 				      logic[3:0] {
								  IDLE,
								  EXEC_WR,
								  EXEC_RD,
								  EXEC_EMPTY_LL,
								  SEND_RESP_SIZE,
								  SEND_RESP_OP,	
								  SEND_RESP_ERROR
								  } t_req_resp_fsm_st;
   
   t_req_resp_fsm_st	 ll_ctrl_cur_st ;   
   t_req_resp_fsm_st      ll_ctrl_nxt_st;
   t_req_types					      req_type_int;
   logic [PTR_WD-1:0] 				      req_pos_int;
   logic [WR_DATA_WD-1:0] 			      req_data_int;
   t_error_types                                      error_type;
   logic 					      error_detected;
   t_resp_types                                       determine_resp_type;
   logic 					      req_vld_delyd;   
   //--------//


   
   // error type determination //
   always_comb begin
      error_type = OTHER;
      error_detected = 0;
      
      if(req_vld) begin
	 if(req_type > 9) begin
	    error_type =  ILL_REQ_TYPE; 
	    error_detected = 1; 
	 end
	 else if (req_type == INSERT & req_pos != 0 & ll_empty) begin
	    error_type = INS_LL_EMPTY;
	    error_detected = 1;
	 end
	 else if (req_type == DELETE_NODE & ll_empty) begin
	    error_type = DEL_LL_EMPTY;
	    error_detected = 1;
	 end
	 else if ((req_type == POP_HEAD_REQ | req_type == POP_TAIL_REQ) & ll_empty) begin
	    error_type = POP_LL_EMPTY;
	    error_detected = 1;	    
	 end
	 else if (req_type == EMPTY_LL & ll_empty) begin
	    error_type = EMPTY_LL_EMPTY;
	    error_detected = 1;	    
	 end
	 //else if (req_vld_delyd & !intf_ready) begin
	 //   error_type = REQ_WHEN_BUSY;
	 //   error_detected = 1;
	 //end
	 else begin
	    error_type = OTHER;
	    error_detected = 0;
	 end

      end
      else begin
	 error_type = OTHER;
	 error_detected = 0;	 
      end
      
   end  
   //----------------//


   
   // delay request valid by one cycle and compare with intf_ready for error detection //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 req_vld_delyd <= 0;	 
      end
      else begin
	 if(req_vld & !req_vld_delyd) begin
	    req_vld_delyd <= req_vld;
	 end
	 else if(req_vld & req_vld_delyd) begin
	    req_vld_delyd <= 0;	    
	 end
	 else begin
	    req_vld_delyd <= 0;	    
	 end
	 
      end
   end
   //---------------//
   
   // ll controller FSM outputs //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 intf_ready <= 1;
	 resp_vld <= 0;
	 resp_type <= 0;
	 resp_data <= 0;
	 resp_data_vld <= 0;
	 wr_vld <= 0;	 
	 wr_insert <= 0;	 
	 wr_data_nxt_ptr <= 0;
	 wr_pos <= 0;
	 resp_vld <= 0;
	 resp_type <= 0;
	 resp_data_vld <= 0;	      
	 resp_data <= 0;
	 rd_vld <= 0;	 
	 rd_pop <= 0;	 
	 rd_addr <= 0;	 
 	 make_ll_empty <= 0;
	 determine_resp_type <= ERROR;
	 ll_ctrl_cur_st <= IDLE;
	 
      end
      else begin
	 
	 ll_ctrl_cur_st <= ll_ctrl_nxt_st;
	 intf_ready <= 0;
	 
	 case(ll_ctrl_nxt_st)
	   IDLE: begin
	      wr_vld <= 0;
	      wr_insert <= 0;
	      wr_data_nxt_ptr <= 0;
	      wr_pos <= 0;
	      resp_vld <= 0;
	      resp_type <= ERROR;
	      resp_data_vld <= 0;	      
	      resp_data <= 0;
	      rd_vld <= 0;	 
	      rd_pop <= 0;	 
	      rd_addr <= 0;	 
 	      make_ll_empty <= 0;
	      determine_resp_type <= ERROR;
	      
	      if(req_vld) begin
		 intf_ready <= 0;
		 req_type_int <= req_type;
		 req_pos_int <= req_pos; 
		 req_data_int <= req_data;		 
	      end
	      else begin
		 intf_ready <= 1;
		 req_type_int <= 0;
		 req_pos_int <= 0; 
		 req_data_int <= 0;
	      end
	      
	   end	  
	   
	   
	   EXEC_WR: begin
	      
	      wr_vld <= 1;	      
	      determine_resp_type <= OP_DONE;		   
	      wr_data_nxt_ptr <= req_data;

	      case(req_type)
		INSERT: begin
		   wr_insert <= 1;
		   wr_pos <= req_pos;
		end
		MODIFY: begin
		   wr_insert <= 0;
		   wr_pos <= req_pos;
		end		   
		PUSH_HEAD: begin
		   wr_insert <= 1;
		   wr_pos <= 0;
		end
		PUSH_TAIL: begin
		   wr_insert <= 1;
		   wr_pos <= ll_size;
		end

		default: begin
		   wr_vld <= 0;
		   wr_insert <= 0;
		   wr_data_nxt_ptr <= 0;
		   wr_pos <= 0;
		   determine_resp_type <= ERROR;		   
		end
	      endcase
	   end // case: EXEC_WR
	   

	   
	   EXEC_RD: begin
	      if(rd_ctrl_ready_in & !rd_vld) begin
		 rd_vld <= 1;	 	   
		   case(req_type)		
		     READ_NODE: begin
			rd_pop <= 0;	 
			rd_addr <= req_pos;
			determine_resp_type <= RD_NODE_DATA;		      
		     end
		     DELETE_NODE: begin
			rd_pop <= 1;	 
			rd_addr <= req_pos;
			determine_resp_type <= DEL_NODE_DATA;
		     end
		     POP_HEAD_REQ: begin
			rd_pop <= 1;	 
			rd_addr <= 0;
			determine_resp_type <= POP_HEAD;
		     end
		     POP_TAIL_REQ: begin
			rd_pop <= 1;	 
			rd_addr <= ll_size-1;
			determine_resp_type <= POP_TAIL;
		     end
		     
		     default: begin
			rd_vld <= 0;	 
			rd_pop <= 0;	 
			rd_addr <= 0;
			determine_resp_type <= ERROR;
		     end
		     
		   endcase // case (req_type_int)
	      end // if (rd_ctrl_ready_in & !rd_vld)
	      else begin
		 rd_vld <= 0;	 
		 rd_pop <= 0;	
	      end // else: !if(rd_ctrl_ready_in & !rd_vld)
	      

	   end // case: EXEC_RD
	   


	   
	   EXEC_EMPTY_LL: begin
	      make_ll_empty <= 1;
	      determine_resp_type <= OP_DONE;	      
	   end
	   

	   
	   SEND_RESP_SIZE: begin	      
	      resp_vld <= 1;
	      resp_type <= SIZE;
	      resp_data_vld <= 1;
	      
	      if(!ll_empty)  resp_data <= ll_size + 1;	      
	      else resp_data <= 0;	      	      
	   end
	   

	   
	   SEND_RESP_OP: begin
	      make_ll_empty <= 0;	      
	      wr_vld <= 0;
	      wr_insert <= 0;
	      wr_data_nxt_ptr <= 0;
	      wr_pos <= 0;
	      rd_vld <= 0;	 
	      rd_pop <= 0;	 
	      rd_addr <= 0;
	      resp_vld <= 1;
	      resp_type <= determine_resp_type;
	      
	      case(determine_resp_type) inside
		OP_DONE: begin
		   resp_data_vld <= 0;	      
		   resp_data <= 0; 
		end
		RD_NODE_DATA, POP_HEAD, DEL_NODE_DATA, POP_TAIL: begin
		   resp_data_vld <= 1;	      
		   resp_data <= rd_ctrl_data_out;
		end

		default: begin
		   resp_vld <= 1;
		   resp_type <= ERROR;
		   resp_data_vld <= 1;	      
		   resp_data <= error_type;
		end
	      endcase // case (determine_resp_type)
	   end // case: SEND_RESP_OP
	   
 	   
	   
	   
	   SEND_RESP_ERROR: begin
	      resp_vld <= 1;
	      resp_type <= ERROR;
	      resp_data_vld <= 1;	      
	      resp_data <= error_type; 
	   end	   
	   

	   default: begin
	      wr_vld <= 0;
	      wr_insert <= 0;
	      wr_data_nxt_ptr <= 0;
	      wr_pos <= 0;
	      resp_vld <= 0;
	      resp_type <= ERROR;
	      resp_data_vld <= 0;	      
	      resp_data <= 0;
	      rd_vld <= 0;	 
	      rd_pop <= 0;	 
	      rd_addr <= 0;	 
 	      make_ll_empty <= 0;
	      determine_resp_type <= ERROR;
	      intf_ready <= 1;
	      req_type_int <= 0;
	      req_pos_int <= 0; 
	      req_data_int <= 0;
	   end
	   
	 endcase // case (ll_ctrl_cur_st)	 
      end
      
   end
   //---------//


   
   // Linked list request controller FSM //
   always_comb begin
      ll_ctrl_nxt_st = ll_ctrl_cur_st;
      case(ll_ctrl_cur_st)
	IDLE: begin
	   if(req_vld) begin
	      if( error_detected ) begin
		 ll_ctrl_nxt_st = SEND_RESP_ERROR;
	      end
	      else begin
		 case(req_type)
		   RETURN_SIZE: begin ll_ctrl_nxt_st = SEND_RESP_SIZE ; end
		   INSERT: begin ll_ctrl_nxt_st =      EXEC_WR; end
		   MODIFY: begin ll_ctrl_nxt_st =      EXEC_WR; end
		   READ_NODE: begin ll_ctrl_nxt_st =   EXEC_RD;  end
		   DELETE_NODE: begin ll_ctrl_nxt_st = EXEC_RD; end
		   POP_HEAD_REQ: begin ll_ctrl_nxt_st =    EXEC_RD; end
		   POP_TAIL_REQ: begin ll_ctrl_nxt_st =    EXEC_RD; end
		   PUSH_HEAD: begin ll_ctrl_nxt_st =   EXEC_WR;  end
		   PUSH_TAIL: begin ll_ctrl_nxt_st =   EXEC_WR;  end
		   EMPTY_LL: begin ll_ctrl_nxt_st =    EXEC_EMPTY_LL;  end
		   
		   default: begin
		      ll_ctrl_nxt_st = IDLE;		
		   end
		   
		 endcase // case (req_type_int)
	      end//
	   end
	   else ll_ctrl_nxt_st = IDLE;
	end // case: IDLE	
	

	EXEC_WR: begin
	   if(wr_ctrl_fsm_ready_in) ll_ctrl_nxt_st = SEND_RESP_OP;
	   else ll_ctrl_nxt_st = EXEC_WR;	   
	end	


	EXEC_RD: begin
	   if(rd_ctrl_ready_in & req_type == DELETE_NODE  ) ll_ctrl_nxt_st = SEND_RESP_OP;
	   else if(rd_ctrl_data_out_vld) ll_ctrl_nxt_st = SEND_RESP_OP;
	   else ll_ctrl_nxt_st = EXEC_RD;	   
	end

	EXEC_EMPTY_LL: begin
	   if(ll_empty) ll_ctrl_nxt_st = SEND_RESP_OP;
	   else ll_ctrl_nxt_st = EXEC_EMPTY_LL;	   
	end
	

	SEND_RESP_SIZE: begin
	   if (resp_taken) ll_ctrl_nxt_st = IDLE;
	   else	   ll_ctrl_nxt_st = SEND_RESP_SIZE;	   
	end
	
	SEND_RESP_OP: begin
	   if (resp_taken) ll_ctrl_nxt_st = IDLE;
	   else	   ll_ctrl_nxt_st = SEND_RESP_OP;
	end
	
	SEND_RESP_ERROR: begin
	   if (resp_taken) ll_ctrl_nxt_st = IDLE;
	   else	   ll_ctrl_nxt_st = SEND_RESP_ERROR;
	end
	
	default: begin
	   ll_ctrl_nxt_st = IDLE;
	end
	
      endcase // case (ll_ctrl_cur_st)
   end // always_comb   
   //----------//
   
   
endmodule // ll_req_resp_intf


