module pulse_to_level(
								input logic clk,
								input logic reset_n,
								input logic pulse,
								input logic enable,
								input logic clear,
								output logic level
								);
								
//------------- Declarations ----------------//


//-------------------------------------------//


always_ff@(posedge clk) begin
	if(!reset_n) begin
		level <= 0;
	end
	else begin
		if(enable & pulse) level <= 1;
		else if (clear)	 level <= 0;
		else					 level <= level;
	end

end

endmodule // pulse_to_level.sv //