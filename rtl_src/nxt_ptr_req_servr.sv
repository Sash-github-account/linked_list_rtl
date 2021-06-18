`include "detect_pos_first_one.v"

module nxt_ptr_req_servr(
			 input logic 		   clk,
			 input logic 		   reset_n,
			 // Update from write controller //
			 input logic 		   upd_nxt_ptr,
			 // pointer returned from read controller //
			 input logic 		   return_nxt_ptr,
			 input logic [PTR_WD-1:0]  pos_2_return_nxt_ptr,
			 // make linked list empty - command from req_resp_intf //
			 input logic 		   make_ll_empty,
			 // Indicate ll_empty to req_resp_intf //
			 output logic 		   ll_empty,
			 // Output to write controller //
			 output logic [PTR_WD-1:0] nxt_ptr
			 );


   // Declarations //
   logic [DATA_DEPTH-1:0] 			  nxt_ptr_avail;
   //-----------//

   // Assignments //
   assign ll_empty = &nxt_ptr_avail;   
   //--------------//
   
   // Update next pointer available vector //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 nxt_ptr_avail <= {DATA_DEPTH{1'b1}};
	 
      end
      else begin
	 if(upd_nxt_ptr) nxt_ptr_avail[nxt_ptr] <= 0;
	 else if(return_nxt_ptr & !nxt_ptr_avail[pos_2_return_nxt_ptr]) nxt_ptr_avail[pos_2_return_nxt_ptr] <= 1;
	 else if(make_ll_empty)	 nxt_ptr_avail <= {DATA_DEPTH{1'b1}};
	 else nxt_ptr_avail <= nxt_ptr_avail;

	 
      end
      
   end // always_ff@ (posedge clk)
   //--------//
   

   // Detect next available nxt_ptr //
   detect_pos_first_one #(DATA_DEPTH) i_dpfo(
					     .data_i(nxt_ptr_avail),
					     .pos_o(nxt_ptr)
					     );

   //-----------//
   
endmodule // nxt_ptr_req_servr
