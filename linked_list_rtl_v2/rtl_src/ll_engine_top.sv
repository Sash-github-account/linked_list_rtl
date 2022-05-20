module ll_engine_top(
							input logic clk,
							input logic reset_n,
							input logic 		           				  req_vld,
							input t_mainop_types     					  req_main_op,
							input t_specifier_types  					  req_spec,
							input logic [HEADPTR_ADDR_WIDTH-1:0]     req_ll_num_in,
							input logic [NODENUM_WIDTH-1:0]     	  req_pos,
							input logic [DATA_WIDTH-1:0]  			  req_data,
							output logic									  intf_ready,
							output logic									  resp_gen_cmpltd,
							output logic									  hb_pulse
							);


//---------- Declarations ---------------//
/*
.WR_DATA_WD (DATA_WIDTH),
 .DATA_DEPTH (DATAMEM_DEPTH),
 .WR_ADDR_WD ($clog2(DATAMEM_DEPTH)),
 .RD_ADDR_WD  ($clog2(DATAMEM_DEPTH)),
 .RD_DATA_WD  (DATA_WIDTH)
 
*/
  
  logic [3:0] node_cntr_rd_data;
  logic [1:0] node_cntr_rd_addr;
  logic [3:0] node_cntr_wr_data;
  logic [1:0] node_cntr_wr_addr;
  logic [3:0] hdptr_rd_data;
  logic [1:0] hdptr_rd_addr;
  logic [3:0] hdptr_wr_data;
  logic [1:0] hdptr_wr_addr;
  logic [3:0] nxtptr_mem_rd_data;
  logic [3:0] nxtptr_mem_rd_addr;
  logic [3:0] nxtptr_mem_wr_data;
  logic [3:0] nxtptr_mem_wr_addr;
  logic [7:0] data_mem_rd_data;
  logic [3:0] data_mem_rd_addr;
  logic [7:0] data_mem_wr_data;
  logic [3:0] data_mem_wr_addr;
  logic [1:0] resp_ll_num;
  logic [3:0] resp_num_nodes;
  logic [3:0] nxt_ptr_out;
  logic [3:0] pos_2_return_nxt_ptr;
  logic [3:0] hdptr_cfg_value;
  logic [3:0] wr_ctrl_ndptr_Nminus2;
  logic [3:0] wr_ctrl_ndptr_N;
  logic [3:0] wr_ctrl_wrback_ptr;
  logic [7:0] wr_ctrl_wrback_data;
  logic [7:0] wr_ctrl_data;
  logic [3:0] wr_ctrl_nodeptr_for_write;
  logic [3:0] wr_ctrl_nxtptr_for_hdptr_update;
  logic [3:0] rd_ctrl_wrback_ptr;
  logic [7:0] rd_ctrl_data_value;
  logic [3:0] rd_ctrl_nxtptr_value;
  logic [3:0] rd_ctrl_nxtptr_Nminus2_rd_data;
  logic [3:0] rd_ctrl_nxtptr_Nminus1_rd_data;
  logic [3:0] rd_ctrl_nxtptr_N_rd_data;
  logic [3:0] rd_ctrl_ll_ptr;
  logic [3:0] rd_ctrl_ll_node_cnt;
  logic [3:0] req_middle_node_pos;
  logic [3:0] req_hdptr_cfgrd_ndnum_value;
  logic [1:0] req_ll_num;
  logic [7:0] req_data_out;
//---------------------------------------//



