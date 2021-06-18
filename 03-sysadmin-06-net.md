## 1. Необязательное задание: можно посмотреть целый фильм в консоли telnet towel.blinkenlights.nl :)  
    All 1000 scanned ports on towel.blinkenlights.nl (213.136.8.188) are closed (999) or filtered (1)  
    Nmap done: 1 IP address (1 host up) scanned in 10.52 seconds  
Неудача, все порты закрыты. Видимо, лавочка больше не работает. :(

## 2. Узнайте о том, сколько действительно независимых (не пересекающихся) каналов есть в разделяемой среде WiFi при работе на 2.4 ГГц. Стандарты с полосой 5 ГГц более актуальны, но регламенты на 5 ГГц существенно различаются в разных странах, а так же не раз обновлялись. В качестве дополнительного вопроса вне зачета, попробуйте найти актуальный ответ и на этот вопрос.
**2,4 ГГц:**    
* 13 каналов, из них не пересекающиеся: 1, 6 и 11.    

**5 ГГц:**   
* UNII-1. Начиная снизу, самые нижние четыре канала на 5 ГГц вместе называются полосой UNII-1. Каналы 36, 40, 44 и 48.     
* UNII-2. Секция UNII-2 также содержит четыре канала – 52, 56, 60 и 64.  
* UNII-3. Каналы: 149, 153, 157, 161 и 165.  
* UNII-4, служба ближней связи. Каналы в этом диапазоне зарезервированы для лицензированных радиолюбителей и DSRC.  

## 3. Адрес канального уровня – MAC адрес – это 6 байт, первые 3 из которых называются OUI – Organizationally Unique Identifier или уникальный идентификатор организации. Какому производителю принадлежит MAC 38:f9:d3:55:55:79?
Apple, Inc   

## 4. Каким будет payload TCP сегмента, если Ethernet MTU задан в 9001 байт, размер заголовков IPv4 – 20 байт, а TCP – 32 байта?

## 5. Может ли во флагах TCP одновременно быть установлены флаги SYN и FIN при штатном режиме работы сети? Почему да или нет?

## 6. ss -ula sport = :53 на хосте имеет следующий вывод:

State           Recv-Q          Send-Q                   Local Address:Port                     Peer Address:Port          Process
UNCONN          0               0                        127.0.0.53%lo:domain                        0.0.0.0:*
Почему в State присутствует только UNCONN, и может ли там присутствовать, например, TIME-WAIT?

## 7. Обладая знаниями о том, как штатным образом завершается соединение (FIN от инициатора, FIN-ACK от ответчика, ACK от инициатора), опишите в каких состояниях будет находиться TCP соединение в каждый момент времени на клиенте и на сервере при завершении. Схема переходов состояния соединения вам в этом поможет.

## 8. TCP порт – 16 битное число. Предположим, 2 находящихся в одной сети хоста устанавливают между собой соединения. Каким будет теоретическое максимальное число соединений, ограниченное только лишь параметрами L4, которое параллельно может установить клиент с одного IP адреса к серверу с одним IP адресом? Сколько соединений сможет обслужить сервер от одного клиента? А если клиентов больше одного?

## 9. Может ли сложиться ситуация, при которой большое число соединений TCP на хосте находятся в состоянии TIME-WAIT? Если да, то является ли она хорошей или плохой? Подкрепите свой ответ пояснением той или иной оценки.

## 10. Чем особенно плоха фрагментация UDP относительно фрагментации TCP?

## 11. Если бы вы строили систему удаленного сбора логов, то есть систему, в которой несколько хостов отправяют на центральный узел генерируемые приложениями логи (предположим, что логи – текстовая информация), какой протокол транспортного уровня вы выбрали бы и почему? Проверьте ваше предположение самостоятельно, узнав о стандартном протоколе syslog. 
Здесь хорошая статья: https://www.rapid7.com/blog/post/2014/07/15/tcp-or-udp-for-logging/  
Выбор транспортного протокола зависит от подключаемых устройств, объема ресурсов и требований приложения.   

**Плюсы UDP:**  
* Быстрота;
* Минимальная нагрузка на системные ресурсы;
* Совместимость со старыми устройствами (не поддерживают TCP);

**Минусы UDP:**  
* Негарантированная доставка данных.

**Рекомендуется к использованию:** для логирования большого количества некритичных событий.   
  
**Плюсы TCP:**   
* Гарантированная доставка данных.

**Минусы TCP:**  
* Не такой быстрый;
* Больше нагружает системные ресурсы;
* Не все устройства поддерживают TCP.  

**Рекомендуется к использованию:** для логирования нечасто возникающих важных событий.

## 12. Сколько портов TCP находится в состоянии прослушивания на вашей виртуальной машине с Ubuntu, и каким процессам они принадлежат?  
**netstat -atpn**  
`Активные соединения с интернетом (servers and established)`    
`Proto Recv-Q Send-Q Local Address Foreign Address State       PID/Program name`    
`tcp        0      0 0.0.0.0:2049            0.0.0.0:*               LISTEN      -`   
`tcp        0      0 0.0.0.0:41935           0.0.0.0:*               LISTEN      -  `  
`tcp        0      0 0.0.0.0:42287           0.0.0.0:*               LISTEN      809/rpc.mountd`    
`tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init`    
`tcp        0      0 0.0.0.0:49429           0.0.0.0:*               LISTEN      809/rpc.mountd`    
`tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      617/systemd-resolve`    
`tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      800/sshd: /usr/sbin`    
`tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN      755/cupsd`    
`tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1812/master`    
`tcp        0      0 127.0.0.1:8125          0.0.0.0:*               LISTEN      1816/netdata`    
`tcp        0      0 0.0.0.0:60413           0.0.0.0:*               LISTEN      809/rpc.mountd`    
`tcp        0      0 127.0.0.1:19999         0.0.0.0:*               LISTEN      1816/netdata`    
`tcp        0     64 192.168.1.104:22        192.168.1.103:52031     ESTABLISHED 3833/sshd: grigorii`    
`tcp6       0      0 :::2049                 :::*                    LISTEN      -`    
`tcp6       0      0 :::46667                :::*                    LISTEN      809/rpc.mountd`    
`tcp6       0      0 :::111                  :::*                    LISTEN      1/init`    
`tcp6       0      0 :::22                   :::*                    LISTEN      800/sshd: /usr/sbin`    
`tcp6       0      0 ::1:631                 :::*                    LISTEN      755/cupsd`    
`tcp6       0      0 ::1:25                  :::*                    LISTEN      1812/master`    
`tcp6       0      0 :::41881                :::*                    LISTEN      -`    
`tcp6       0      0 :::57465                :::*                    LISTEN      809/rpc.mountd`    
`tcp6       0      0 :::53567                :::*                    LISTEN      809/rpc.mountd`    

Итого:   
* 12 портов tcp в состоянии LISTEN (22 в состоянии ESTABLISHED)  
* 9 портов tcp6 в состоянии LISTEN.
* PIDы прилагаются.  

## 13. Какой ключ нужно добавить в tcpdump, чтобы он начал выводить не только заголовки, но и содержимое фреймов в текстовом виде? А в текстовом и шестнадцатиричном?
В man tcpdump указано про ключи -e, -x, X, XX, позволяющие добавлять к выводимым данным заголовки канального уровня и содержимое *пакетов* в разном сочетании, однако ничего не написано про содержимое *фреймов*. 
Из того, что я нашел в man tcpdump:   

* Выводить с данными также заголовки 2-го уровня:  
       -e     Print the link-level header on each dump line.  This can be used, for example, to print MAC layer addresses for protocols such as Ethernet and IEEE 802.11.
 
* Выводить заголовки пакета и данные в пакете, БЕЗ заголовка 2-го уровня, в HEX и ASCII:  
       -X     When parsing and printing, in addition to printing the headers of each packet, print the data of each packet (minus its link level header) in hex and ASCII.  This is very handy for analysing new protocols.
	   
* Выводить заголовки пакета и данные в пакете, включая  заголовок 2-го уровня, в HEX и ASCII:  
       -XX    When parsing and printing, in addition to printing the headers of each packet, print the data of each packet, including its link level header, in hex and ASCII.
       

## 14. Попробуйте собрать дамп трафика с помощью tcpdump на основном интерфейсе вашей виртуальной машины и посмотреть его через tshark или Wireshark (можно ограничить число пакетов -c 100). Встретились ли вам какие-то установленные флаги Internet Protocol (не флаги TCP, а флаги IP)? Узнайте, какие флаги бывают. Как на самом деле называется стандарт Ethernet, фреймы которого попали в ваш дамп? Можно ли где-то в дампе увидеть OUI?