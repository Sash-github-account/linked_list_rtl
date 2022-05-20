# -*- coding: utf-8 -*-
"""
Created on Fri Dec 31 11:52:35 2021

@author: nsash
"""


from System_object import System_object

  

class ll_opcode_assembler(System_object):
    
    mem_addr_width = 15
    
    max_addr_space = 2**mem_addr_width
    
    mem_data_width = 8    
    
    
    trg_rom_file = "test.rom"
    
    vfile = None
    
    def __init__(self):
        self.src_assm_file = self.assm_file

    
    def read_rom_file(self, filename):
        content = self.read_file(filename)
        return content
    
    
    def write_to_rom_file(self, filename, str_line):        
        self.write_to_file(filename, str_line)
        
    
    def split_at_new_line(self, content):
        split_content = content.split("\n")
        split_content_clean = []
        for item in split_content:
            if(item != ""):
                split_content_clean.append(item)
        return split_content_clean
    
    
    def main_op_decoder(self, argument):
        op_num_bits = 4
        switcher = {
            "NO_OP"        : 0,
            "CONFIG_HDPTR" : 1,
            "READ_LL_REGS" : 2,
            "INSERT"       : 3,
            "DELETE"       : 4,
    		"UPDATE"       : 5,
    		"READ_NODE"    : 6,
    		"POP"          : 7,
    		"EMPTY_LL"     : 8,     
            }
        main_op =  switcher.get(argument, "nothing")
        mainop_bit_string = self.int_to_bin(main_op, op_num_bits)
        return mainop_bit_string
    
    
    def specifier_decoder(self, argument):
        op_num_bits = 4
        switcher = {
            "NONE"          :0,
            "AT_HEAD"       :1,
    		"ALL_LIST"      :2,
    		"SET_NUM_LL"    :3,
    		"NO_NODES_LL"   :4,
    		"AT_TAIL"       :5,
    		"SPEC_LIST"     :6,
    		"SET_HDPTR"     :7,
    		"AT_NODE_NUM"   :8,
    		"DEL_LL"        :9,
            }
        specifier = switcher.get(argument, "nothing")
        specifier_bit_string = self.int_to_bin(specifier, op_num_bits)
        return specifier_bit_string
    
    
    def ll_num_decode(self, ll_num):
        ll_num_int = int(ll_num)
        if(ll_num_int < self.max_lls):
            llnum_bit_string = self.int_to_bin(ll_num_int, self.ll_hdptr_add_width)
        else:
            llnum_bit_string = "0000" #FIXME       
        return llnum_bit_string
       
    
         
    def req_pos_decode(self, node_pos):
        node_pos_int = int(node_pos)
        if(node_pos_int < self.max_num_nodes):
            req_pos_bit_string = self.int_to_bin(node_pos_int, self.ll_mem_addr_width)
        else:
            req_pos_bit_string = "0000" #FIXME        
        return req_pos_bit_string
    
    
    def req_data_decode(self, data_value):
        data_value_int = int(data_value)
        if(data_value_int < self.max_data_value):
            req_data_bit_string = self.int_to_bin(data_value_int, self.ll_data_width)
        else:
            req_data_bit_string = "00000000" #FIXME        
        return req_data_bit_string
    
    
    def int_to_bin(self, num, op_pad_size):
        if(num !=  "nothing"):
            print(num)
            num_int = int(num)
            bin_string = str(bin(num_int))[2:]
            len_str = len(bin_string)
            if(op_pad_size > len_str):
                for n in range(op_pad_size - len_str):
                    bin_string =  "0" + bin_string
        else:
            bin_string = "00000000"
        return bin_string
    
    
    def count_num_bits(self, bit_string):
        count = 0
        for i in bit_string:
            count = count + 1
        return count
    
    
    def construct_instruction_pkt_for_trg_mem(self, padded_instruction, num_inst_words):
        instruction_pkt_for_trg_mem = ""
        for num_word in range(num_inst_words):
            for i in range(self.mem_data_width):
                bit_num = (num_word*self.mem_data_width) + i
                inv_bit_num = (((num_word+1)*self.mem_data_width)-1) - i
                    
                if(i == (self.mem_data_width-1)):
                    instruction_pkt_for_trg_mem = instruction_pkt_for_trg_mem + padded_instruction[bit_num] + ";\n"
                else:
                    instruction_pkt_for_trg_mem = instruction_pkt_for_trg_mem + padded_instruction[bit_num]
        return instruction_pkt_for_trg_mem
    
    
    def pad_zeros_inst_to_mem_data_bndry(self, bit_string):
        #print(bit_string)
        inst_bit_str_len = self.count_num_bits(bit_string)
        rem = (inst_bit_str_len % self.mem_data_width)
        num_pad_bits = self.mem_data_width - rem
        pad_bits = ""
        for i in range(num_pad_bits):
            pad_bits = pad_bits + "0"
        padded_instruction = bit_string + pad_bits
        #print(padded_instruction)
        num_inst_words = len(padded_instruction) / self.mem_data_width
        return padded_instruction, int(num_inst_words)
              
    
    def main_ll_inst_decoder(self, fields_array):
        mainop_bit_string = self.main_op_decoder(fields_array[0])
        specifier_bit_string = self.specifier_decoder(fields_array[1])
        llnum_bit_string = self.ll_num_decode(fields_array[2])
        req_pos_bit_string = self.req_pos_decode(fields_array[3])
        req_data_bit_string = self.req_data_decode(fields_array[4])
        instruction_bit_stream = mainop_bit_string + specifier_bit_string + llnum_bit_string + req_pos_bit_string + req_data_bit_string 
        return instruction_bit_stream
    
    
    def split_line_n_decode(self, line):
        op_fields = line.split(",")
        print(op_fields)
        decoded_inst_bits = self.main_ll_inst_decoder(op_fields)
        return decoded_inst_bits
        
               
    def run_assembler_for_rom_file(self):
        content = self.read_rom_file(self.src_assm_file)    
        split_content = self.split_at_new_line(content)
        combined_bit_code_str = ""
        for line in split_content:
            decoded_inst_bits = self.split_line_n_decode(line)      
            padded_instruction, num_inst_words = self.pad_zeros_inst_to_mem_data_bndry(decoded_inst_bits)
            instruction_pkt_for_trg_mem = self.construct_instruction_pkt_for_trg_mem(padded_instruction, num_inst_words)
            combined_bit_code_str = combined_bit_code_str + instruction_pkt_for_trg_mem
        self.write_to_rom_file(self.trg_rom_file, combined_bit_code_str)
        if(self.vfile != None):
            self.write_to_rom_file(self.vfile, "\n//-------- gen by ll_opcode_assembler.py ------------//\n")
            self.write_to_rom_file(self.vfile, combined_bit_code_str)
            self.write_to_rom_file(self.vfile, "\n//-------- gen by ll_opcode_assembler.py ------------//\n")
        return None

  
    