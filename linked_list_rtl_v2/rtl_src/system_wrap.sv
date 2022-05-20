//`include "param_types.sv"
//`include "includes.vh"
module system_wrap(
							input logic clk,
							input logic reset_n,
							// interface with ROM //
							output logic [ROM_ADDR_WIDTH-1:0]	rom_rd_addr,
							output logic 								CE_bar,
							output logic								OE_bar,
							output logic								WE_bar,
							input logic [ROM_DATA_WIDTH-1:0]		rom_rd_data,
							// system heart beat signal to top //
							output logic								hb_pulse
							);
							
							
//------- Declaration ----------//
 t_mainop_types req_main_op;
 t_specifier_types req_spec;
 /*
  logic [ROM_ADDR_WIDTH-1:0]	rom_rd_addr;
							 logic 								CE_bar;
							 logic								OE_bar;
							 logic								WE_bar;
  logic [ROM_DATA_WIDTH-1:0]		rom_rd_data;
							// interface with ll_engine //
							 logic 		           				  	req_vld;
							 t_mainop_types     					  	req_main_op;
							 t_specifier_types  					  	req_spec;
  logic [HEADPTR_ADDR_WIDTH-1:0]     req_ll_num_in;
  logic [NODENUM_WIDTH-1:0]     	  	req_pos;
  logic [DATA_WIDTH-1:0]  			  	req_data;
							 logic									  		intf_ready;
							 logic									  		resp_gen_cmpltd;
							 logic										batch_dma_done;
  logic 		           				  req_vld;
							 t_mainop_types     					  req_main_op;
							 t_specifier_types  					  req_spec;
  logic [HEADPTR_ADDR_WIDTH-1:0]     req_ll_num_in;
  logic [NODENUM_WIDTH-1:0]     	  req_pos;
  logic [DATA_WIDTH-1:0]  			  req_data;
							 logic									  intf_ready;
 
							 logic									  resp_gen_cmpltd;
							 logic									  hb_pulse_o;
							 */
//------------------------------//

assign hb_pulse = hb_pulse_o | !batch_dma_done;


//---------Gen by Python Script: integration_script.py ---------------//


 rom_dma_top i_rom_dma_top(
   .clk (clk),
 								.reset_n (reset_n),
 								.rom_rd_addr (rom_rd_addr),
 								.CE_bar (CE_bar),
 								.OE_bar (OE_bar),
 								.WE_bar (WE_bar),
 								.rom_rd_data (rom_rd_data),
 								.req_vld (req_vld),
 								.req_main_op (req_main_op),
 								.req_spec (req_spec),
 								.req_ll_num_in (req_ll_num_in),
 								.req_pos (req_pos),
 								.req_data (req_data),
 								.intf_ready (intf_ready),
 								.resp_gen_cmpltd (resp_gen_cmpltd),
								.batch_dma_done(batch_dma_done)
								);



 ll_engine_top i_ll_engine_top(
								.clk (clk),
 								.reset_n (reset_n),
 								.req_vld (req_vld),
 								.req_main_op (req_main_op),
 								.req_spec (req_spec),
 								.req_ll_num_in (req_ll_num_in),
 								.req_pos (req_pos),
 								.req_data (req_data),
 								.intf_ready (intf_ready),
 								.resp_gen_cmpltd (resp_gen_cmpltd),
 								.hb_pulse (hb_pulse_o)
								);


endmodule //system_wrap.sv

//---------Gen by Python Script: integration_script.py ---------------//
