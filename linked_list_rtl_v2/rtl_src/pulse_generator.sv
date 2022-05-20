module pulse_generator(
								input logic clk,
								input logic reset_n,
								input logic start,
								output logic pulse,
								output logic pulse_not
								);

//------------ Declarations -----------------//
logic 									prev;
//-------------------------------------------//
								
assign pulse = ~prev & start; 
assign pulse_not = ~pulse; 


always_ff@(posedge clk ) begin
	if(!reset_n) begin
		prev <= 0;
	end
	else begin
		prev <= pulse; // for pulse generation //
	end
end

endmodule // pulse_generator.sv
