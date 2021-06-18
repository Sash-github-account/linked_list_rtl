module ll_wr_ctrl(
		  input logic 			clk,
		  input logic 			reset_n,
		  // write req from ll ctrl //
		  input logic [WR_DATA_WD-1:0] 	data_to_wr,
		  input logic 			data_to_wr_req,
		  input logic 			insert_data,
		  // get next available data //
		  input logic [PTR_WD-1:0] 	nxt_ptr_from_servr,
		  input logic 			nxt_ptr_wr_done,
		  // from data mem //
		  input logic 			data_mem_wr_cmpl,
		  //to ll_nxt_ptr_logic //
		  output logic 			upd_nxt_ptr,
		  output logic 			upd_nxt_ptr_insert, 
		  output logic [PTR_WD-1:0] 	cur_nxt_ptr,
		  // to ll data mem //
		  output logic [WR_DATA_WD-1:0] wr_data2ll_data_mem,
		  output logic [WR_ADDR_WD-1:0] wr_data2ll_addr,
		  output logic 			wr_data2ll_vld,
		  // to ll ctrl //
		  output logic 			wr_ctrl_fsm_ready		  
		  );


   // Declarations //
   typedef enum logic[3:0]{
			   IDLE,
			   UPD_NXTPTR_DATAMEM,
			   WAIT_MEM_CMPL
			   } t_wr_ctrl_fsm_st;
   
   t_wr_ctrl_fsm_st   wr_ctrl_nxt_st;   
   t_wr_ctrl_fsm_st wr_ctrl_cur_st;
   logic [PTR_WD-1:0] 				head_ptr;
   logic [WR_DATA_WD-1:0] 			data_to_wr_int; 
   logic 					fsm_active;
   //----------//

   

   // Assigns //   
   assign wr_ctrl_fsm_ready = ~fsm_active;
   //----------//

   

   // Hold data internally //
   always_ff@(posedge clk) begin
      
      if(reset_n) begin
	 data_to_wr_int <= 0;    
      end
      else begin
	 if(data_to_wr_req & !fsm_active) data_to_wr_int <= data_to_wr;
	 else data_to_wr_int <= data_to_wr_int;	 
      end
      
   end 
   //----------//
   


   // Write controller FSM outputs //
   always_ff@(posedge clk) begin
      if(reset_n) begin
	 upd_nxt_ptr <= 0;
	 cur_nxt_ptr <= 0;
	 wr_data2ll_data_mem <= 0;
	 wr_data2ll_addr <= 0;
	 wr_data2ll_vld <= 0;
	 head_ptr  <= 0;	
	 wr_ctrl_cur_st <= IDLE;
	 fsm_active <= 0;
	 
      end
      else begin
	 
         wr_ctrl_cur_st <= wr_ctrl_nxt_st;
	 
	 case(wr_ctrl_nxt_st)
	   IDLE: begin
	      upd_nxt_ptr <= 0;
	      cur_nxt_ptr <= 0;
	      fsm_active <= 0;
	      wr_data2ll_data_mem <= 0;
	      wr_data2ll_addr <= 0;
	      wr_data2ll_vld <= 0;
	   end

	   UPD_NXTPTR_DATAMEM: begin
	      upd_nxt_ptr <= 1;
	      cur_nxt_ptr <= nxt_ptr_from_servr;
	      fsm_active <= 1;
	      wr_data2ll_data_mem <= data_to_wr_int;
	      wr_data2ll_addr <= nxt_ptr_from_servr;
	      wr_data2ll_vld <= 1;
	   end

	   WAIT_MEM_CMPL: begin
	      upd_nxt_ptr <= 0;
	      fsm_active <= 1;
	      cur_nxt_ptr <= 0;
//	      cur_nxt_ptr_vld <= 0;
	      wr_data2ll_data_mem <= 0;
	      wr_data2ll_addr <= 0;
	      wr_data2ll_vld <= 0;
	   end

	   default: begin
	      upd_nxt_ptr <= 0;
	      fsm_active <= 0;
	      cur_nxt_ptr <= 0;
//	      cur_nxt_ptr_vld <= 0;
	      wr_data2ll_data_mem <= 0;
	      wr_data2ll_addr <= 0;
	      wr_data2ll_vld <= 0;
	   end
	 endcase // case (wr_ctrl_nxt_st)	 
	 
      end
      
   end // always_ff@ (posedge clk)
   //---------//

   

   // Write control FSM transistions //
   always_comb begin
      wr_ctrl_nxt_st = wr_ctrl_cur_st;
      
      case(wr_ctrl_cur_st)
	
	IDLE: begin
	   if(!fsm_active & data_to_wr_req) wr_ctrl_nxt_st = UPD_NXTPTR_DATAMEM;
	   else  wr_ctrl_nxt_st = IDLE;
	   
	end

	UPD_NXTPTR_DATAMEM: begin
	   wr_ctrl_nxt_st = WAIT_MEM_CMPL;
	   
	end

	WAIT_MEM_CMPL: begin
	   if(nxt_ptr_wr_done & data_mem_wr_cmpl) wr_ctrl_nxt_st = IDLE;
	   else wr_ctrl_nxt_st = WAIT_MEM_CMPL;
	   
	end

	default: begin
	   wr_ctrl_nxt_st = IDLE;
	end
      endcase // case (wr_ctrl_cur_st)
            
   end   
   //----------//
   
endmodule // ll_wr_ctrl
