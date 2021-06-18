`include "param_types.sv"
`include "hd_ptr.sv"
//`inlcude "linked_list_data_mem.sv"
`include "ll_nxt_ptr_logic.sv"
`include "ll_rd_ctrl.sv"
`include "ll_req_resp_intf.sv"
//`inlcude "ll_wr_ctrl.sv"
`include "nxt_ptr_req_servr.sv"

module linked_list_top(
		       input logic 		     clk,
		       input logic 		     reset_n,
		       // Inputs from top to req_resp_intf //
		       input logic 		     req_vld,
		       input 			     t_req_types req_type,
		       input logic [PTR_WD-1:0]      req_pos,
		       input logic [WR_DATA_WD-1:0]  req_data,
		       input logic 		     resp_taken,
		       // Outputs from req_resp_intf //
		       output logic 		     resp_vld,
		       output 			     t_resp_types resp_type,
		       output logic [WR_DATA_WD-1:0] resp_data,
		       output logic 		     resp_data_vld,
		       // output from req_resp_intf to indicate ll_ctrl FSM ready //
		       output logic 		     intf_ready
		       );


   // Declarations //
   logic 					     i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_vld;         
   logic 					     i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_insert;      
   logic [WR_DATA_WD-1:0] 			     i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_data_nxt_ptr;  
   logic 					     i_ll_wr_ctrl_to_i_ll_req_resp_intf_wr_ctrl_fsm_ready_in;
   
   logic 					     i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_req_vld;
   logic 					     i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_req_pop;   
   logic [PTR_WD-1:0] 				     i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_node_at_pos;
   logic 					     i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_data_out_vld;   
   logic [WR_DATA_WD-1:0] 			     i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_data_out;
   logic 					     i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_ctrl_ready;
 
   logic 					     i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_make_ll_empty;
   logic 					     i_ll_nxt_ptr_logic_to_i_ll_req_resp_intf_ll_empty;   
   logic [PTR_WD-1:0] 				     i_ll_nxt_ptr_logic_to_i_ll_req_resp_intf_ll_size;
   
   logic [RD_DATA_WD-1:0] 			     i_ll_nxt_ptr_logic_to_i_ll_rd_ctrl_rd_data;
   logic 					     i_ll_nxt_ptr_logic_to_i_ll_rd_ctrl_rd_data_out_vld;
   logic 					     i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_vld;
   logic 					     i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_delete;
   logic [RD_ADDR_WD-1:0] 			     i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_addr;

   logic [WR_ADDR_WD-1:0] 			     i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_wr_pos;

   logic 					     i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_upd_nxt_ptr;   
   logic 					     i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_upd_nxt_ptr_insert;   
   logic [PTR_WD-1:0] 				     i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_cur_nxt_ptr;
   logic 					     i_ll_nxt_ptr_logic_to_i_ll_wr_ctrl_wr_done;
  
   logic 					     i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_vld;
   logic [WR_ADDR_WD-1:0] 			     i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_addr;
   logic [WR_DATA_WD-1:0] 			     i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_data;
   logic 					     i_linked_list_data_mem_to_i_ll_wr_ctrl_wr_done;
   
   logic 					     i_ll_rd_ctrl_to_i_linked_list_data_mem_rd_vld;
   logic [RD_ADDR_WD-1:0] 			     i_ll_rd_ctrl_to_i_linked_list_data_mem_rd_addr;
   logic [RD_DATA_WD-1:0] 			     i_linked_list_data_mem_to_i_ll_rd_ctrl_rd_data;
   logic 					     i_linked_list_data_mem_to_i_ll_rd_ctrl_rd_data_out_vld;
 
   logic [PTR_WD-1:0] 				     i_nxt_ptr_req_servr_to_i_ll_wr_ctrl_nxt_ptr;
   logic 					     i_ll_wr_ctrl_to_i_nxt_ptr_req_servr_upd_nxt_ptr;

   logic 					     i_ll_req_resp_intf_to_i_nxt_ptr_req_servr_make_ll_empty;
   logic 					     i_nxt_ptr_req_servr_to_i_ll_req_resp_intf_make_ll_empty;
   
   logic 					     i_ll_rd_ctrl_to_i_nxt_ptr_req_servr_rd_nxt_ptr_vld;
   logic [PTR_WD-1:0] 				     i_ll_rd_ctrl_to_i_nxt_ptr_req_servr_rd_data_from_nxt_ptr;
 
   logic 					     i_ll_req_resp_intf_i_hd_ptr_to_make_ll_empty;

   logic [WR_DATA_WD-1:0] 			     i_hd_ptr_cur_hd_ptr;

   logic 					     i_ll_req_resp_intf_combined_ll_empty_indicator_in;
   logic 					     hd_ptr_ll_empty;
 
   //-------------//
  

   // Assigns //
   assign hd_ptr_ll_empty = |i_hd_ptr_cur_hd_ptr;
   assign i_ll_wr_ctrl_to_i_nxt_ptr_req_servr_upd_nxt_ptr = i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_upd_nxt_ptr;
   assign i_ll_req_resp_intf_to_i_nxt_ptr_req_servr_make_ll_empty = i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_make_ll_empty;
   assign i_ll_req_resp_intf_i_hd_ptr_to_make_ll_empty = i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_make_ll_empty;
   assign i_ll_req_resp_intf_combined_ll_empty_indicator_in = i_ll_nxt_ptr_logic_to_i_ll_req_resp_intf_ll_empty & i_nxt_ptr_req_servr_to_i_ll_req_resp_intf_make_ll_empty & hd_ptr_ll_empty;  
   //-----------//


					
   //// ---Insatantiations---- ////

   // Head pointer logic //
  hd_ptr i_hd_ptr(
	      .clk(clk),
	      .reset_n(reset_n),
	      // Update requests from req_resp_intf //
	      .upd_hd_ptr(),
	      .make_ll_empty(i_ll_req_resp_intf_i_hd_ptr_to_make_ll_empty),
	      .new_hd_ptr(),
	      // current head pointer to other blocks //
	      .cur_hd_ptr(i_hd_ptr_cur_hd_ptr)
	      );  
   //------------//

   // Logic that keeps track of available memory pointers  //
   nxt_ptr_req_servr i_nxt_ptr_req_servr(
					 .clk(clk),
					 .reset_n(reset_n),
					 // From/to read controller //
					 .return_nxt_ptr(i_ll_rd_ctrl_to_i_nxt_ptr_req_servr_rd_nxt_ptr_vld),
					 .pos_2_return_nxt_ptr(i_ll_rd_ctrl_to_i_nxt_ptr_req_servr_rd_data_from_nxt_ptr),
					 // From/to req_resp_intf //
					 .make_ll_empty(i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_make_ll_empty),
					.ll_empty(i_nxt_ptr_req_servr_to_i_ll_req_resp_intf_make_ll_empty),
					 // From/to write pointer//
					 .upd_nxt_ptr(i_ll_wr_ctrl_to_i_rnxt_ptr_req_servr_upd_nxt_ptr),
					 .nxt_ptr(i_rnxt_ptr_req_servr_to_i_ll_wr_ctrl_nxt_ptr)
					 );
   //-----------//


   
   // Linked list data memory//
   linked_list_data_mem i_linked_list_data_mem(
					       .clk(clk),
					       .reset_n(reset_n),
					       // From/to write controller //
					       .wr_vld(i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_vld),
					       .wr_addr(i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_addr),
					       .wr_data(i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_data),
					       .wr_done(i_linked_list_data_mem_to_i_ll_wr_ctrl_wr_done),
					       // From/to read controller //
					       .rd_vld(i_ll_rd_ctrl_to_i_linked_list_data_mem_rd_vld),
					       .rd_addr(i_ll_rd_ctrl_to_i_linked_list_data_mem_rd_addr),
					       .rd_data(i_linked_list_data_mem_to_i_ll_rd_ctrl_rd_data),
					       .rd_data_out_vld(i_linked_list_data_mem_to_i_ll_rd_ctrl_rd_data_out_vld)
					       );
   //-----------//


   
   // Next pointer logic //
   ll_nxt_ptr_logic   i_ll_nxt_ptr_logic(
					 .clk(clk),
					 .reset_n(reset_n),
					 // from/to  write controller //
					 .wr_done(i_ll_nxt_ptr_logic_to_i_ll_wr_ctrl_wr_done),
					 .wr_vld(i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_upd_nxt_ptr),
					 .wr_insert(i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_upd_nxt_ptr_insert),
					 .wr_data_nxt_ptr(i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_cur_nxt_ptr),
					 // From/to read controller //
					 .rd_vld(i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_vld),
					 .rd_delete(i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_delete),
					 .rd_addr(i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_addr),
					 .rd_data(i_ll_nxt_ptr_logic_to_i_ll_rd_ctrl_rd_data),
					 .rd_data_out_vld(i_ll_nxt_ptr_logic_to_i_ll_rd_ctrl_rd_data_out_vld),
					 // From/to req_resp_intf //
					 .wr_pos(i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_wr_pos),
					 .make_ll_empty(i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_make_ll_empty),
					 .ll_empty(i_ll_nxt_ptr_logic_to_i_ll_req_resp_intf_ll_empty),
					 .ll_size(i_ll_nxt_ptr_logic_to_i_ll_req_resp_intf_ll_size)
					 );
   //------------//

   
   // Read controller //
   ll_rd_ctrl i_ll_rd_ctrl(
			   .clk(clk),
			   .reset_n(reset_n),
		  	   // Outputs to nxt_ptr_logic //
			   .req_vld_to_nxt_ptr(i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_vld),
			   .req_pop_to_nxt_ptr(i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_delete),
			   .node_at_pos_to_nxt_ptr(i_ll_rd_ctrl_to_i_ll_nxt_ptr_logic_rd_addr),
			   // Inputs from nxt_ptr_logic  //
			   .rd_nxt_ptr_vld(i_ll_nxt_ptr_logic_to_i_ll_rd_ctrl_rd_data_out_vld),
			   .rd_data_from_nxt_ptr(i_ll_nxt_ptr_logic_to_i_ll_rd_ctrl_rd_data),
			   // Outputs to nxt_ptr_req_serv //
			   .return_nxt_ptr(i_ll_rd_ctrl_to_i_nxt_ptr_req_servr_rd_nxt_ptr_vld),
			   .pos_2_return_nxt_ptr(i_ll_rd_ctrl_to_i_nxt_ptr_req_servr_rd_data_from_nxt_ptr),
			   // Outputs to data mem //
			   .rd_req_to_mem_vld(i_ll_rd_ctrl_to_i_linked_list_data_mem_rd_vld),
			   .rd_req_addr_to_mem(i_ll_rd_ctrl_to_i_linked_list_data_mem_rd_addr),
			   // Read data from data mem //
			   .rd_data_from_mem_vld(i_linked_list_data_mem_to_i_ll_rd_ctrl_rd_data_out_vld),
			   .rd_data_from_mem(i_linked_list_data_mem_to_i_ll_rd_ctrl_rd_data),
			   // read request from req_resp_intf //
			   .rd_req_vld(i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_req_vld),
			   .rd_req_pop(i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_req_pop),
			   .rd_node_at_pos(i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_node_at_pos),
			   // final read data sent to req_resp_intf //
			   .rd_ctrl_ready(i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_ctrl_ready),
			   .rd_data_out_vld(i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_data_out_vld),
			   .rd_data_out(i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_data_out)
			   );
   //------------//

   
   // Write controller //
   ll_wr_ctrl i_ll_wr_ctrl(
			   // From/to top //
			   .clk(clk),
			   .reset_n(reset_n),
			   // From/to req_resp_intf //
			   .data_to_wr(i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_data_nxt_ptr),
			   .data_to_wr_req(i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_vld),
			   .insert_data(i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_insert),
			   .wr_ctrl_fsm_ready(i_ll_wr_ctrl_to_i_ll_req_resp_intf_wr_ctrl_fsm_ready_in),
			   // From/to nxt avail ptr logic //
			   .nxt_ptr_from_servr(i_rnxt_ptr_req_servr_to_i_ll_wr_ctrl_nxt_ptr),
			   // From/to nxt_ptr_logic //
			   .nxt_ptr_wr_done(i_ll_nxt_ptr_logic_to_i_ll_wr_ctrl_wr_done),
			   .upd_nxt_ptr(i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_upd_nxt_ptr),
			   .upd_nxt_ptr_insert(i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_upd_nxt_ptr_insert), 
			   .cur_nxt_ptr(i_ll_wr_ctrl_to_i_ll_nxt_ptr_logic_cur_nxt_ptr),
			   // From/to data mem //
			   .data_mem_wr_cmpl(i_linked_list_data_mem_to_i_ll_wr_ctrl_wr_done),
			   .wr_data2ll_data_mem(i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_data),
			   .wr_data2ll_addr(i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_addr),
			   .wr_data2ll_vld(i_ll_wr_ctrl_to_i_linked_list_data_mem_wr_vld)
			   );
   //-----------------//
      

   // Request response interface //
     ll_req_resp_intf i_ll_req_resp_intf(
					 // From/to top //
					 .clk(clk),
					 .reset_n(reset_n),
					 .req_vld(req_vld),
					 .req_type(req_type),
					 .req_pos(req_pos),
					 .req_data(req_data),
					 .resp_taken(resp_taken),
					 .resp_vld(resp_vld),
					 .resp_type(resp_type),
					 .resp_data(resp_data),
					 .resp_data_vld(resp_data_vld),
					 .intf_ready(intf_ready),
					 // From/to nxt_ptr_logic //
					 .wr_pos(i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_wr_pos),
					 .make_ll_empty(i_ll_req_resp_intf_to_i_ll_nxt_ptr_logic_make_ll_empty),
					 .ll_empty(i_ll_req_resp_intf_combined_ll_empty_indicator_in),
					 .ll_size(i_ll_nxt_ptr_logic_to_i_ll_req_resp_intf_ll_size),
					 // From/to write controller //
					 .wr_vld(i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_vld),
					 .wr_insert(i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_insert),
					 .wr_data_nxt_ptr(i_ll_req_resp_intf_to_i_ll_wr_ctrl_wr_data_nxt_ptr),
					 .wr_ctrl_fsm_ready_in(i_ll_wr_ctrl_to_i_ll_req_resp_intf_wr_ctrl_fsm_ready_in),
					 // From/to read controller //
					 .rd_vld(i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_req_vld),
					 .rd_pop(i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_req_pop),
					 .rd_addr(i_ll_req_resp_intf_to_i_ll_rd_ctrl_rd_node_at_pos),
					 .rd_ctrl_ready_in(i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_ctrl_ready),
					 .rd_ctrl_data_out_vld(i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_data_out_vld),
					 .rd_ctrl_data_out(i_ll_rd_ctrl_to_i_ll_req_resp_intf_rd_data_out)
					 );
   //-------------//

endmodule // linked_list_top
