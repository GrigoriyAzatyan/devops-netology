#! /usr/bin/env python3
import socket
import os
import ast
import json
import yaml

nodes = ["drive.google.com", "mail.google.com", "google.com"]

# Просмотрим содержимое логов JSON и YAML
logs = ['hosts.json', 'hosts.yml']
for file in logs:
    # Если файла нет, то создаем
    input_file = open(file, 'a+')
    input_file.close()
    input_file = open(file, 'r')

    # Читаем JSON
    if file == 'hosts.json':
        json_text = input_file.read()
        if len(json_text) != 0:
            log_from_json = json.loads(json_text)
            print(f'Найден предыдущий лог JSON: {log_from_json.items()}')
            input_file.close()
        else:
            # Если предыдущего лога нет, заполним словарь нулями
            log_from_json = {}
            n = 0
            while n <= (len(nodes) - 1):
                log_from_json[nodes[n]] = socket.gethostbyname(nodes[n])
                log_from_json[nodes[n]] = "0.0.0.0"
                n += 1
            print(f'Предыдущий лог JSON был пуст. Создали новый словарь: {log_from_json.items()}')

    # Читаем YAML
    elif file == 'hosts.yml':
        yaml_text = input_file.read()
        if len(yaml_text) != 0:
            log_from_yaml = yaml.safe_load(yaml_text)
            print(f'Найден предыдущий лог YAML: {log_from_yaml.items()}')
            input_file.close()
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
        print(
            f'ОК. Узел {nodes[n]}: прошлый IP {log_from_json[nodes[n]]}, новый IP {new_log[nodes[n]]}. Изменений нет.')
    else:
        print(f'ПРОБЛЕМА! Узел {nodes[n]} сменил IP с {log_from_json[nodes[n]]} на {new_log[nodes[n]]}! Это ужасно.')
    n += 1

with open('hosts.json', 'w') as hosts_json:
    json.dump(new_log, hosts_json, indent=2)

with open('hosts.yml', 'w') as hosts_yaml:
    yaml.dump(new_log, hosts_yaml, sort_keys=False, indent=2)
