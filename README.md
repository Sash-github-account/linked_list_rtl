# Linked List in RTL
A SystemVerilog RTL implementation of linked list with a test bench.

**Micro-architecture:**

Below is a schematic chart of the various hierarchies (and corresponding sv files) in the design.

i_ll ( linked_list_top.sv ) 
          |
          --> i_hd_ptr ( hd_ptr.sv ) : Logic that handles head pointer updation and maintenace
          --> i_nxt_ptr_req_servr ( nxt_ptr_req_servr.sv ): Logic that maintains free pointers, indicating the address of next available data memory slot.
          |                     |
          |                     --> i_dpfo ( detect_pos_first_one.v ): detects the address of next available memory slot taking the free pointer vector as input.
          |
          --> i_linked_list_data_mem ( linked_list_data_mem.sv ): Dual port reg-file based node data storage
          --> i_ll_nxt_ptr_logic ( ll_nxt_ptr_logic.sv ): Maintains list of next pointers as a reg-file corresponding to node position and handles updation of 
          |                                                next pointer as per request type of current operation.
          --> i_ll_rd_ctrl ( ll_rd_ctrl.sv ): Handles read/pop requests, interacting with linked_list_data_mem and ll_nxt_ptr_logic.
          --> i_ll_wr_ctrl ( ll_wr_ctrl.sv ): Handles write/insert/push requests, interacting with linked_list_data_mem and ll_nxt_ptr_logic.
          --> i_ll_req_resp_intf ( ll_req_resp_intf.sv ): Primary external interface, handles decoding of request types, controlling the execution of the request and generating appropriate responses.

The input interface to the design is structured as a request-response mechanism:

**Input signals for request:**

req_vld : 1-bit request valid indication

req_type : 4-bit in current version. Below is a list of supported operation requests

req_pos : Parametrized signal to indicate the node position (node number) at which the operation is to be performed

req_data : Parametrized signal carrying data corresponding to the request


**Input signal for response:**

resp_taken: Asserted one cycle after the design drives a 1 on 'resp_vld'


**Output signals for response from the design:**

resp_vld : 1-bit response valid indication

resp_type : 4-bit in current version. Below is a list of supported responses

resp_data : Response data, parametrized (same as req_data)

resp_data_vld : Indicates data is valid


**This implementation currently supports the following linked-list operations:**

// REQUEST types //

// 0. return size of node

// 1. Insert node at specified position

// 2. modify node data at a specific node

// 3. read node data from  a specific node

// 4. delete a specific node

// 5. read data and delete node(pop) from head

// 6. read data and delete node(pop) from tail

// 7. push to tail

// 8. push to head

// 9. make list empty ie., delete all nodes


**List of supported responses:**

// RESPONSE types //

// 0. size of node response

// 1. Operation done for : insert, modify, make list empty and push requests

// 2. read response for : read data node request

// 3. delete response for : delete data at node request

// 4. read response for : pop from head

// 5. read response for : pop from tail

// 6. Request type error


**List of error types that will be reported as a response:**

// Possible error types //

// 0. Insert req when ll is empty, except at pos 0

// 1. Delete req when ll is empty

// 2. pop req when ll is empty

// 3. illegal req type

// 4. Empty ll when it is already empty


**Tested features:**

Tested error handling, insert and push operations with a simple test bench.

**W.I.P:**

Rest of the operations yet to be tested with a more comprehensive test bench.
