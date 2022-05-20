# -*- coding: utf-8 -*-
"""
Created on Tue Jan 11 16:42:25 2022

@author: nsash
"""

from System_object import System_object
from linked_list_pkg import linked_list
from ll_opcode_assembler import ll_opcode_assembler
import sys

class ll_system_api:
    __ll_list = []
    
    __sys_obj = System_object()
    
    __assmbler = ll_opcode_assembler()
    
    def __init__(self):
        construct_noop_str = "NO_OP" + "," + "NONE" + "," + "0" + "," + "0" + ","  + "0" + "\n"
        construct_setnumll_str = "CONFIG_HDPTR," + "SET_NUM_LL," + str(self.__sys_obj.max_lls - 1) + "," + "0" + ","  + "0" + "\n"
        construct_inst_for_wr = construct_noop_str + construct_setnumll_str
        self.__sys_obj.write_to_file(self.__sys_obj.assm_file, construct_inst_for_wr)
        
    def create_ll(self):
        popd_hdptr = self.__sys_obj.pop_hdptr_stack()
        if(popd_hdptr[0] != None):
            ll = linked_list(popd_hdptr)
            self.__ll_list.append(ll)
            return ll
        else:
            print("No new ll resources available in the system. Max_num_ll allowed: " + str(self.__sys_obj.max_lls))
            sys.exit()
      
    def delete_ll(self, ll):
        ll.empty_ll()
        self.__sys_obj.push_hdptr_stack(ll.__ll_id, ll.__hdptr)
        
    def run_assm(self):
        self.__assmbler.run_assembler_for_rom_file()
        
    def __del__(self):
        self.run_assm()
        
ll_api = ll_system_api()