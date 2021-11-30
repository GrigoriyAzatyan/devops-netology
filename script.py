#! /usr/bin/env python3
import argparse
import os

# Принимаем путь крепозиторию в параметр --path
parser = argparse.ArgumentParser()
parser.add_argument('--path', type=str, default='~/git/devops_netology', help='Укажите путь к репозиторию')
arg = parser.parse_args()
print()
print('*******************************************************************************')
print(f'*** Проверяем папку {arg.path} на наличие измененных файлов ***')
print('*******************************************************************************')
print()

# Проверяем наличие изменененных файлов
bash_command = 'cd ' + arg.path + ' && git status --porcelain'
result_os = os.popen(bash_command).read()
one_string = result_os.replace('\n', ' ')
if one_string.find(' M ') == -1 and one_string.find('MM ') == -1 and one_string.find('AM ') == -1:
    print('Измененных файлов в указанном каталоге нет.')
    print()
    exit()
else:
    print('Найдены следующие измененные файлы:')
    print()
    # Перечисляем изменененные файлы
    statuses=[' M ', 'MM ', 'AM ']
    for result in result_os.split('\n'):
        n = 0
        while n <= (len(statuses) - 1):
            if result.find(statuses[n]) != -1:
                prepare_result = arg.path + '/' + result.replace(statuses[n], '')
                print(prepare_result)
            n += 1
    print()

