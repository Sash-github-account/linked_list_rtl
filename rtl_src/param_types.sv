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

typedef enum logic[2:0]{
			OTHER,
			INS_LL_EMPTY,
			DEL_LL_EMPTY,
			POP_LL_EMPTY,
			EMPTY_LL_EMPTY,
			ILL_REQ_TYPE
			} t_error_types;

