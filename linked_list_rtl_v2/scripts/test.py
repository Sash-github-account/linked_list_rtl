# -*- coding: utf-8 -*-
"""
Created on Sun Jan  2 19:15:30 2022

@author: nsash
"""
from datetime import datetime

init_time = datetime.now()

import ll_system_api as ll_sys

ll = ll_sys.ll_api.create_ll()
ll.insert(5)
ll.insert(7)
ll.insert(1, 2)
ll.delete(pos = 1)
ll.delete()
ll1 = ll_sys.ll_api.create_ll()
ll1.insert(10)
ll1.insert(1)
ll1.delete(pos = 0)

del ll_sys.ll_api

fin_time = datetime.now()
print("Execution time : ", (fin_time-init_time))