module tb;
   logic 		     clk;
   logic 		     reset_n;
   // Inputs from top to req_resp_intf //
   logic 		     req_vld;
   t_req_types req_type;
   logic [PTR_WD-1:0] 	     req_pos;
   logic [WR_DATA_WD-1:0]    req_data;
   logic 		     resp_taken;
   logic 		     resp_vld;
   logic 		     resp_type;
   logic 		     resp_data;
   logic 		     resp_data_vld;
   logic 		     intf_ready;
   int 			     count ;

   always #1 clk = ~clk;
   
   initial begin
      $dumpfile("dump.vcd"); $dumpvars;
      $display($time, " << Starting the Simulation >>");
      clk <= 0;
      count <= 0;
      reset_n <= 1;
      req_vld<= 0;
      req_type<= 0;
      req_pos<= 0;
      req_data<= 0;
      resp_taken<= 0;
      #10;
      reset_n <= 0;
      #200;
      $finish;
   end
   
   // driver logic
   always@(posedge clk) begin
      if(intf_ready & !reset_n & count < 5) begin
	 req_vld<= 1;
	 req_type<= PUSH_HEAD;
	 req_pos<= 0;
	 req_data<= (count == 0)? 'ha : (count == 1) ?  'hb : (count == 2)? 'hc: (count == 3) ? 'hd : (count == 4) ? 'he : 'hf;
      end
      else if(intf_ready & !reset_n & count >= 5) begin
	 req_vld<= 1;
	 req_type<= POP_HEAD_REQ;
	 req_pos<= 0;
	 req_data<= 0;    
      end
      else req_vld <=0;
     
      if(resp_vld) begin
	 req_vld<= 0;
	 resp_taken <= 1;
	 if(!resp_taken & count < 5) count <= count + 1;
      end  
      else resp_taken <= 0;
   end
   //------------//
   

   linked_list_top i_ll(
			.clk(clk),
			.reset_n(reset_n),
			// Inputs from top to req_resp_intf //
			.req_vld(req_vld),
			.req_type(req_type),
			.req_pos(req_pos),
			.req_data(req_data),
			.resp_taken(resp_taken),
			// Outputs from req_resp_intf //
			.resp_vld(resp_vld),
			.resp_type(resp_type),
			.resp_data(resp_data),
			.resp_data_vld(resp_data_vld),
			// output from req_resp_intf to indicate ll_ctrl FSM ready //
			.intf_ready(intf_ready)
			);
endmodule
