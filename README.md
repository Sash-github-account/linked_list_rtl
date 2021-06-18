# linked_list_rtl
A SystemVerilog RTL implementation of linked list with a test bench

The input interface to the design is structured as a request-response mechanism:
Input signals for request:
req_vld : 1-bit request valid indication
req_type : 4-bit in current version. Below is a list of supported operation requests
req_pos : Parametrized signal to indicate the node position (node number) at which the operation is to be performed
req_data : Parametrized signal carrying data corresponding to the request

Input signal for response:
resp_taken: Asserted one cycle after the design drives a 1 on 'resp_vld'

Output signals for response from the design:
resp_vld : 1-bit response valid indication
resp_type : 4-bit in current version. Below is a list of supported responses
resp_data : Response data, parametrized (same as req_data)
resp_data_vld : Indicates data is valid

This implementation currently supports the following linked-list operations:
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

List of supported responses:
// RESPONSE types //
// 0. size of node response
// 1. Operation done for : insert, modify, make list empty and push requests
// 2. read response for : read data node request
// 3. delete response for : delete data at node request
// 4. read response for : pop from head
// 5. read response for : pop from tail
// 6. Request type error

Current version: tested error handling, insert and push operations with a simple. Rest of the operations yet to be tested with a more comprehensive test bench.