//---------Gen by Python Script: integration_script.py ---------------//


 ll_op_decode_unit i_ll_op_decode_unit(
								.clk (clk),
 								.reset_n (reset_n),
 								.req_vld (req_vld),
 								.req_main_op (req_main_op),
 								.req_spec (req_spec),
 								.req_ll_num_in (req_ll_num_in),
 								.req_pos (req_pos),
 								.req_data (req_data),
 								.req_del_node_at_node_num (req_del_node_at_node_num),
 								.req_del_node_at_head (req_del_node_at_head),
 								.req_del_node_at_tail (req_del_node_at_tail),
 								.req_add_node_at_node_num (req_add_node_at_node_num),
 								.req_add_node_at_head (req_add_node_at_head),
 								.req_add_node_at_tail (req_add_node_at_tail),
 								.req_rd_ll_reg (req_rd_ll_reg),
 								.req_delete_ll (req_delete_ll),
 								.req_ll_num (req_ll_num),
 								.req_cfg_num_actv_ll (req_cfg_num_actv_ll),
 								.req_cfg_set_hdptr (req_cfg_set_hdptr),
 								.req_hdptr_cfgrd_ndnum_value (req_hdptr_cfgrd_ndnum_value),
 								.req_middle_node_pos (req_middle_node_pos),
 								.req_data_out (req_data_out),
 								.req_taken (req_taken),
 								.ll_mngr_fsm_idle (ll_mngr_fsm_idle),
 								.intf_ready (intf_ready),
 								.resp_gen_cmpltd (resp_gen_cmpltd),
 								.resp_gen_decode_err (resp_gen_decode_err),
 								.resp_gen_decode_err_type (resp_gen_decode_err_type),
								.resp_no_op(resp_no_op)
								);



 ll_mngr i_ll_mngr(
								.clk (clk),
 								.reset_n (reset_n),
 								.req_del_node_at_node_num (req_del_node_at_node_num),
 								.req_del_node_at_head (req_del_node_at_head),
 								.req_del_node_at_tail (req_del_node_at_tail),
 								.req_add_node_at_node_num (req_add_node_at_node_num),
 								.req_add_node_at_head (req_add_node_at_head),
 								.req_add_node_at_tail (req_add_node_at_tail),
 								.req_rd_ll_reg (req_rd_ll_reg),
 								.req_cfg_delete_ll (req_cfg_delete_ll),
 								.req_ll_num (req_ll_num),
 								.req_data (req_data),
 								.req_cfg_num_actv_ll (req_cfg_num_actv_ll),
 								.req_cfg_set_hdptr (req_cfg_set_hdptr),
 								.req_hdptr_cfgrd_ndnum_value (req_hdptr_cfgrd_ndnum_value),
 								.req_middle_node_pos (req_middle_node_pos),
 								.ll_mngr_fsm_idle (ll_mngr_fsm_idle),
 								.req_taken (req_taken),
 								.hdptr_cfg_value (hdptr_cfg_value),
 								.hdptr_cfg_value_vld (hdptr_cfg_value_vld),
 								.pos_2_return_nxt_ptr (pos_2_return_nxt_ptr),
 								.return_nxt_ptr (return_nxt_ptr),
 								.rd_ctrl_ready (rd_ctrl_ready),
 								.rd_ctrl_single_rd_req (rd_ctrl_single_rd_req),
 								.rd_ctrl_traverse_ll (rd_ctrl_traverse_ll),
 								.rd_ctrl_traverse_ll_for_middle_node_del (rd_ctrl_traverse_ll_for_middle_node_del),
 								.rd_ctrl_traverse (rd_ctrl_traverse),
 								.rd_ctrl_count_down_nxtptr (rd_ctrl_count_down_nxtptr),
 								.rd_ctrl_traverse_ll_wrback_data (rd_ctrl_traverse_ll_wrback_data),
 								.rd_ctrl_send_wrback_reg_value (rd_ctrl_send_wrback_reg_value),
 								.rd_ctrl_ll_node_cnt (rd_ctrl_ll_node_cnt),
 								.rd_ctrl_ll_ptr (rd_ctrl_ll_ptr),
 								.rd_ctrl_nxtptr_value (rd_ctrl_nxtptr_value),
 								.rd_ctrl_nxtptr_vld (rd_ctrl_nxtptr_vld),
 								.rd_ctrl_data_value (rd_ctrl_data_value),
 								.rd_ctrl_data_vld (rd_ctrl_data_vld),
 								.rd_ctrl_wrback_ptr (rd_ctrl_wrback_ptr),
 								.rd_ctrl_wrback_ptr_vld (rd_ctrl_wrback_ptr_vld),
 								.ll_mngr_resp_taken (ll_mngr_resp_taken),
 								.rd_ctrl_upd_nxtptr_for_mid_node_del (rd_ctrl_upd_nxtptr_for_mid_node_del),
 								.rd_ctrl_nxtptr_N_rd_data (rd_ctrl_nxtptr_N_rd_data),
 								.rd_ctrl_nxtptr_Nminus1_rd_data (rd_ctrl_nxtptr_Nminus1_rd_data),
 								.rd_ctrl_nxtptr_Nminus2_rd_data (rd_ctrl_nxtptr_Nminus2_rd_data),
 								.wr_ctrl_wrdata_ndptr_vld (wr_ctrl_wrdata_ndptr_vld),
 								.wr_ctrl_direct_wr (wr_ctrl_direct_wr),
 								.wr_ctrl_nxtptr_for_hdptr_update_taken (wr_ctrl_nxtptr_for_hdptr_update_taken),
 								.wr_ctrl_ready (wr_ctrl_ready),
 								.wr_ctrl_req_taken (wr_ctrl_req_taken),
 								.wr_ctrl_nxtptr_for_hdptr_update_vld (wr_ctrl_nxtptr_for_hdptr_update_vld),
 								.wr_ctrl_nxtptr_for_hdptr_update (wr_ctrl_nxtptr_for_hdptr_update),
 								.wr_ctrl_nodeptr_for_write (wr_ctrl_nodeptr_for_write),
 								.wr_ctrl_nodeptr_vld (wr_ctrl_nodeptr_vld),
 								.wr_ctrl_data (wr_ctrl_data),
 								.wr_ctrl_data_vld (wr_ctrl_data_vld),
 								.wr_ctrl_writeback_seq (wr_ctrl_writeback_seq),
 								.wr_ctrl_wrback_data (wr_ctrl_wrback_data),
 								.wr_ctrl_wrback_data_vld (wr_ctrl_wrback_data_vld),
 								.wr_ctrl_wrback_ptr (wr_ctrl_wrback_ptr),
 								.wr_ctrl_wrback_ptr_vld (wr_ctrl_wrback_ptr_vld),
 								.wr_ctrl_ndptr_N (wr_ctrl_ndptr_N),
 								.wr_ctrl_ndptr_Nminus2 (wr_ctrl_ndptr_Nminus2),
 								.wr_ctrl_del_mid_ndptrs_vld (wr_ctrl_del_mid_ndptrs_vld),
 								.node_cntr_wr_vld (node_cntr_wr_vld),
 								.node_cntr_wr_addr (node_cntr_wr_addr),
 								.node_cntr_wr_data (node_cntr_wr_data),
 								.node_cntr_wr_done (node_cntr_wr_done),
 								.node_cntr_rd_vld (node_cntr_rd_vld),
 								.node_cntr_rd_addr (node_cntr_rd_addr),
 								.node_cntr_rd_data (node_cntr_rd_data),
 								.node_cntr_rd_data_out_vld (node_cntr_rd_data_out_vld),
 								.hdptr_wr_vld (hdptr_wr_vld),
 								.hdptr_wr_addr (hdptr_wr_addr),
 								.hdptr_wr_data (hdptr_wr_data),
 								.hdptr_wr_done (hdptr_wr_done),
 								.hdptr_rd_vld (hdptr_rd_vld),
 								.hdptr_rd_addr (hdptr_rd_addr),
 								.hdptr_rd_data (hdptr_rd_data),
 								.hdptr_rd_data_out_vld (hdptr_rd_data_out_vld),
 								.ll_mngr_resp_gen_req_taken (ll_mngr_resp_gen_req_taken),
 								.resp_tot_nodes (resp_tot_nodes),
 								.resp_num_nodes (resp_num_nodes),
 								.resp_ll_nodes (resp_ll_nodes),
 								.resp_ll_num (resp_ll_num),
								.resp_done(resp_done),
								.hb_pulse(hb_pulse)
								);



 ll_rd_ctrl_v2 i_ll_rd_ctrl_v2(
								.clk (clk),
 								.reset_n (reset_n),
 								.rd_ctrl_ready (rd_ctrl_ready),
 								.rd_ctrl_traverse_ll (rd_ctrl_traverse_ll),
 								.rd_ctrl_single_rd_req (rd_ctrl_single_rd_req),
 								.rd_ctrl_traverse_ll_wrback_data (rd_ctrl_traverse_ll_wrback_data),
 								.rd_ctrl_send_wrback_reg_value (rd_ctrl_send_wrback_reg_value),
 								.rd_ctrl_ll_node_cnt (rd_ctrl_ll_node_cnt),
 								.rd_ctrl_ll_ptr (rd_ctrl_ll_ptr),
 								.rd_ctrl_nxtptr_N_rd_data (rd_ctrl_nxtptr_N_rd_data),
 								.rd_ctrl_nxtptr_Nminus1_rd_data (rd_ctrl_nxtptr_Nminus1_rd_data),
 								.rd_ctrl_nxtptr_Nminus2_rd_data (rd_ctrl_nxtptr_Nminus2_rd_data),
 								.rd_ctrl_upd_nxtptr_for_mid_node_del (rd_ctrl_upd_nxtptr_for_mid_node_del),
 								.rd_ctrl_traverse_ll_for_middle_node_del (rd_ctrl_traverse_ll_for_middle_node_del),
 								.rd_ctrl_nxtptr_value (rd_ctrl_nxtptr_value),
 								.rd_ctrl_nxtptr_vld (rd_ctrl_nxtptr_vld),
 								.rd_ctrl_data_value (rd_ctrl_data_value),
 								.rd_ctrl_data_vld (rd_ctrl_data_vld),
 								.rd_ctrl_wrback_ptr (rd_ctrl_wrback_ptr),
 								.rd_ctrl_wrback_ptr_vld (rd_ctrl_wrback_ptr_vld),
 								.ll_mngr_resp_taken (ll_mngr_resp_taken),
 								.nxtptr_mem_rd_vld (nxtptr_mem_rd_vld),
 								.nxtptr_mem_rd_addr (nxtptr_mem_rd_addr),
 								.nxtptr_mem_rd_data (nxtptr_mem_rd_data),
 								.nxtptr_mem_rd_data_out_vld (nxtptr_mem_rd_data_out_vld),
 								.data_mem_rd_vld (data_mem_rd_vld),
 								.data_mem_rd_addr (data_mem_rd_addr),
 								.data_mem_rd_data (data_mem_rd_data),
 								.data_mem_rd_data_out_vld (data_mem_rd_data_out_vld)
								);



 ll_wr_ctrl_v2 i_ll_wr_ctrl_v2(
								.clk (clk),
 								.reset_n (reset_n),
 								.wr_ctrl_ready (wr_ctrl_ready),
 								.wr_ctrl_req_taken (wr_ctrl_req_taken),
 								.wr_ctrl_nxtptr_for_hdptr_update_vld (wr_ctrl_nxtptr_for_hdptr_update_vld),
 								.wr_ctrl_nxtptr_for_hdptr_update (wr_ctrl_nxtptr_for_hdptr_update),
 								.wr_ctrl_nxtptr_for_hdptr_update_taken (wr_ctrl_nxtptr_for_hdptr_update_taken),
 								.wr_ctrl_direct_wr (wr_ctrl_direct_wr),
 								.wr_ctrl_wrdata_ndptr_vld (wr_ctrl_wrdata_ndptr_vld),
 								.wr_ctrl_wrdata_only (wr_ctrl_wrdata_only),
 								.wr_ctrl_nodeptr_for_write (wr_ctrl_nodeptr_for_write),
 								.wr_ctrl_nodeptr_vld (wr_ctrl_nodeptr_vld),
 								.wr_ctrl_data (wr_ctrl_data),
 								.wr_ctrl_data_vld (wr_ctrl_data_vld),
 								.wr_ctrl_wrback_data (wr_ctrl_wrback_data),
 								.wr_ctrl_wrback_data_vld (wr_ctrl_wrback_data_vld),
 								.wr_ctrl_wrback_ptr (wr_ctrl_wrback_ptr),
 								.wr_ctrl_wrback_ptr_vld (wr_ctrl_wrback_ptr_vld),
 								.wr_ctrl_ndptr_N (wr_ctrl_ndptr_N),
 								.wr_ctrl_ndptr_Nminus2 (wr_ctrl_ndptr_Nminus2),
 								.wr_ctrl_del_mid_ndptrs_vld (wr_ctrl_del_mid_ndptrs_vld),
 								.data_mem_wr_vld (data_mem_wr_vld),
 								.data_mem_wr_addr (data_mem_wr_addr),
 								.data_mem_wr_data (data_mem_wr_data),
 								.data_mem_wr_done (data_mem_wr_done),
 								.nxtptr_mem_wr_vld (nxtptr_mem_wr_vld),
 								.nxtptr_mem_wr_addr (nxtptr_mem_wr_addr),
 								.nxtptr_mem_wr_data (nxtptr_mem_wr_data),
 								.nxtptr_mem_wr_done (nxtptr_mem_wr_done),
 								.nxt_ptr_out (nxt_ptr_out),
 								.ll_ptrs_empty (ll_ptrs_empty),
 								.upd_nxt_ptr (upd_nxt_ptr)
								);



 ll_nxt_avail_memptr_gen i_ll_nxt_avail_memptr_gen(
								.clk (clk),
 								.reset_n (reset_n),
 								.hdptr_cfg_value (hdptr_cfg_value),
 								.hdptr_cfg_value_vld (hdptr_cfg_value_vld),
 								.upd_nxt_ptr (upd_nxt_ptr),
 								.return_nxt_ptr (return_nxt_ptr),
 								.pos_2_return_nxt_ptr (pos_2_return_nxt_ptr),
 								.make_ll_empty(make_ll_empty),
 								.ll_ptrs_empty (ll_ptrs_empty),
 								.nxt_ptr_out (nxt_ptr_out)
								);



 ll_resp_gen_unit i_ll_resp_gen_unit(
								.clk (clk),
 								.reset_n (reset_n),
 								.resp_num_nodes (resp_num_nodes),
 								.resp_gen_cmpltd (resp_gen_cmpltd),
 								.resp_ll_nodes (resp_ll_nodes),
 								.resp_ll_num (resp_ll_num),
 								.ll_mngr_resp_gen_req_taken (ll_mngr_resp_gen_req_taken),
 								.resp_tot_nodes (resp_tot_nodes),
   .resp_no_op(resp_no_op),
								.resp_done(resp_done),
   								.resp_gen_decode_err(resp_gen_decode_err)

								);



 ll_mem_model  #(.WR_DATA_WD (DATA_WIDTH),
 .DATA_DEPTH (DATAMEM_DEPTH),
 .WR_ADDR_WD ($clog2(DATAMEM_DEPTH)),
 .RD_ADDR_WD  ($clog2(DATAMEM_DEPTH)),
 .RD_DATA_WD  (DATA_WIDTH)) i_data_mem(
								.clk (clk),
 								.reset_n (reset_n),
 								.wr_vld (data_mem_wr_vld),
 								.wr_addr (data_mem_wr_addr),
 								.wr_data (data_mem_wr_data),
 								.wr_done (data_mem_wr_done),
 								.rd_vld (data_mem_rd_vld),
 								.rd_addr (data_mem_rd_addr),
 								.rd_data (data_mem_rd_data),
 								.rd_data_out_vld (data_mem_rd_data_out_vld)
								);


  ll_mem_model  #(.WR_DATA_WD (4),
 .DATA_DEPTH (DATAMEM_DEPTH),
 .WR_ADDR_WD ($clog2(DATAMEM_DEPTH)),
 .RD_ADDR_WD  ($clog2(DATAMEM_DEPTH)),
                  .RD_DATA_WD  (4)) i_nxtptr_mem(
								.clk (clk),
 								.reset_n (reset_n),
 								.wr_vld (nxtptr_mem_wr_vld),
 								.wr_addr (nxtptr_mem_wr_addr),
 								.wr_data (nxtptr_mem_wr_data),
 								.wr_done (nxtptr_mem_wr_done),
 								.rd_vld (nxtptr_mem_rd_vld),
 								.rd_addr (nxtptr_mem_rd_addr),
 								.rd_data (nxtptr_mem_rd_data),
 								.rd_data_out_vld (nxtptr_mem_rd_data_out_vld)
								);


  ll_mem_model  #(.WR_DATA_WD (4),
                  .DATA_DEPTH (4),
                  .WR_ADDR_WD ($clog2(4)),
                  .RD_ADDR_WD  ($clog2(4)),
                  .RD_DATA_WD  (4)) i_hdptr(
								.clk (clk),
 								.reset_n (reset_n),
 								.wr_vld (hdptr_wr_vld),
 								.wr_addr (hdptr_wr_addr),
 								.wr_data (hdptr_wr_data),
 								.wr_done (hdptr_wr_done),
 								.rd_vld (hdptr_rd_vld),
 								.rd_addr (hdptr_rd_addr),
 								.rd_data (hdptr_rd_data),
 								.rd_data_out_vld (hdptr_rd_data_out_vld)
								);


  ll_mem_model  #(.WR_DATA_WD (4),
                 .DATA_DEPTH (4),
                  .WR_ADDR_WD ($clog2(4)),
                  .RD_ADDR_WD  ($clog2(4)),
                  .RD_DATA_WD  (4)) i_node_cntr(
								.clk (clk),
 								.reset_n (reset_n),
 								.wr_vld (node_cntr_wr_vld),
 								.wr_addr (node_cntr_wr_addr),
 								.wr_data (node_cntr_wr_data),
 								.wr_done (node_cntr_wr_done),
 								.rd_vld (node_cntr_rd_vld),
 								.rd_addr (node_cntr_rd_addr),
 								.rd_data (node_cntr_rd_data),
 								.rd_data_out_vld (node_cntr_rd_data_out_vld)
								);


endmodule //ll_engine_top.sv

//---------Gen by Python Script: integration_script.py ---------------//
