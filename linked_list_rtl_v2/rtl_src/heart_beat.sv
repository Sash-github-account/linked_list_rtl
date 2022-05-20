module heart_beat(
						input logic clk,
						input logic reset_n,
						// to top //
						output logic hb_pulse
						);
						
						
						
//----------- Declarations ------------//
// create a binary counter[29:0] cnt; //
// 2**29/150MHz = 3.5 sec, pulse width of 1.25 sec //
reg[31:0] cnt;
//-------------------------------------//


//------------ output ---------------------//
  assign hb_pulse = cnt[5];
//-----------------------------------------//



//-------------- counter -----------------//
always @(posedge clk) begin
	if(!reset_n) cnt  <= 0;
	else	cnt <= cnt + 1; // count up
end
//-----------------------------------------//

endmodule // heart_beat.sv
