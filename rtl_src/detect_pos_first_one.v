module detect_pos_first_one 
  #(parameter D_WIDTH = 16)
   (
    input [D_WIDTH-1:0] 	     data_i,
    output reg [$clog2(D_WIDTH)-1:0] pos_o
    );
   
   
   
   // Declarations //
   genvar 			     i;
   //______________//
   

   
   // Compute position of first one //
   generate
      for (i = 0; i < D_WIDTH; i=i+1) begin
	 always@(*) begin
	    if (data_i[i] == 1'b1) pos_o = D_WIDTH - (i+1);
	 end
      end	
   endgenerate
   //______________//
   

   
endmodule // detect_pos_first_one


