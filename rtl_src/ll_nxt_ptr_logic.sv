module ll_nxt_ptr_logic(
			input logic 		      clk,
			input logic 		      reset_n,
			// inputs from write controller //
			input logic 		      wr_vld,
			input logic 		      wr_insert,
			input logic [WR_DATA_WD-1:0]  wr_data_nxt_ptr,
			// inputs from read controller //
			input logic 		      rd_vld,
			input logic 		      rd_delete,
			input logic [RD_ADDR_WD-1:0]  rd_addr,
			// From/to req_resp_intf //
			input logic 		      make_ll_empty,
			input logic [WR_ADDR_WD-1:0]  wr_pos,
			output logic 		      ll_empty,
			output logic [PTR_WD-1:0]     ll_size,
			// Indicate nxt_ptr updation done to write controller //
			output logic 		      wr_done,
			// Outputs to return nxt_ptr value during read operation //
			output logic [RD_DATA_WD-1:0] rd_data,
			output logic 		      rd_data_out_vld
			);


   // Declarations //
   logic [WR_DATA_WD-1:0] 			      nxt_ptr_mem [DATA_DEPTH:0];
   logic [PTR_WD-1:0] 				      node_cnt;
   //-------------//
   

   // Assigns //
   assign ll_empty = (node_cnt == 0) ? 1:0;
   assign ll_size = node_cnt;
   //-----------//
   

   // node count updation logic //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 node_cnt <= 0;	 
      end
      else begin
	 if(wr_vld & node_cnt < DATA_DEPTH) node_cnt <= node_cnt + 1;
	 else if (rd_delete & node_cnt > 0) node_cnt <= node_cnt - 1;
	 else if (make_ll_empty) node_cnt <= 0;	 
	 else node_cnt <= node_cnt;	 
      end
      
   end
   //-------//

   
   // Update new next pointer //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 wr_done <= 0;
	 rd_data <= 0;
	 rd_data_out_vld <= 0;
         for (int i=0; i < DATA_DEPTH-1; i = i +1) begin
	    nxt_ptr_mem[i] <= 0;
	 end
      end
      else begin
	 
	 if(wr_vld) begin
	    wr_done <= 1;
	    if(!wr_insert) begin
	       nxt_ptr_mem[node_cnt] <= wr_data_nxt_ptr;
	       
	    end
	    else begin
               for (int i=0; i < DATA_DEPTH-1; i = i +1) begin
		  if(i > wr_pos & i<node_cnt) nxt_ptr_mem[i] <= nxt_ptr_mem[i-1];
		  else if(i == wr_pos) nxt_ptr_mem[i] <= wr_data_nxt_ptr;		  
		  else if(i < wr_pos) nxt_ptr_mem[i] <= nxt_ptr_mem[i];		  
		  else nxt_ptr_mem[i] <= nxt_ptr_mem[i];
		  
	       end
	    end
	    
	 end	 
	 else begin 
	    nxt_ptr_mem <= nxt_ptr_mem;
	    wr_done <= 0;	    
	 end // else: !if(wr_vld)

	 if(rd_vld) begin
	    if(!rd_delete) begin
	       rd_data <= nxt_ptr_mem[rd_addr];
	       rd_data_out_vld <= 1;
	    end
	    else begin
	       rd_data_out_vld <= 1;
	       rd_data <= nxt_ptr_mem[rd_addr];
               for ( int i=0; i < DATA_DEPTH-1; i = i +1) begin
		  if(i >= wr_pos & i<node_cnt) nxt_ptr_mem[i] <= nxt_ptr_mem[i+1];
		  else if(i == wr_pos-1) nxt_ptr_mem[i] <= wr_data_nxt_ptr;		  
		  else nxt_ptr_mem[i] <= nxt_ptr_mem[i];
		  
	       end
	    end
	    
	 end // if (rd_vld)
	 else if(make_ll_empty) begin
	    rd_data_out_vld <= 1;
	    rd_data <= 0; 
	 end	 
	 else begin
	    rd_data_out_vld <= 0;
	    rd_data <= 0;	    
	 end	 
	 
	 
      end             
   end // always_ff@ (posedge clk)
   //---------//
   
   
   
endmodule
