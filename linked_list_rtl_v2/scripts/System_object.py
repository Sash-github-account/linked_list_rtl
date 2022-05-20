# -*- coding: utf-8 -*-
"""
Created on Fri Dec 31 11:52:35 2021

@author: nsash
"""

import random

class System_object:
    
    assm_file = "test1.assm"
    
    ll_data_width = 8
    
    ll_mem_addr_width = 4
    
    ll_hdptr_add_width = 2
    
    max_lls = 2**ll_hdptr_add_width
    
    max_num_nodes = 2**ll_mem_addr_width
    
    max_data_value = 2**ll_data_width
    
    hdptr_stack = []
    
    hdptr_stack_indx = 0
    
    num_active_lls = 0
    
    def __init__(self):
        self.fill_hdptr_stack()
    
    def read_file(self, filename):
        fileptr = open(filename,"r")
        content = fileptr.read();  
        fileptr.close()
        return content
    
    def fill_hdptr_stack(self):
        hdptr_ids = [*range(self.max_lls)]
        hdptr_list = []
        for hdptrid in hdptr_ids:
            hdptr = random.randrange(0, self.max_num_nodes, 1)
            if hdptr not in hdptr_list: hdptr_list.append(hdptr)
            if hdptr not in [None]: hdptr_list.append(hdptr)
            self.hdptr_stack.append([hdptrid, hdptr])
            self.hdptr_stack_indx = self.hdptr_stack_indx + 1
        print(self.hdptr_stack)
           
    def write_to_file(self, fileName, str_line):        
        #---------- open file to write -------------#
        wrFilePtr = open(fileName, "a")
        wrFilePtr.write(str_line)
        wrFilePtr.close()
        #-------------------------------------------#
          
    def split_at_new_line(self, content):
        split_content = content.split("\n")
        return split_content
      
    def pop_hdptr_stack(self):
        ret_obj = self.hdptr_stack.pop(self.hdptr_stack_indx - 1)
        print(ret_obj)
        self.hdptr_stack_indx = self.hdptr_stack_indx - 1
        self.num_active_lls = self.num_active_lls + 1
        return ret_obj
        
    def push_hdptr_stack(self, hd_id, ptr):
        self.hdptr_stack.append([hd_id, ptr]) 
        self.hdptr_stack_indx = self.hdptr_stack_indx + 1
        self.num_active_lls = self.num_active_lls + 1

        
        
        
        
        
  
    