//`include "detect_pos_first_one.v"

module ll_nxt_avail_memptr_gen(
			 input logic 		   			clk,
			 input logic 		   			reset_n,
			 // disabling avail ptrs corresponding to cfgd. hdptr //
			 input logic [PTR_WD-1:0] 		hdptr_cfg_value,
			 input logic 						hdptr_cfg_value_vld,
			 // Update from write controller //
			 input logic 		   			upd_nxt_ptr,
			 // pointer returned from read controller //
			 input logic 		   			return_nxt_ptr,
			 input logic [PTR_WD-1:0]  	pos_2_return_nxt_ptr,
			 // make linked list empty - command from req_resp_intf //
			 input logic 		   			make_ll_empty,
			 // Indicate ll_empty to req_resp_intf //
			 output logic 		   			ll_ptrs_empty,
			 // Output to write controller //
			 output logic [PTR_WD-1:0] 	nxt_ptr_out
			 );


// Declarations //
logic [0:DATAMEM_DEPTH-1] 			  nxt_ptr_avail;
logic [PTR_WD-1:0] 				  nxt_ptr;   
//-----------//

// Assignments //
assign ll_ptrs_empty = &nxt_ptr_avail;   
assign nxt_ptr_out = nxt_ptr;   
//--------------//

// Update next pointer available vector //
always_ff@(posedge clk ) begin
	if(!reset_n) begin
		nxt_ptr_avail <= {DATAMEM_DEPTH{1'b1}};
	end
	else begin
		if(upd_nxt_ptr)																	nxt_ptr_avail[nxt_ptr] <= 0;
		else if(hdptr_cfg_value_vld)													nxt_ptr_avail[hdptr_cfg_value] <= 0;
		else if(return_nxt_ptr & !nxt_ptr_avail[pos_2_return_nxt_ptr])		nxt_ptr_avail[pos_2_return_nxt_ptr] <= 1;
		else if(make_ll_empty)	 														nxt_ptr_avail <= {DATAMEM_DEPTH{1'b1}};
		else 																					nxt_ptr_avail <= nxt_ptr_avail;
	end
	
end // always_ff@ (posedge clk)
//--------//


// Detect next available nxt_ptr //
detect_pos_first_one #(DATAMEM_DEPTH) i_dpfo(
					  .data_i(nxt_ptr_avail),
					  .pos_o(nxt_ptr)
					  );

//-----------//
   
endmodule // ll_nxt_avail_memptr_gen