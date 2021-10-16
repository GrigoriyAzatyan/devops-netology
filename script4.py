#! /usr/bin/env python3
import socket
import os
import ast
import json
import yaml

nodes=["drive.google.com","mail.google.com","google.com"]

# Если файла JSON нет, то создаем
json_file = open('hosts.json', 'a+')
json_file.close()

# Если файла YAML нет, то создаем
yaml_file = open('hosts.yml', 'a+')
yaml_file.close()


# Просмотрим содержимое лога JSON
json_file = open('hosts.json', 'r')
json_text = json_file.read()
if len(json_text) != 0:
   log_from_json = json.loads(json_text)
   print(f'Найден предыдущий лог JSON: {log_from_json.items()}')
   json_file.close()
else:
   # Если предыдущего лога нет, заполним словарь нулями
   log_from_json = {}
   n = 0
   while n <= (len(nodes) - 1):
      log_from_json[nodes[n]] = socket.gethostbyname(nodes[n])
      log_from_json[nodes[n]] = "0.0.0.0"
      n += 1
   print(f'Предыдущий лог JSON был пуст. Создали новый словарь: {log_from_json.items()}')


# Просмотрим содержимое лога YAML
yaml_file = open('hosts.yml', 'r')
yaml_text = yaml_file.read()
if len(yaml_text) != 0:
   log_from_yaml = yaml.safe_load(yaml_text)
   print(f'Найден предыдущий лог YAML: {log_from_yaml.items()}')
   yaml_file.close()
else:
   # Если предыдущего лога нет, заполним словарь нулями
   log_from_yaml = {}
   n = 0
   while n <= (len(nodes) - 1):
      log_from_yaml[nodes[n]] = socket.gethostbyname(nodes[n])
      log_from_yaml[nodes[n]] = "0.0.0.0"
      n += 1
   print(f'Предыдущий лог YAML был пуст. Создали новый словарь: {log_from_yaml.items()}')


# Просмотрим новые данные, запишем в лог
n = 0
new_log = {}
while n <= (len(nodes) - 1):
   new_log[nodes[n]] = socket.gethostbyname(nodes[n])
   if new_log[nodes[n]] == log_from_json[nodes[n]]:
      print(f'ОК. Узел {nodes[n]}: прошлый IP {log_from_json[nodes[n]]}, новый IP {new_log[nodes[n]]}. Изменений нет.')
   else:
      print(f'ПРОБЛЕМА! Узел {nodes[n]} сменил IP с {log_from_json[nodes[n]]} на {new_log[nodes[n]]}! Это ужасно.')
   n += 1

with open('hosts.json', 'w') as hosts_json:
   json.dump(new_log, hosts_json, indent=2)

with open('hosts.yml', 'w') as hosts_yaml:
   yaml.dump(new_log, hosts_yaml, sort_keys=False, indent=2)
