#! /usr/bin/env python3
import socket
import os
import ast
nodes=["drive.google.com","mail.google.com","google.com"]

# Если файла нет, то создаем
file_log = open('hosts.log', 'a+')
file_log.close()

# Просмотрим содержимое лога
file_log = open('hosts.log', 'r')
log_text = file_log.read()
if len(log_text) != 0:
   log_dict = ast.literal_eval(log_text)
   file_log.close()
else:
   # Если предыдущего лога нет, заполним словарь нулями
   log_dict = {}
   n = 0
   while n <= (len(nodes) - 1):
      log_dict[nodes[n]] = socket.gethostbyname(nodes[n])
      log_dict[nodes[n]] = "0.0.0.0"
      n += 1

# Просмотрим новые данные, запишем в лог
n = 0
log = open('hosts.log','w')
new_log_dict = {}
while n <= (len(nodes) - 1):
   new_log_dict[nodes[n]] = socket.gethostbyname(nodes[n])
   if new_log_dict[nodes[n]] == log_dict[nodes[n]]:
      print(f'ОК. Узел {nodes[n]}: прошлый IP {log_dict[nodes[n]]}, новый IP {new_log_dict[nodes[n]]}. Изменений нет.')
   else:
      print(f'ПРОБЛЕМА! Узел {nodes[n]} сменил IP с {log_dict[nodes[n]]} на {new_log_dict[nodes[n]]}! Это ужасно.')
   n += 1
log.write(str(new_log_dict))
log.close()
