module ll_rd_ctrl(
		  input logic 			clk,
		  input logic 			reset_n,
		  // read request from req_resp_intf //
		  input logic 			rd_req_vld,
		  input logic 			rd_req_pop,
		  input logic [PTR_WD-1:0] 	rd_node_at_pos,
		  // Outputs to nxt_ptr_logic //
		  output logic 			req_vld_to_nxt_ptr,
		  output logic 			req_pop_to_nxt_ptr,
		  output logic [PTR_WD-1:0] 	node_at_pos_to_nxt_ptr,
		  // Inputs from nxt_ptr_logic  //
		  input logic 			rd_nxt_ptr_vld,
		  input logic [PTR_WD-1:0] 	rd_data_from_nxt_ptr,
		  // Outputs to nxt_ptr_req_serv //
		  output logic 			return_nxt_ptr,
		  output logic [PTR_WD-1:0] 	pos_2_return_nxt_ptr, 
		  // Outputs to data mem //
		  output logic 			rd_req_to_mem_vld,
		  output logic [WR_DATA_WD-1:0] rd_req_addr_to_mem,
		  // Read data from data mem //
		  input logic 			rd_data_from_mem_vld,
		  input logic [WR_DATA_WD-1:0] 	rd_data_from_mem,
		  // final read data sent to req_resp_intf //
  		  output logic 			rd_ctrl_ready,
		  output logic 			rd_data_out_vld,
		  output logic [WR_DATA_WD-1:0] rd_data_out

		  );


   // Declarations//
   typedef enum logic[3:0]{
			   IDLE,			   
			   GET_POS_PTR,	
			   UPD_NXT_PTR,
			   RD_DATA_MEM
			   } t_rd_ctrl_st;
   t_rd_ctrl_st 					rd_ctrl_cur_st;
   t_rd_ctrl_st 					rd_ctrl_nxt_st;
   //----------//

   
   
   // READ controller FSM Outputs //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 rd_data_out_vld <= 0;	 
	 rd_data_out	 <= 0;
	 rd_ctrl_cur_st <= IDLE;
	 req_vld_to_nxt_ptr      <= 0;	      
	 req_pop_to_nxt_ptr     <= 0;              
	 node_at_pos_to_nxt_ptr <= 0;
         rd_req_to_mem_vld <= 0;	      
	 rd_req_addr_to_mem <= 0;
	 return_nxt_ptr <= 0;	      
         rd_ctrl_ready <= 1;
	 pos_2_return_nxt_ptr <= 0;
      end
      else begin
	 rd_ctrl_cur_st <= rd_ctrl_nxt_st;
	 rd_ctrl_ready <= 0;
         
	 case(rd_ctrl_nxt_st) 
	   IDLE: begin
              rd_req_to_mem_vld <= 0;	      
	      rd_req_addr_to_mem <= 0;
	      req_vld_to_nxt_ptr      <= 0;	      
	      req_pop_to_nxt_ptr     <= 0;              
	      node_at_pos_to_nxt_ptr <= 0;
	      return_nxt_ptr <= 0;	      
	      pos_2_return_nxt_ptr <= 0;
	      if(!rd_ctrl_ready) begin
		 rd_data_out_vld <= rd_data_from_mem_vld;	      
		 rd_data_out <= rd_data_from_mem;
	      end
	      else begin
		 rd_data_out_vld <= 0;	      
		 rd_data_out <= 0;
	      end
              rd_ctrl_ready <= 1;
	   end

	   GET_POS_PTR: begin		                        
	      req_vld_to_nxt_ptr      <= rd_req_vld;	      
	      req_pop_to_nxt_ptr     <= 0;              
	      node_at_pos_to_nxt_ptr <= rd_node_at_pos;
	      return_nxt_ptr <= 0;	      
	      pos_2_return_nxt_ptr <= 0;
	      rd_data_out_vld <= 0;	      
	      rd_data_out <= 0;
	   end	
	   
	   UPD_NXT_PTR: begin
	      req_vld_to_nxt_ptr      <= rd_req_vld;	      
	      req_pop_to_nxt_ptr     <= rd_req_pop;              
	      node_at_pos_to_nxt_ptr <= rd_node_at_pos;
	      return_nxt_ptr <= 0;	      
	      pos_2_return_nxt_ptr <= 0;
	      rd_data_out_vld <= 0;
	      rd_data_out <= 0;	      
	   end

	   RD_DATA_MEM: begin
	      rd_req_to_mem_vld <= 1;	      
	      rd_req_addr_to_mem <= rd_data_from_nxt_ptr;
	      req_vld_to_nxt_ptr      <= 0;	      
	      req_pop_to_nxt_ptr     <= 0;              
	      node_at_pos_to_nxt_ptr <= 0;
	      return_nxt_ptr <= 1;	      
	      pos_2_return_nxt_ptr <= rd_data_from_nxt_ptr;
	      rd_data_out_vld <= 0;	      
	      rd_data_out <= 0;
	   end

	   default: begin
	      rd_data_out_vld <= 0;	 
	      rd_data_out	 <= 0;
	      rd_ctrl_cur_st <= IDLE;
	      req_vld_to_nxt_ptr      <= 0;	      
	      req_pop_to_nxt_ptr     <= 0;              
	      node_at_pos_to_nxt_ptr <= 0;
              rd_req_to_mem_vld <= 0;	      
	      rd_req_addr_to_mem <= 0;
	      return_nxt_ptr <= 0;	      
              rd_ctrl_ready <= 1;
	      pos_2_return_nxt_ptr <= 0;
	   end
	   
	 endcase // case (rd_ctrl_cur_st)    
      end
      
   end
   //----------//


   // Read controller FSM state transitions //
   always_comb begin
      rd_ctrl_nxt_st = IDLE;
      case(rd_ctrl_cur_st) 
	IDLE: begin
	   if(rd_req_vld & rd_req_pop) begin
	      rd_ctrl_nxt_st = UPD_NXT_PTR;	      
	   end
	   else if(rd_req_vld & !rd_req_pop) rd_ctrl_nxt_st = GET_POS_PTR;
	   else rd_ctrl_nxt_st = IDLE;	   
	end

	GET_POS_PTR: begin
	   if(rd_nxt_ptr_vld) rd_ctrl_nxt_st = RD_DATA_MEM;
	   else rd_ctrl_nxt_st = GET_POS_PTR;	   
	end	
	
	UPD_NXT_PTR: begin
	   if(rd_nxt_ptr_vld) rd_ctrl_nxt_st = RD_DATA_MEM;
	   else rd_ctrl_nxt_st = UPD_NXT_PTR;
	end

	RD_DATA_MEM: begin
	   if(rd_data_from_mem_vld) rd_ctrl_nxt_st = IDLE;
	   else rd_ctrl_nxt_st = RD_DATA_MEM;	   
	end

	default: begin
	   rd_ctrl_nxt_st = IDLE;	   
	end
	
      endcase // case (rd_ctrl_cur_st)      
   end   
   //------------//

   
endmodule // ll_rd_ctrl
