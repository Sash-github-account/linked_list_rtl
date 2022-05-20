// Code your testbench here
// or browse Examples
//`include "param_types.sv"
//`include "rom_model.sv"

module tb_top;
  
  parameter WR_ADDR_WD = 8; 
  parameter WR_DATA_WD = 8; 
  parameter DATA_DEPTH = 21;
  
  logic clk;
							 logic reset_n;
							// interface with ROM //
  logic [ROM_ADDR_WIDTH-1:0]	rom_rd_addr;
							 logic 								CE_bar;
							 logic								OE_bar;
							 logic								WE_bar;
  logic [ROM_DATA_WIDTH-1:0]		rom_rd_data;
							// system heart beat signal to top //
							 logic								hb_pulse;
  logic 		  rd_vld;
  logic [WR_ADDR_WD-1:0]  rd_addr;
  logic [WR_DATA_WD-1:0] rd_data;
								  logic 		  rd_data_out_vld;
  
  
  assign rd_vld = !CE_bar & !OE_bar & WE_bar;
  assign rd_addr = rom_rd_addr;
  assign rom_rd_data = rd_data;
  
  initial begin
    $dumpfile("dump1.vcd"); $dumpvars;
    clk <= 0;
    reset_n <= 0;
    #50 reset_n <= 1;
    #6000 $finish;
  end
  
  always #2 clk <= !clk;
  
  system_wrap i_s_w(
    .clk(clk),
    .reset_n(reset_n),
							// interface with ROM //
    .rom_rd_addr(rom_rd_addr),
    .CE_bar(CE_bar),
    .OE_bar(OE_bar),
    .WE_bar(WE_bar),
    .rom_rd_data(rom_rd_data),
							// system heart beat signal to top //
    .hb_pulse(hb_pulse)
							);
  
  rom_model #(.DATA_DEPTH(NUM_VLD_ROM_DATA))i_r_m(
    .clk(clk),
    .reset_n(reset_n),
								 // From/to read controller //
    .rd_vld(rd_vld),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .rd_data_out_vld(rd_data_out_vld)
								 );
  
endmodule
