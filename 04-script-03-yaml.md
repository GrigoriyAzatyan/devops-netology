# Задание 1. 
Мы выгрузили JSON, который получили через API запрос к нашему сервису:   

    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
    
Нужно найти и исправить все ошибки, которые допускает наш сервис.

**Решение:**   
Написал скрипт:  

    #! /usr/bin/env python3
    import json

    with open('file.json', 'r') as file:
       result = json.load(file)
       print(result.items())

Результат выполнения плачевный:  
`json.decoder.JSONDecodeError: Invalid control character at: line 9 column 26 (char 237)`  

Ошибка в строке 9, не хватает 3-х кавычек. Правильная строка:  

    "ip" : "71.78.22.43"

Исправляем, проверяем. Счастье наступило:  

    dict_items([('info', 'Sample JSON output from our service\t'), ('elements', [{'name': 'first', 'type': 'server', 'ip': 7175}, {'name': 'second', 'type': 'proxy', 'ip': '71.78.22.43'}])])



# Задание 2. 
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

**Решение:**  

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

        # Читаем JSON, подготавливаем данные
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

        # Читаем YAML, подготавливаем данные
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



# Дополнительное задание (со звездочкой*)
Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:

* Принимать на вход имя файла
* Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
* Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
* Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
* При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
* Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

Текст скрипта:

    #! /usr/bin/env python3

    import argparse
    import os
    import json
    import yaml
    import re

    parser = argparse.ArgumentParser()
    parser.add_argument('--file')
    arg = parser.parse_args()

    # Проверяем существование файла
    print()
    print('Проверяем путь к файлу...')
    print()
    check_file = os.access(arg.file, os.F_OK)
    if not check_file:
        print(f'Такого файла нет: {arg.file}! Идите лесом.')
        print()
        print('***************************************************')
        print('Работа скрипта завершена неудачей. И все из-за вас.')
        exit()
    else:
        print(f'Файл существует по указанному пути: {arg.file}')

    # Проверяем расширение файла
    if arg.file[-5:] == '.json':
        name_format = 'json'
    elif arg.file[-5:] == '.yaml' or arg.file[-4:] == '.yml':
        name_format = 'yaml'
    else:
        name_format = 'wrong'
        print('Не распознано расширение в имени файла!')
        print(f'Я принимаю только файлы с расширениями *.json, *.yaml и *.yml.')
        print()
        print('************************************')
        print('Работа скрипта завершена неудачей.')
        print('Живите теперь с этим. Хорошего дня.')
        exit()

    # Функция - парсер JSON
    # noinspection PyBroadException
    def json_parser(input_text):
        try:
            parse_result = json.loads(input_text)
        except Exception as ex:
            error_text = re.findall('(^[a-zA-Z\s]+)(?=\S\sline)', str(ex))
            error_line = re.findall('((?<=line )\d+)', str(ex))
            parse_result = 'Ошибка! Ваш кривой JSON содержит ошибку в строке (строках) ' + str(error_line[0:]) + '. Сообщение ошибки:\n' + str(error_text[0])
        finally:
            return parse_result


    # Функция - парсер YAML
    # noinspection PyBroadException
    def yaml_parser(input_text):
        try:
            parse_result = yaml.safe_load(file_text)
        except Exception as ex:
            error_line = re.findall('((?<=line )\d+)', str(ex))
            parse_result = 'Ошибка! Ваш кривой YAML содержит ошибку в строке (строках) ' + str(error_line[0:]) + '. Сообщение ошибки:\n' + str(ex)
        finally:
            return parse_result


    # Начинаем парсить файл
    file = open(arg.file, 'r')
    file_text = file.read()

    # Читаем как JSON
    json_parse_result = json_parser(file_text)
    if str(json_parse_result)[0:6] != 'Ошибка':
        file_format = 'json'
        output_ext = 'yml.output'
        if name_format == file_format:
            check_result = 'OK'
            print()
            print(f'Все ОК, файл в формате JSON. Получены объекты: {json_parse_result}')
        else:
            check_result = 'Warning'
            print()
            print(f'Расширение файла YAML, но сам файл в формате JSON. Получены объекты: {json_parse_result}')

    else:
        # Читаем как YAML
        yaml_parse_result = yaml_parser(file_text)
        if str(yaml_parse_result)[0:6] != 'Ошибка':
            file_format = 'yaml'
            output_ext = 'json.output'
            if name_format == file_format:
                check_result = 'OK'
                print()
                print(f'Все ОК, файл в формате YAML. Получены объекты: {yaml_parse_result}')
            else:
                check_result = 'Warning'
                print()
                print(f'Расширение файла JSON, но сам файл в формате YAML. Получены объекты: {yaml_parse_result}')
        else:
            check_result = 'Error'
            print('\n==========================\nВаш файл не удалось распарсить ни как JSON, ни как YAML. Вы понимаете, до чего докатились?!')
            print()
            print(f'Сообщение парсера JSON:\n==========================\n{json_parse_result}')
            print()
            print(f'Сообщение парсера YAML:\n==========================\n{yaml_parse_result}')
            file.close()
            exit()
    file.close()

    # Начинаем конвертировать!
    if file_format == 'json':
        output_result = yaml.dump(json_parse_result, sort_keys=False, indent=2)
    elif file_format == 'yaml':
        output_result = json.dumps(yaml_parse_result, indent=2)

    # Сохраняем в файл
    # Получаем имя без расширения
    name_regexp = re.findall('(.*)(?=\.[a-z]+$)', arg.file)
    name = name_regexp[0]
    output_name = name + '.' + output_ext

    with open(output_name, 'w+') as output_file:
        output_file.write(output_result)

    print()
    print(f'Сохранено в файл: {output_name}')
    print('Завершаем работу.')

