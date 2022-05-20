module rom_dma_top(
							input logic clk,
							input logic reset_n,
							// interface with ROM //
							output logic [ROM_ADDR_WIDTH-1:0]	rom_rd_addr,
							output logic 								CE_bar,
							output logic								OE_bar,
							output logic								WE_bar,
							input logic [ROM_DATA_WIDTH-1:0]		rom_rd_data,
							// interface with ll_engine //
							output logic 		           				  	req_vld,
							output t_mainop_types     					  	req_main_op,
							output t_specifier_types  					  	req_spec,
							output logic [HEADPTR_ADDR_WIDTH-1:0]     req_ll_num_in,
							output logic [NODENUM_WIDTH-1:0]     	  	req_pos,
							output logic [DATA_WIDTH-1:0]  			  	req_data,
							input logic									  		intf_ready,
							input logic									  		resp_gen_cmpltd,
							output logic										batch_dma_done
							);
							
							
//------------- Declarations -----------------//
logic									start_rd;
logic									cfg_ready;
logic [ROM_ADDR_WIDTH-1:0]		cfg_dma_base_addr;
logic [ROM_ADDR_WIDTH-1:0]		cfg_dma_num_bytes;
logic									cfg_pulse;
logic									cfg_ok;
logic									enable_p2l;
logic									clear_p2l;
logic[7:0] 							rom_data_fifo_fifo_data_in;
logic[7:0]							rom_data_fifo_fifo_data_out;
//--------------------------------------------//

//-------- DMA Config Regs --------------//
heart_beat i_config_start_pulse(
						  .clk(clk),
						  .reset_n(reset_n),
						  .hb_pulse(cfg_pulse)
						);
						
pulse_to_level i_pulse_to_level(
								  .clk(clk),
								  .reset_n(reset_n),
								  .pulse(cfg_pulse),
								  .enable(enable_p2l),
								  .clear(clear_p2l | batch_dma_done),
								  .level(cfg_ok)
								);
								
								
always_ff@(posedge clk) begin
	if(!reset_n) begin
		start_rd <= 0;
		cfg_ready <= 0;
		cfg_dma_base_addr <= 0;
		cfg_dma_num_bytes <= 0;
		enable_p2l <= 0;
		clear_p2l <= 0;
	end
	else begin
		enable_p2l <= 1;
		clear_p2l <= 0;
		
		if(cfg_ok) begin
			start_rd <= 1;
			cfg_ready <= 1;
			cfg_dma_base_addr <= 0;
			cfg_dma_num_bytes <= NUM_VLD_ROM_DATA;
		end
		
	end
end
//---------------------------------------//


//---------Gen by Python Script: integration_script.py ---------------//


 rom_dma_ll_intf i_rom_dma_ll_intf(
								.clk (clk),
 								.reset_n (reset_n),
 								.rom_data_fifo_fifo_data_pop (rom_data_fifo_fifo_data_pop),
 								.rom_data_fifo_fifo_data_out (rom_data_fifo_fifo_data_out),
 								.rom_data_fifo_fifo_data_out_vld (rom_data_fifo_fifo_data_out_vld),
 								.rom_data_fifo_fifo_full (rom_data_fifo_fifo_full),
 								.rom_data_fifo_fifo_empty (rom_data_fifo_fifo_empty),
 								.req_vld (req_vld),
 								.req_main_op (req_main_op),
 								.req_spec (req_spec),
 								.req_ll_num_in (req_ll_num_in),
 								.req_pos (req_pos),
 								.req_data (req_data),
 								.intf_ready (intf_ready),
 								.resp_gen_cmpltd (resp_gen_cmpltd)
								);



 rom_dma_ctrl i_rom_dma_ctrl(
								.clk (clk),
 								.reset_n (reset_n),
 								.rom_data_fifo_fifo_data_in (rom_data_fifo_fifo_data_in),
 								.rom_data_fifo_fifo_data_push (rom_data_fifo_fifo_data_push),
 								.rom_data_fifo_fifo_full (rom_data_fifo_fifo_full),
 								.rom_data_fifo_fifo_empty (rom_data_fifo_fifo_empty),
 								.rom_rd_addr (rom_rd_addr),
 								.CE_bar (CE_bar),
 								.OE_bar (OE_bar),
 								.WE_bar (WE_bar),
 								.rom_rd_data (rom_rd_data),
 								.start_rd (start_rd),
 								.cfg_ready (cfg_ready),
 								.cfg_dma_base_addr (cfg_dma_base_addr),
 								.cfg_dma_num_bytes (cfg_dma_num_bytes),
								.batch_dma_done(batch_dma_done)
								);



 generic_fifo #(.FIFO_DATA_WIDTH(8), .FIFO_DEPTH(16)) i_rom_data_fifo(
								.clk (clk),
 								.reset_n (reset_n),
 								.fifo_data_in (rom_data_fifo_fifo_data_in),
 								.fifo_data_push (rom_data_fifo_fifo_data_push),
 								.fifo_data_pop (rom_data_fifo_fifo_data_pop),
 								.fifo_data_out (rom_data_fifo_fifo_data_out),
 								.fifo_data_out_vld (rom_data_fifo_fifo_data_out_vld),
 								.fifo_full (rom_data_fifo_fifo_full),
 								.fifo_empty (rom_data_fifo_fifo_empty)
								);


endmodule //rom_dma_top.sv

//---------Gen by Python Script: integration_script.py ---------------//
