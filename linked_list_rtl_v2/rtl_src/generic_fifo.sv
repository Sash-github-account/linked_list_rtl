module generic_fifo#(
							parameter FIFO_DATA_WIDTH = 8,
							parameter FIFO_DEPTH = 16
							)(
							input logic 							  clk,
							input logic 							  reset_n,
							input logic [FIFO_DATA_WIDTH-1:0]  fifo_data_in,
							input logic 							  fifo_data_push,
							input logic 							  fifo_data_pop,
							output logic [FIFO_DATA_WIDTH-1:0] fifo_data_out,
							output logic							  fifo_data_out_vld,
							output logic							  fifo_full,
							output logic							  fifo_empty
							);
							
//------- Declarations ----------//

localparam FIFO_PTR_WIDTH = $clog2(FIFO_DEPTH);
logic [FIFO_DATA_WIDTH -1:0]  fifo_array [0:FIFO_DEPTH-1];
logic [FIFO_PTR_WIDTH-1:0] 	rd_ptr;
logic [FIFO_PTR_WIDTH-1:0]		wr_ptr;
logic									upd_wr_ptr;
logic									upd_rd_ptr;

//--------------------------------//


//---------- output and fifo state --------------//
assign fifo_data_out_vld = !fifo_empty;
assign fifo_data_out = fifo_array[rd_ptr];
assign fifo_full = ((wr_ptr + 1) == rd_ptr) ? 1'b1 : 1'b0;
assign fifo_empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;
assign upd_wr_ptr = fifo_data_push & !fifo_full;
assign upd_rd_ptr = fifo_data_pop & !fifo_empty;
//------------------------------------------------//

//--------- FIFO logic -------------//
always_ff@(posedge clk) begin
	if(!reset_n) begin
		rd_ptr <= 0;
		wr_ptr <= 0;
		for(int i = 0; i < FIFO_DEPTH; i++) begin
			fifo_array[i] <= 0;
		end
	end
	else begin
		if(upd_wr_ptr & !upd_rd_ptr) begin
			fifo_array[wr_ptr] <= fifo_data_in;
			wr_ptr <= wr_ptr + 1;
			if(wr_ptr == FIFO_DEPTH - 1) wr_ptr <= 0;
		end
		
		else if(upd_rd_ptr & !upd_wr_ptr) begin
			rd_ptr <= rd_ptr + 1;
			if(rd_ptr == FIFO_DEPTH - 1) rd_ptr <= 0;
		end
		else if(upd_rd_ptr & upd_wr_ptr) begin
			wr_ptr <= wr_ptr;
			rd_ptr <= rd_ptr;
		end
	end
end
//------------------------------------//

endmodule // generic_fifo.sv //