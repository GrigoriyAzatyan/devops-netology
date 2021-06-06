## 1. На лекции мы познакомились с node_exporter. В демонстрации его исполняемый файл запускался в background. 
Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. И
спользуя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter:
* поместите его в автозагрузку,
* предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на systemctl cat cron),
* удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

**Ответ:**  
cat /etc/systemd/system/node_exporter.service  

      [Unit]  
      Description=Node Exporter  
      After=network-online.target  

      [Service]  
      User=node_exporter  
      Group=node_exporter  
      Type=simple  
      EnvironmentFile=-/etc/default/node_exporter  
      ExecStart=/usr/local/bin/node_exporter $EXTRA_OPTS  

      [Install]  
      WantedBy=multi-user.target  

**# systemctl status node_exporter**  
● node_exporter.service - Node Exporter  
     `Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)`    
     `Active: active (running) since Sun 2021-06-06 11:35:48 UTC; 2min 10s ago`    
     `Main PID: 7153 (node_exporter)`    
       `Tasks: 6 (limit: 1122)`   
      `Memory: 10.8M`    
      `CGroup: /system.slice/node_exporter.service`    
              `└─7153 /usr/local/bin/node_exporter` 


## 2. Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

**Ответ:**  
--collector.disable-defaults --collector.meminfo --collector.loadavg --collector.filesystem


## 3. Установите в свою виртуальную машину Netdata. Воспользуйтесь готовыми пакетами для установки (sudo apt install -y netdata). После успешной установки:
* в конфигурационном файле /etc/netdata/netdata.conf в секции [web] замените значение с localhost на bind to = 0.0.0.0,
* добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте vagrant reload:
config.vm.network "forwarded_port", guest: 19999, host: 19999
После успешной перезагрузки в браузере на своем ПК (не в виртуальной машине) вы должны суметь зайти на localhost:19999. 
Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

[![Результат](https://yadi.sk/i/Js2UWft76ntq-Q)](https://yadi.sk/i/Js2UWft76ntq-Q)

## 4. Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
Очевидно, можно:   
**# dmesg | grep virtual**
[    0.001214] CPU MTRRs all blank - virtualized system.  
[    0.089277] Booting paravirtualized kernel on KVM  
[    3.347333] systemd[1]: Detected virtualization oracle.  


## 5. Как настроен sysctl fs.nr_open на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?
**Ответы:**  
5.1. Максимальное количество открытых файловых дескрипторов для процесса. По умолчанию: 1024\*1024 (1048576). См. https://sysctl-explorer.net/fs/nr_open/    
`# cat /proc/sys/fs/nr_open`
1048576

5.2.  ulimit -n <лимит>  
-n        the maximum number of open file descriptors  


## 6. Запустите любой долгоживущий процесс (не ls, который отработает мгновенно, а, например, sleep 1h) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через nsenter. Для простоты работайте в данном задании под root (sudo -i). Под обычным пользователем требуются дополнительные опции (--map-root-user) и т.д.  

`# unshare -f --pid --mount-proc /bin/bash -c "sleep 1h"`  
`# lsns`  
4026532204 mnt         2  3461 root             unshare -f --pid --mount-proc /bin/bash -c sleep 1h  
4026532205 pid         1  3462 root             sleep 1h  

`# nsenter --target 3462 --pid --mount`  
`# ps aux`  
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND  
root         **1**  0.0  0.0   7404   772 pts/0    S+   13:26   0:00 **sleep 1h**
root           2  0.5  0.5  10468  5232 pts/1    S    13:26   0:00 -bash  
root          13  0.0  0.3  11728  3460 pts/1    R+   13:26   0:00 ps aux  


## 7. Найдите информацию о том, что такое :(){ :|:& };:. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов dmesg расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?  

Вывод dmesg:  
[ 2124.970311] Out of memory: Killed process 526 (systemd-timesyn) total-vm:88516kB, anon-rss:760kB, file-rss:2952kB, shmem-rss:0kB, UID:102 pgtables:72kB oom_score_adj:0  
[ 2126.627420] systemd-journald[349]: /dev/kmsg buffer overrun, some messages lost.  

**Out-Of-Memory Killer**  
Как работает OOM Killer: http://catap.ru/blog/2009/05/03/about-memory-oom-killer/    
Как изменить максимальное число процессов:  
`sysctl kernel.pid_max=256000`


