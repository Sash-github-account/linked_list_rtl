# -*- coding: utf-8 -*-
"""
Created on Sat Jan  1 01:07:22 2022

@author: nsash
"""
  
from System_object import System_object

class linked_list(System_object):

   

    __ll_id = 0
    
    __hdptr = 0
    
    node_count = 0
    
    
    def __init__(self, popd_hdptr):
        self.__assm_file =  self.assm_file
        self.__ll_id = popd_hdptr[0]
        self.__hdptr = popd_hdptr[1]
        self.__wr_to_assm_file("NO_OP", "NONE", self.__hdptr, 0)
        self.__wr_to_assm_file("CONFIG_HDPTR", "SET_HDPTR", self.__hdptr, 0)
        print("done")


            
    def __wr_to_assm_file(self, main_op, spec, pos, data):  
        construct_inst_str = main_op + "," + spec + "," + str(self.__ll_id) + "," + str(pos) + ","  + str(data) + "\n"
        self.write_to_file(self.__assm_file, construct_inst_str)
                 
    
    def insert(self, data, pos = None):
        if(pos == None):
            pos = self.node_count
            
        if(pos == 0):
            self.__wr_to_assm_file("INSERT", "AT_HEAD", pos, data)
        elif(pos == self.node_count):
            self.__wr_to_assm_file("INSERT", "AT_TAIL", pos, data)
        elif(pos > self.node_count):
            self.__wr_to_assm_file("NO_OP", "AT_TAIL", pos, data)            
        else:
            self.__wr_to_assm_file("INSERT", "AT_NODE_NUM", pos, data)
            
        self.node_count = self.node_count + 1


    def delete(self, data = 0,  pos = None):
        if(pos == None):
            pos = self.node_count
            
        if(self.node_count > 0):
            if(pos == 0):
                self.__wr_to_assm_file("DELETE", "AT_HEAD", pos, data)
            elif(pos == self.node_count):
                self.__wr_to_assm_file("DELETE", "AT_TAIL", pos, data)
            elif(pos > self.node_count):
                self.__wr_to_assm_file("NO_OP", "AT_TAIL", pos, data)            
            else:
                self.__wr_to_assm_file("DELETE", "AT_NODE_NUM", pos, data)
                
            self.node_count = self.node_count - 1
        else:
            self.__wr_to_assm_file("NO_OP", "NONE", pos, data)



    def update_node_value(self, data, pos = None):
        if(pos == None):
            pos = self.node_count
            
        if(pos == 0):
            self.__wr_to_assm_file("UPDATE", "AT_HEAD", pos, data)
        elif(pos == self.node_count):
            self.__wr_to_assm_file("UPDATE", "AT_TAIL", pos, data)
        elif(pos > self.node_count):
            self.__wr_to_assm_file("NO_OP", "AT_TAIL", pos, data)            
        else:
            self.__wr_to_assm_file("UPDATE", "AT_NODE_NUM", pos, data)  
            
            
    def read_node_value(self, data = 0, pos = None):
          if(pos == None):
              pos = self.node_count
              
          if(pos == 0):
              self.__wr_to_assm_file("READ_NODE", "AT_HEAD", pos, data)
          elif(pos == self.node_count):
              self.__wr_to_assm_file("READ_NODE", "AT_TAIL", pos, data)
          elif(pos > self.node_count):
              self.__wr_to_assm_file("NO_OP", "AT_TAIL", pos, data)            
          else:
              self.__wr_to_assm_file("READ_NODE", "AT_NODE_NUM", pos, data)                  
            

    def pop(self, data = 0,  pos = None):
        if(pos == None):
            pos = self.node_count
            
        if(self.node_count > 0):
            if(pos == 0):
                self.__wr_to_assm_file("POP", "AT_HEAD", pos, data)
            elif(pos == self.node_count):
                self.__wr_to_assm_file("POP", "AT_TAIL", pos, data)
            elif(pos > self.node_count):
                self.__wr_to_assm_file("NO_OP", "AT_TAIL", pos, data)            
            else:
                self.__wr_to_assm_file("POP", "AT_NODE_NUM", pos, data)
                
            self.node_count = self.node_count - 1
        else:
            self.__wr_to_assm_file("POP", "NONE", pos, data)
 
            
 
    def empty_ll(self):
        self.__wr_to_assm_file("EMPTY_LL,", "SPEC_LIST", 0, 0)
        self.__del__()




