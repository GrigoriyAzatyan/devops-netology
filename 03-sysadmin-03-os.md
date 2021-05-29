## 1. Какой системный вызов делает команда cd? В прошлом ДЗ мы выяснили, что cd не является самостоятельной программой, это shell builtin, поэтому запустить strace непосредственно на cd не получится. Тем не менее, вы можете запустить strace на /bin/bash -c 'cd /tmp'. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к cd.
  
Ответ:  
`strace -o output.log /bin/bash -c 'cd /tmp' && egrep *tmp output.log`

## 2. Попробуйте использовать команду file на объекты разных типов на файловой системе. Например:  
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
Используя strace, выясните, где находится база данных file, на основании которой она делает свои догадки.

Ответ:   
man magic указывает на такую информацию:  

* The database of these “magic patterns” is usually located in a binary file in **/usr/share/misc/magic.mgc** or a directory of source text magic pattern fragment files in **/usr/share/misc/magic**.  The database  specifies what patterns are to be tested for, what message or MIME type to print if a particular pattern is found, and additional information to extract from the file. 

Попробуем выполнить file /bin/bash, отфильтровав результат:   
`strace -o output.log /bin/bash -c 'file /bin/bash' && cat output.log | grep magic`

    openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libmagic.so.1", O_RDONLY|O_CLOEXEC) = 3   
    stat("/home/grigorii_azatyan/.magic.mgc", 0x7ffe5073a820) = -1 ENOENT (Нет такого файла или каталога)   
    stat("/home/grigorii_azatyan/.magic", 0x7ffe5073a820) = -1 ENOENT (Нет такого файла или каталога)   
    openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (Нет такого файла или каталога)   
    stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0   
    openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3   
    openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3   

Результат:  
 - Видим обращение к библиотеке **/lib/x86_64-linux-gnu/libmagic.so.1**;
 - Файл /etc/magic, по-видимому, служит для каких-то временных данных;
 - Видим обращение к файлу **/usr/share/misc/magic.mgc**
  

## 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков, предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Смоделируем нехорошую ситуацию:  
`ping 8.8.8.8 > ~/output.log   `    
`sudo rm -rf output.log  `  
`sudo lsof | grep output.log  `  

    ping      7770      grigorii_azatyan    1w      REG      8,5    73432    1453088 /home/grigorii_azatyan/output.log (deleted)  

Видим: PID 7770, файловый дескриптор 1.  
Значит, можно найти этот файловый дескриптор в /proc/7770/fd/1 и записать туда пустоту:        
`sudo su`   
`> /proc/7770/fd/1`    

**Результат:**    
`cat /proc/7770/fd/1  `  

    64 bytes from 8.8.8.8: icmp_seq=1108 ttl=109 time=44.9 ms   
    64 bytes from 8.8.8.8: icmp_seq=1109 ttl=109 time=47.9 ms   
    64 bytes from 8.8.8.8: icmp_seq=1110 ttl=109 time=44.9 ms    
    64 bytes from 8.8.8.8: icmp_seq=1111 ttl=109 time=45.3 ms   
    64 bytes from 8.8.8.8: icmp_seq=1112 ttl=109 time=44.6 ms   
    64 bytes from 8.8.8.8: icmp_seq=1113 ttl=109 time=46.4 ms   
    64 bytes from 8.8.8.8: icmp_seq=1114 ttl=109 time=44.4 ms   
  
Файл обнулился на момент выполнения команды, что и требовалось в задании. Однако, команда ping продолжает сливать помои на жесткий диск. Впрочем, это уже другая история.


## 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
Зомби не занимают памяти (как процессы-сироты), но блокируют записи в таблице процессов, размер которой ограничен для каждого пользователя и системы в целом.
https://ru.wikipedia.org/wiki/%D0%9F%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81-%D0%B7%D0%BE%D0%BC%D0%B1%D0%B8#%D0%92%D0%BE%D0%B7%D0%BD%D0%B8%D0%BA%D0%BD%D0%BE%D0%B2%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B7%D0%BE%D0%BC%D0%B1%D0%B8

## 5. В iovisor BCC есть утилита opensnoop:
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04. Дополнительные сведения по установке.

**Ответ:**   
/usr/sbin/opensnoop-bpfcc  
      `PID    COMM               FD ERR PATH`  
      `1856   vminfo              4   0 /var/run/utmp`    
      `626    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services`  
      `626    dbus-daemon        28   0 /usr/share/dbus-1/system-services`  
      `626    dbus-daemon        -1   2 /lib/dbus-1/system-services`  
      `626    dbus-daemon        28   0 /var/lib/snapd/dbus-1/system-services/`  
      `2496   gnome-shell        27   0 /proc/self/stat`  


## 6. Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.

**Ответ:**  
    `uname({sysname="Linux", nodename="ubuntu-20", ...}) = 0`  
    `fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0x1), ...}) = 0`  
    `uname({sysname="Linux", nodename="ubuntu-20", ...}) = 0`  
    `uname({sysname="Linux", nodename="ubuntu-20", ...}) = 0`  
    `write(1, "Linux ubuntu-20 5.8.0-53-generic"..., 115) = 115 ` 

**man 2 uname**
* Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.


## 7. Чем отличается последовательность команд через ; и через && в bash? Например:
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
Есть ли смысл использовать в bash &&, если применить set -e?

**Ответы:**
- С использованем ; обе команды отработают в любом случае.    
- С использованием && вторая команда отработает только при успешном результате первой.  
- С применением set -e скрипт/оболочка завершит работу при ненулевом коде возврата команды. В принципе, конструкция с && работать будет, но она необязательна, т.к. при другом условии оболочка просто завершится. 

## 8. Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?

**Ответ:**
set -e прекращает выполнение скрипта, если команда завершилась ошибкой.  
set -u - прекращает выполнение скрипта, если встретилась несуществующая переменная.  
set -x - выводит выполняемые команды в stdout перед выполненинем.  
set -o pipefail - прекращает выполнение скрипта, даже если одна из частей пайпа завершилась ошибкой. В этом случае bash-скрипт завершит выполнение, если mycommand вернёт ошибку, не смотря на true в конце пайплайна: mycommand | true.  
Красиво и безопасно.  

## 9. Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (/PROCESS STATE CODES) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

**Ответ:**   
`ps -ao stat,command`
`STAT COMMAND`  
`S+   dbus-run-session -- gnome-session --autostart /usr/share/gdm/greeter/autostart`  
`Sl+  /usr/libexec/gnome-session-binary --systemd --autostart /usr/share/gdm/greeter/autostart`  
`Sl   /usr/libexec/ibus-engine-simple`  
`...`  
`R+   ps -ao stat,command ` 

Наиболее частый статус:   
**S    interruptible sleep (waiting for an event to complete)**   

Дополнительные буквы:     
* <    high-priority (not nice to other users)  
* N    low-priority (nice to other users)  
* L    has pages locked into memory (for real-time and custom IO)  
* s    is a session leader  
* l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)  
* \+    is in the foreground process group  
