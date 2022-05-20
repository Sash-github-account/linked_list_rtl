module rom_model#(parameter WR_ADDR_WD = 8, parameter WR_DATA_WD = 8, parameter DATA_DEPTH = 48)(
								 input logic clk,
								 input logic reset_n,
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
   //--------------//
  
   always_ff@(posedge clk) begin
      if(!reset_n)begin
	 for(int i=0; i < DATA_DEPTH-1; i++) begin
	    data_mem[i] <= 0;
	    
	 end
	 
      end
      else begin
	 data_mem[ 0 ] <= 8'b00001001;
	 
	 data_mem[ 1 ] <= 8'b00111111;
	 
	 data_mem[ 2 ] <= 8'b11001100;
	 
	 data_mem[ 3 ] <= 8'b11001100;
	 
	 data_mem[ 4 ] <= 8'b11001101;
	 
	 data_mem[ 5 ] <= 8'b00011111;
	 
		  data_mem[ 6 ] <= 8'b01000000;
	 
	 data_mem[ 7 ] <= 8'b01001000;
	 
	 data_mem[ 8 ] <= 8'b11110101;
	 
	 data_mem[ 9 ] <= 8'b11000011;
	 
	 data_mem[10 ] <= 8'b00100101;
	 
		  data_mem[11 ] <= 8'b00111111;
	 
	 data_mem[12 ] <= 8'b10110111;
	 
	 data_mem[13 ] <= 8'b00001010;
	 
	 data_mem[14 ] <= 8'b00111101;
	 
	 data_mem[15 ] <= 8'b00100101;
	 
	 data_mem[16 ] <= 8'b00111101;
	 
	 data_mem[17 ] <= 8'b01100111;
	 
	 data_mem[18 ] <= 8'b01001101;
	 
	 data_mem[19 ] <= 8'b00010110;
	 


       
		      end

   end


   
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
						
						
