`ifndef _PARAMS_
`define _PARAMS_
parameter MAINOP_SIZE = 4;
parameter SPECIFIER_SIZE = 4;
parameter DATAMEM_DEPTH = 16;
parameter NXTPTR_MEM_DEPTH = DATAMEM_DEPTH;
parameter NXTPTR_ADDR_WIDTH = $clog2(NXTPTR_MEM_DEPTH);
parameter NODENUM_WIDTH = $clog2(NXTPTR_MEM_DEPTH);
parameter DATA_WIDTH = 8;
parameter DATAMEM_ADDR_WIDTH = $clog2(DATAMEM_DEPTH);
parameter HEADPTR_MEM_DEPTH = 4;
parameter MAX_NUM_LL = HEADPTR_MEM_DEPTH;
parameter NUM_LL_WIDTH = $clog2(HEADPTR_MEM_DEPTH);
parameter HEADPTR_ADDR_WIDTH = $clog2(HEADPTR_MEM_DEPTH);
parameter NXTPTR_MEM_WIDTH = $clog2(NXTPTR_MEM_DEPTH);
parameter DATAMEM_WIDTH = DATA_WIDTH;
parameter HEADPTR_WIDTH = $clog2(DATAMEM_DEPTH);
parameter PTR_WD = NXTPTR_MEM_WIDTH;
parameter INST_SIZE = 4 + 4 + HEADPTR_ADDR_WIDTH + NODENUM_WIDTH + DATA_WIDTH;
parameter ROM_DATA_WIDTH = 8;
parameter ROM_ADDR_WIDTH = 15;
parameter INST_SIZE_MOD_ROM_DATA_WIDTH = INST_SIZE%ROM_DATA_WIDTH;
parameter ADD_ONE = (INST_SIZE_MOD_ROM_DATA_WIDTH > 0) ? 1 : 0;
parameter NUM_OF_ROM_FIFO_RD_PER_INST = (INST_SIZE/ROM_DATA_WIDTH) + ADD_ONE;
parameter FIFO_DATA_WIDTH = 8;
parameter NUM_VLD_ROM_DATA = 42;
/*
parameter WR_DATA_WD = DATA_WIDTH;
parameter DATA_DEPTH = DATAMEM_DEPTH;
parameter WR_ADDR_WD = $clog2(DATAMEM_DEPTH);
parameter RD_ADDR_WD  = $clog2(DATAMEM_DEPTH);
parameter RD_DATA_WD  = DATA_WIDTH;*/

/* --------- Main operation and their specifiers ----------------- //

Config HeadPtrMem -> set num of linked lists, set each head pointer, delete linked list​

Read ll regs -> 0. total no. of nodes, 
					 1. no. Of node of a particular linked list,
					 2. no. of active lls, 
					 3. active ll reg
					 4. Max no. lls

Insert -> at head, at tail, at node number​

Delete (no Read) -> at head, at tail, at node number​

Update Node value -> @Head, @Tail, @nodeNum​

Read Node value -> @Head, @Tail, @nodeNum​

Pop (Read n Delete) value -> @Head, @Tail, @nodeNum​

Empty Linked list (Delete all nodes) -> all lists, a specific list 

//---------------------------------------------------------------*/

typedef enum logic[MAINOP_SIZE-1:0]{
			NO_OP, //0
			CONFIG_HDPTR, //1
			READ_LL_REGS, //2
			INSERT,//3
			DELETE,//4
			UPDATE,//5
			READ_NODE,//6
			POP,//7
			EMPTY_LL//8   
			} t_mainop_types;


typedef enum logic[SPECIFIER_SIZE-1:0]{
			NONE,//0
			AT_HEAD,//1
			ALL_LIST,//2
			SET_NUM_LL,//3
			NO_NODES_LL,//4
			AT_TAIL,//5
			SPEC_LIST,//6
			SET_HDPTR,//7
			AT_NODE_NUM,//8
			DEL_LL//9
			} t_specifier_types;

			
typedef enum logic[2:0]{
			CFG_RESP,
			OP_DONE,
			RD_NODE_DATA,
			ERROR
			} t_response_types;
			
	
typedef enum logic[2:0]{
			OTHER,
			INS_LL_EMPTY,
			DEL_LL_EMPTY,
			POP_LL_EMPTY,
			EMPTY_LL_EMPTY,
			ILL_REQ_TYPE,
			REQ_WHEN_BUSY
			} t_err_types;
		
/*		
parameter PTR_WD = 8;
parameter WR_DATA_WD = 8;
parameter DATA_DEPTH = 16;
parameter WR_ADDR_WD = 8;
parameter RD_ADDR_WD  = 8;
parameter RD_DATA_WD  = 8;


// REQUEST types //
// 0. return size of node
// 1. Insert node at specified position
// 2. modify node data at a specific node
// 3. read node data from  a specific node
// 4. delete a specific node
// 5. read data and delete node(pop) from head
// 6. read data and delete node(pop) from tail
// 7. push to head
// 8. push to tail
// 9. make list empty ie., delete all nodes
typedef enum logic[3:0]{
			RETURN_SIZE,
			INSERT,
			MODIFY,
			READ_NODE,
			DELETE_NODE,
			POP_HEAD_REQ,
			POP_TAIL_REQ,
			PUSH_HEAD,
			PUSH_TAIL,
			EMPTY_LL   
			} t_req_types;


// RESPONSE types //
// 0. size of node response
// 1. Operation done for : insert, modify, make list empty and push requests
// 2. read response for : read data node request
// 3. delete response for : delete data at node request
// 4. read response for : pop from head
// 5. read response for : pop from tail
// 6. Request type error
typedef enum logic[2:0]{
			SIZE,
			OP_DONE,
			RD_NODE_DATA,
			DEL_NODE_DATA,
			POP_HEAD,
			POP_TAIL,
			ERROR
			} t_resp_types;

// Possible error types //
// 0. Insert req when ll is empty, except at pos 0
// 1. Delete req when ll is empty
// 2. pop req when ll is empty
// 3. illegal req type
// 4. Empty ll when it is already empty
// 5. Recieved request when interface is busy
typedef enum logic[2:0]{
			OTHER,
			INS_LL_EMPTY,
			DEL_LL_EMPTY,
			POP_LL_EMPTY,
			EMPTY_LL_EMPTY,
			ILL_REQ_TYPE,
			REQ_WHEN_BUSY
			} t_error_types;
*/

`endif