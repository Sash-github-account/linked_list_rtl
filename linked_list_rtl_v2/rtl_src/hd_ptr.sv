module hd_ptr(
	      input logic 		clk,
	      input logic 		reset_n,
	      // Update requests from req_resp_intf //
	      input logic 		upd_hd_ptr,
	      input logic 		make_ll_empty,
	      input logic [PTR_WD-1:0] 	new_hd_ptr,
	      // current head pointer to other blocks //
	      output logic [PTR_WD-1:0] cur_hd_ptr
	      );

   // Head pointer logic //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 cur_hd_ptr <= -1;
	 
      end
      else begin
	 if (upd_hd_ptr & !make_ll_empty) begin
	    cur_hd_ptr <= new_hd_ptr;
	 end
	 else if(make_ll_empty)begin
	    cur_hd_ptr <= -1;
	 end
	 else begin
	    cur_hd_ptr <= cur_hd_ptr;
	 end	 
	 
      end
      
   end
   //----------//
  
endmodule // hd_ptr