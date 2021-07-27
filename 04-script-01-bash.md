## 1. Есть скрипт:

    a=1
    b=2
    c=a+b
    d=$a+$b
    e=$(($a+$b)) 
Какие значения переменным c,d,e будут присвоены? Почему?

**Ответ:**  
- Значением c будет строка "**a+b**", т.к. переменные не обозначены символом $, и выражение не помещено в какие-либо скобки;   
- Значением d будет строка "**1+2**", т.к. переменные обозначены, но выражение не помещено в какие-либо скобки;   
- Значением e будет **число 3**, т.к. переменные обозначены символом $, и все выражение помещено в конструкцию $(( )).     

## 2. На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным. В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на жёстком диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить.

**Ответ**  
* Перезаписываем лог:

        while ((1==1))
        do
        curl https://localhost:4757
        if (($? != 0))
        then
        date > curl.log
        break
        fi
        done

- Запись в лог заменена перезаписью.
- Добавлена пропущенная скобка в строке 1;  
- Добавлена команда break перед fi.   


## 3. Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242 по 80 порту и записывает результат в файл log. Проверять доступность необходимо пять раз для каждого узла.  

    #! /usr/bin/env bash

    # Объявляем узлы
    ip_array=("192.168.0.1" "173.194.222.113" "87.250.250.242") 

    # Проверим каждый узел
    node=0
    count_nodes=$((${#ip_array[@]}-1))
    while [ $node -le $count_nodes ]
    do
        echo Проверяем доступность узла ${ip_array[$node]}

    #   5 попыток для каждого узла
        for counter in {1..5}
            do
               echo Попытка $counter из 5...
               curl -I -m 1 -sS http://${ip_array[$node]} &>> log
            done
    let "node+=1"
    done


## 4. Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается. 

**Новый вариант:**  

    #! /usr/bin/env bash

    # Объявляем узлы
    ip_array=("192.168.0.1" "173.194.222.113" "87.250.250.242")

    # Проверим каждый узел
    node=0
    declare -i count_nodes
    count_nodes=$((${#ip_array[@]}-1))
    while [ $node -le $count_nodes ]
    do
        echo Проверяем доступность узла ${ip_array[$node]}

    #   5 попыток для каждого узла
        for counter in {1..5}
            do
               echo Попытка $counter из 5...
               curl -I -m 1 -sS http://${ip_array[$node]} &>> log
            done

    # Прерываем скрипт, если обнаружили ошибку
        if (($? != 0))
        then
           echo Подох веб-сервис на IP ${ip_array[$node]}! >> error
           break
        fi

        let "node+=1"
    done


**Старый вариант:**  

    #! /usr/bin/env bash

    ip_array=("192.168.0.1" "173.194.222.113" "87.250.250.242")
    for i in {1..5}
    do
      echo Попытка $i из 5...

    ### Сканируем первый IP ###
       ip=${ip_array[0]}
       echo Сканируем IP $ip...
       curl -I -m 1 -sS http://$ip &>> log
       if (($? != 0))
       then
         echo Подох веб-сервис на IP $ip! >> error
         break
       fi

    ### Сканируем второй IP ###
       ip=${ip_array[1]}
       echo Сканируем IP $ip...
       curl -I -m 1 -sS http://$ip &>> log
       if (($? != 0))
       then
         echo Подох веб-сервис на IP $ip! >> error
         break
       fi

    ### Сканируем третий IP ###
       ip=${ip_array[2]}
       echo Сканируем IP $ip...
       curl -I -m 1 -sS http://$ip &>> log
       if (($? != 0))
       then
         echo Подох веб-сервис на IP $ip! >> error
         break
       fi
    done

## Дополнительное задание (со звездочкой*)
Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и количество символов в сообщении не превышает 30. Пример сообщения: [04-script-01-bash] сломал хук.  

**Ответ:**  

        #! /usr/bin/env bash

        # Проверяем на соответствие шаблону
        egrep '^\[[0-9]{2}-\w+-[0-9]{2}-\w+\]' .git/COMMIT_EDITMSG
        if (($? !=0 ))
        then
           echo >&2 Сообщение коммита не соответствует корпоративной этике. ВЫ УВОЛЕНЫ.
           exit 1
        fi

        # Проверяем длину, должна быть не больше 30
        MSG=`cat $1`
        if [ ${#MSG} -le 30 ]
        then
           echo Ваше сообщение - $MSG
           echo Сообщение коммита корректной длины: ${#MSG}. Но зарплату мы вам не повысим. СПАСИБО ЗА ВАШУ ЛОЯЛЬНОСТЬ!
           exit 0
        else
           echo Длина вашего сообщения ${#MSG}, а максимально допустимая - 30.
           echo >&2 РЕЗУЛЬТАТ: cообщение коммита слишком длинное, чтобы его читать. ВЫ УВОЛЕНЫ.
           exit 1
        fi

