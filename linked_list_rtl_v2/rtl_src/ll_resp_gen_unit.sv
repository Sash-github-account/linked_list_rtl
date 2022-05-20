module ll_resp_gen_unit(
								input logic 			clk,
								input logic 			reset_n,
								// i/o with ll_mngr //
								input logic [NODENUM_WIDTH-1:0] 				resp_num_nodes,
								output logic										resp_gen_cmpltd,
								input logic 										resp_ll_nodes,
								input logic [HEADPTR_ADDR_WIDTH-1:0] 		resp_ll_num,
								output logic										ll_mngr_resp_gen_req_taken,
								input logic 										resp_tot_nodes,
								input logic											resp_no_op,
								input logic											resp_done,
								input logic											resp_gen_decode_err
								);
	


	
								
always_ff@(posedge clk ) begin
	if(!reset_n) begin
		ll_mngr_resp_gen_req_taken <= 0;
		resp_gen_cmpltd <= 0;
	end
	else begin
		if(resp_tot_nodes | resp_ll_nodes | resp_no_op | resp_gen_decode_err | resp_done) 	begin
			ll_mngr_resp_gen_req_taken <= 1;
			resp_gen_cmpltd <= 1;
		end
		else begin
			ll_mngr_resp_gen_req_taken <= 0;
			resp_gen_cmpltd <= 0;
		end
	end

end								
								
endmodule // ll_resp_gen_unit