module ll_mem_model # (
parameter WR_DATA_WD = DATA_WIDTH,
parameter DATA_DEPTH = DATAMEM_DEPTH,
parameter WR_ADDR_WD = $clog2(DATAMEM_DEPTH),
parameter RD_ADDR_WD  = $clog2(DATAMEM_DEPTH),
parameter RD_DATA_WD  = DATA_WIDTH
					)(
			    input logic 		  clk,
			    input logic 		  reset_n,
			    // From/to write controller //
			    input logic 		  wr_vld,
			    input logic [WR_ADDR_WD-1:0]  wr_addr,
			    input logic [WR_DATA_WD-1:0]  wr_data,
			    output logic 		  wr_done,
			    // From/to read controller //
			    input logic 		  rd_vld,
			    input logic [WR_ADDR_WD-1:0]  rd_addr,
			    output logic [WR_DATA_WD-1:0] rd_data,
			    output logic 		  rd_data_out_vld
			    );


   // Declarations //
	/*
	# (
parameter WR_DATA_WD = DATA_WIDTH,
parameter DATA_DEPTH = DATAMEM_DEPTH,
parameter WR_ADDR_WD = $clog2(DATAMEM_DEPTH),
parameter RD_ADDR_WD  = $clog2(DATAMEM_DEPTH),
parameter RD_DATA_WD  = DATA_WIDTH
					)
	*/
   logic [WR_DATA_WD-1:0] 				  data_mem [0:DATA_DEPTH-1];
   integer 						  i;   
   //--------------//
   


   // Write logic //
   always_ff@(posedge clk) begin
      if(!reset_n) begin
	 wr_done <= 0;
	 
	 for ( i=0; i < DATA_DEPTH-1; i = i +1) begin
	    data_mem[i] <= 0;
	 end
      end
      else begin
	 
	 if(wr_vld) begin
	    wr_done <= 1;	    
	    data_mem[wr_addr] <= wr_data;
	 end	 
	 else begin 
	    data_mem <= data_mem;
	    wr_done <= 0;
	 end
	 
      end             
   end // always_ff@ (posedge clk)
   //-----------//


   
   // Read logic //
   always_ff@(posedge clk) begin
      if(!reset_n) begin
	 rd_data <= 0;	 
	 rd_data_out_vld <= 0;
      end
      else begin
	 if(rd_vld) begin
	    rd_data <= data_mem[rd_addr];
	    rd_data_out_vld <= 1;
	 end
	 else begin
	    rd_data_out_vld <= 0;
	    rd_data <= 0;	    
	 end
      end
      
   end 
   //------------//

   
endmodule // linked_list_data_mem
