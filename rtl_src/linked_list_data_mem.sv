module linked_list_data_mem(
			    input logic 		  clk,
			    input logic 		  reset_n,
			    // From/to write controller //
			    input logic 		  wr_vld,
			    input logic [WR_ADDR_WD-1:0]  wr_addr,
			    input logic [WR_DATA_WD-1:0]  wr_data,
			    output logic 		  wr_done,
			    // From/to read controller //
			    input logic 		  rd_vld,
			    input logic [RD_ADDR_WD-1:0]  rd_addr,
			    output logic [RD_DATA_WD-1:0] rd_data,
			    output logic 		  rd_data_out_vld
			    );

   logic [WR_DATA_WD-1:0] 				  data_mem [DATA_DEPTH:0];

   always_ff@(posedge clk) begin
      if(reset_n) begin
	 wr_done <= 0;
	 
	 for (int i=0; i < DATA_DEPTH-1; i = i +1) begin
	    data_mem[i] <= 0;
	 end
      end
      else begin
	 
	 if(wr_vld) begin
	    wr_done <= 1;	    
	    data_mem[wr_addr] <= wr_data;
	 end	 
	 else data_mem <= data_mem;

	 if(rd_vld) begin
	    rd_data <= data_mem[rd_addr];
	    rd_data_out_vld <= 1;
	 end
	 else begin
	    rd_data_out_vld <= 0;
	 end
	 
      end             
   end
   
endmodule
