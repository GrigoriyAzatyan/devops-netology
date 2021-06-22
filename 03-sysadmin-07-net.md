## 1. На лекции мы обсудили, что манипулировать размером окна необходимо для эффективного наполнения приемного буфера участников TCP сессии (Flow Control). Подобная проблема в полной мере возникает в сетях с высоким RTT. Например, если вы захотите передать 500 Гб бэкап из региона Юга-Восточной Азии на Восточное побережье США. Здесь вы можете увидеть и 200 и 400 мс вполне реального RTT. Подсчитайте, какого размера нужно окно TCP чтобы наполнить 1 Гбит/с канал при 300 мс RTT (берем простую ситуацию без потери пакетов). Можно воспользоваться готовым калькулятором. Ознакомиться с формулами, по которым работает калькулятор можно, например, на Wiki.  
Ответ: [35.76 МБ](https://yadi.sk/i/NNx_80GIGiflcQ)


## 2. Во сколько раз упадет пропускная способность канала, если будет 1% потерь пакетов при передаче?  
Пробуем выполнить iperf между хостом и виртуальной машиной:  
iperf3 -c 10.0.0.49  
`Connecting to host 10.0.0.49, port 5201`  
`[  5] local 10.0.0.41 port 58544 connected to 10.0.0.49 port 5201`  
`[ ID] Interval           Transfer     Bitrate         Retr  Cwnd`  
`[  5]   0.00-1.00   sec   283 MBytes  2.37 Gbits/sec    0    221 KBytes`  
`[  5]   1.00-2.00   sec   281 MBytes  2.36 Gbits/sec    0    221 KBytes`  
`[  5]   2.00-3.00   sec   287 MBytes  2.41 Gbits/sec    0    221 KBytes`  
`[  5]   3.00-4.00   sec   282 MBytes  2.37 Gbits/sec    0    221 KBytes`  
`[  5]   4.00-5.00   sec   280 MBytes  2.35 Gbits/sec    0    221 KBytes`  
`[  5]   5.00-6.00   sec   288 MBytes  2.41 Gbits/sec    0    221 KBytes`  
`[  5]   6.00-7.00   sec   288 MBytes  2.41 Gbits/sec    0    221 KBytes`  
`[  5]   7.00-8.00   sec   286 MBytes  2.40 Gbits/sec    0    221 KBytes`  
`[  5]   8.00-9.00   sec   286 MBytes  2.40 Gbits/sec    0    221 KBytes`  
`[  5]   9.00-10.00  sec   286 MBytes  2.40 Gbits/sec    0    221 KBytes`  
`- - - - - - - - - - - - - - - - - - - - - - - - -`  
`[ ID] Interval           Transfer     Bitrate         Retr`  
`[  5]   0.00-10.00  sec  2.78 GBytes  2.39 Gbits/sec    0             sender`  
`[  5]   0.00-10.00  sec  2.78 GBytes  2.39 Gbits/sec                  receiver`  

Исходная пропускная способность составляет **2.39 Gbits/sec.**  

Добавим со стороны клиента искусственную потерю пакетов:    
`tc qdisc add dev enp0s3 root netem loss 1%`    
  
Повторим замер:   
iperf3 -c 10.0.0.49  
`Connecting to host 10.0.0.49, port 5201`  
`[  5] local 10.0.0.41 port 58580 connected to 10.0.0.49 port 5201`  
`[ ID] Interval           Transfer     Bitrate         Retr  Cwnd`  
`[  5]   0.00-1.00   sec   205 MBytes  1.72 Gbits/sec  1820   49.9 KBytes`  
`[  5]   1.00-2.00   sec   235 MBytes  1.97 Gbits/sec  1799   44.2 KBytes`  
`[  5]   2.00-3.00   sec   239 MBytes  2.01 Gbits/sec  1844   88.4 KBytes`  
`[  5]   3.00-4.00   sec   236 MBytes  1.98 Gbits/sec  1837   62.7 KBytes`  
`[  5]   4.00-5.00   sec   238 MBytes  2.00 Gbits/sec  1770   74.1 KBytes`  
`[  5]   5.00-6.00   sec   234 MBytes  1.96 Gbits/sec  1622   38.5 KBytes`  
`[  5]   6.00-7.00   sec   242 MBytes  2.03 Gbits/sec  1889   48.5 KBytes`  
`[  5]   7.00-8.00   sec   240 MBytes  2.01 Gbits/sec  1813   38.5 KBytes`  
`[  5]   8.00-9.00   sec   228 MBytes  1.91 Gbits/sec  1887   58.5 KBytes`  
`[  5]   9.00-10.00  sec   229 MBytes  1.92 Gbits/sec  1963   44.2 KBytes`  
`- - - - - - - - - - - - - - - - - - - - - - - - -`  
`[ ID] Interval           Transfer     Bitrate         Retr`  
`[  5]   0.00-10.00  sec  2.27 GBytes  1.95 Gbits/sec  18244             sender`  
`[  5]   0.00-10.00  sec  2.27 GBytes  1.95 Gbits/sec                  receiver`  

**Итого: скорость была 2.39 Gbits/sec, стала 1.95 Gbits/sec, уменьшилась в 1,22 раза.** 

## 3. Какая максимальная реальная скорость передачи данных достижима при линке 100 Мбит/с? Вопрос про TCP payload, то есть цифры, которые вы реально увидите в операционной системе в тестах или в браузере при скачивании файлов. Повлияет ли размер фрейма на это?  
**С MTU 1500:** Max TCP Payload= (MTU–TCP–IP) / (MTU+Ethernet+IFG) = (1500–40) / (1500+26+12) = **94.9 Mbit/s**  
**С MTU 9000:** Max TCP Payload= (MTU–TCP–IP) / (MTU+Ethernet+IFG) = (9000–40) / (9000+26+12) = **99.13 Mbit/s**  

## 4. Что на самом деле происходит, когда вы открываете сайт? :) На прошлой лекции был приведен сокращенный вариант ответа на этот вопрос. Теперь вы знаете намного больше, в частности про IP адресацию, DNS и т.д. Опишите максимально подробно насколько вы это можете сделать, что происходит, когда вы делаете запрос curl -I http://netology.ru с вашей рабочей станции. Предположим, что arp кеш очищен, в локальном DNS нет закешированных записей.

**strace -o ~/curl.dump curl -I http://netology.ru**  
Что интересного здесь можно увидеть:  

Запускается curl:    
`execve("/usr/bin/curl", ["curl", "-I", "http://netology.ru"], 0x7ffc486e97a0 /* 18 vars */) = 0`  

Видно обращение к библиотеке резолвера:    
`openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libresolv.so.2", O_RDONLY|O_CLOEXEC) = 3`  

Сетевое соединение к 104.22.48.171:80  
`connect(5, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("104.22.48.171")}, 16) = -1 EINPROGRESS (Операция выполняется в данный момент)`

Удаленный сокет 104.22.48.171:80, локальный сокет 192.168.1.103:47076  
`getpeername(5, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("104.22.48.171")}, [128->16]) = 0`
`getsockname(5, {sa_family=AF_INET, sin_port=htons(47076), sin_addr=inet_addr("192.168.1.103")}, [128->16]) = 0`

Отправка HTTP команд в сокет:  
`sendto(5, "HEAD / HTTP/1.1\r\nHost: netology."..., 76, MSG_NOSIGNAL, NULL, 0) = 76`  

Получен ответ:    
`recvfrom(5, "HTTP/1.1 301 Moved Permanently\r\n"..., 102400, 0, NULL, NULL) = 397`  

Вывод сообщений:    
`write(1, "HTTP/1.1 301 Moved Permanently\r\n", 32) = 32`  
`write(1, "\33[1mDate\33[0m: Tue, 22 Jun 2021 1"..., 45) = 45`  
`write(1, "\33[1mConnection\33[0m: keep-alive\r\n", 32) = 32`  
`write(1, "\33[1mCache-Control\33[0m: max-age=3"..., 37) = 37`  
`write(1, "\33[1mExpires\33[0m: Tue, 22 Jun 202"..., 48) = 48`  
`...`

**Анализ сетевого дампа (команда запущена повторно, IP сервера и порт источника уже другие):**  

**Кадры 1-2: ARP-запрос и ответ:**  

    No.     Time                          Source                Destination           Protocol Length Info
          1 2021-06-22 21:50:52,493785    IntelCor_13:2a:09     Broadcast             ARP      60     Who has 192.168.1.1? Tell 192.168.1.103

    Frame 1: 60 bytes on wire (480 bits), 60 bytes captured (480 bits) on interface \Device\NPF_{BA46532C-F0D5-4BC0-8108-15770106582A}, id 0
    Ethernet II, Src: IntelCor_13:2a:09 (14:f6:d8:13:2a:09), Dst: Broadcast (ff:ff:ff:ff:ff:ff)
    Address Resolution Protocol (request)
        Hardware type: Ethernet (1)
        Protocol type: IPv4 (0x0800)
        Hardware size: 6
        Protocol size: 4
        Opcode: request (1)
        Sender MAC address: IntelCor_13:2a:09 (14:f6:d8:13:2a:09)
        Sender IP address: 192.168.1.103
        Target MAC address: 00:00:00_00:00:00 (00:00:00:00:00:00)
        Target IP address: 192.168.1.1

    No.     Time                          Source                Destination           Protocol Length Info
          2 2021-06-22 21:50:52,495936    Tp-LinkT_0e:74:dc     IntelCor_13:2a:09     ARP      42     192.168.1.1 is at 98:da:c4:0e:74:dc

    Frame 2: 42 bytes on wire (336 bits), 42 bytes captured (336 bits) on interface \Device\NPF_{BA46532C-F0D5-4BC0-8108-15770106582A}, id 0
    Ethernet II, Src: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc), Dst: IntelCor_13:2a:09 (14:f6:d8:13:2a:09)
    Address Resolution Protocol (reply)
        Hardware type: Ethernet (1)
        Protocol type: IPv4 (0x0800)
        Hardware size: 6
        Protocol size: 4
        Opcode: reply (2)
        Sender MAC address: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
        Sender IP address: 192.168.1.1
        Target MAC address: IntelCor_13:2a:09 (14:f6:d8:13:2a:09)
        Target IP address: 192.168.1.103

**Кадры 24-27: Запрос к Яндекс DNS и ответ от сервера на разрешение имени netology.ru:**  

    No.     Time                          Source                Destination           Protocol Length Info
         24 2021-06-22 21:11:40,015613    192.168.1.103         77.88.8.7             DNS      82     Standard query 0xbdaf A netology.ru OPT

    Frame 24: 82 bytes on wire (656 bits), 82 bytes captured (656 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 77.88.8.7
    User Datagram Protocol, Src Port: 46541, Dst Port: 53
    Domain Name System (query)

    No.     Time                          Source                Destination           Protocol Length Info
         25 2021-06-22 21:11:40,015736    192.168.1.103         77.88.8.7             DNS      82     Standard query 0x0491 AAAA netology.ru OPT

    Frame 25: 82 bytes on wire (656 bits), 82 bytes captured (656 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 77.88.8.7
    User Datagram Protocol, Src Port: 33233, Dst Port: 53
    Domain Name System (query)

    No.     Time                          Source                Destination           Protocol Length Info
         26 2021-06-22 21:11:40,052995    77.88.8.7             192.168.1.103         DNS      130    Standard query response 0xbdaf A netology.ru A 172.67.43.83 A 104.22.48.171 A 104.22.49.171 OPT

    Frame 26: 130 bytes on wire (1040 bits), 130 bytes captured (1040 bits)
    Ethernet II, Src: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc), Dst: PcsCompu_97:b0:ce (08:00:27:97:b0:ce)
    Internet Protocol Version 4, Src: 77.88.8.7, Dst: 192.168.1.103
    User Datagram Protocol, Src Port: 53, Dst Port: 46541
    Domain Name System (response)

    No.     Time                          Source                Destination           Protocol Length Info
         27 2021-06-22 21:11:40,060738    77.88.8.7             192.168.1.103         DNS      166    Standard query response 0x0491 AAAA netology.ru AAAA 2606:4700:10::6816:30ab AAAA 2606:4700:10::ac43:2b53 AAAA 2606:4700:10::6816:31ab OPT

    Frame 27: 166 bytes on wire (1328 bits), 166 bytes captured (1328 bits)
    Ethernet II, Src: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc), Dst: PcsCompu_97:b0:ce (08:00:27:97:b0:ce)
    Internet Protocol Version 4, Src: 77.88.8.7, Dst: 192.168.1.103
    User Datagram Protocol, Src Port: 53, Dst Port: 33233
    Domain Name System (response)


**Кадры 28-30: TCP-рукопожатие с сервером**  

    No.     Time                          Source                Destination           Protocol Length Info
         28 2021-06-22 21:11:40,061199    192.168.1.103         172.67.43.83          TCP      74     38168 → 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM=1 TSval=1152883617 TSecr=0 WS=128
    Frame 28: 74 bytes on wire (592 bits), 74 bytes captured (592 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 172.67.43.83
    Transmission Control Protocol, Src Port: 38168, Dst Port: 80, Seq: 0, Len: 0
        Source Port: 38168
        Destination Port: 80
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 0    (relative sequence number)
        Sequence number (raw): 179869802
        [Next sequence number: 1    (relative sequence number)]
        Acknowledgment number: 0
        Acknowledgment number (raw): 0
        1010 .... = Header Length: 40 bytes (10)
        Flags: 0x002 (SYN)
        Window size value: 64240
        [Calculated window size: 64240]
        Checksum: 0x99d4 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        Options: (20 bytes), Maximum segment size, SACK permitted, Timestamps, No-Operation (NOP), Window scale
        [Timestamps]

    No.     Time                          Source                Destination           Protocol Length Info
         29 2021-06-22 21:11:40,101338    172.67.43.83          192.168.1.103         TCP      66     80 → 38168 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1400 SACK_PERM=1 WS=1024

    Frame 29: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    Ethernet II, Src: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc), Dst: PcsCompu_97:b0:ce (08:00:27:97:b0:ce)
    Internet Protocol Version 4, Src: 172.67.43.83, Dst: 192.168.1.103
    Transmission Control Protocol, Src Port: 80, Dst Port: 38168, Seq: 0, Ack: 1, Len: 0
        Source Port: 80
        Destination Port: 38168
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 0    (relative sequence number)
        Sequence number (raw): 3505231623
        [Next sequence number: 1    (relative sequence number)]
        Acknowledgment number: 1    (relative ack number)
        Acknowledgment number (raw): 179869803
        1000 .... = Header Length: 32 bytes (8)
        Flags: 0x012 (SYN, ACK)
        Window size value: 65535
        [Calculated window size: 65535]
        Checksum: 0x3513 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        Options: (12 bytes), Maximum segment size, No-Operation (NOP), No-Operation (NOP), SACK permitted, No-Operation (NOP), Window scale
        [SEQ/ACK analysis]
        [Timestamps]

    No.     Time                          Source                Destination           Protocol Length Info
         30 2021-06-22 21:11:40,101360    192.168.1.103         172.67.43.83          TCP      54     38168 → 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0

    Frame 30: 54 bytes on wire (432 bits), 54 bytes captured (432 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 172.67.43.83
    Transmission Control Protocol, Src Port: 38168, Dst Port: 80, Seq: 1, Ack: 1, Len: 0
        Source Port: 38168
        Destination Port: 80
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 1    (relative sequence number)
        Sequence number (raw): 179869803
        [Next sequence number: 1    (relative sequence number)]
        Acknowledgment number: 1    (relative ack number)
        Acknowledgment number (raw): 3505231624
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x010 (ACK)
        Window size value: 502
        [Calculated window size: 64256]
        [Window size scaling factor: 128]
        Checksum: 0x99c0 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [SEQ/ACK analysis]
        [Timestamps]

    
**Кадр 31: HTTP-запрос**  
No.     Time                          Source                Destination           Protocol Length Info
    31 2021-06-22 21:11:40,101433    192.168.1.103         172.67.43.83          HTTP     130    HEAD / HTTP/1.1 
    
    Frame 31: 130 bytes on wire (1040 bits), 130 bytes captured (1040 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 172.67.43.83
    Transmission Control Protocol, Src Port: 38168, Dst Port: 80, Seq: 1, Ack: 1, Len: 76
        Source Port: 38168
        Destination Port: 80
        [Stream index: 1]
        [TCP Segment Len: 76]
        Sequence number: 1    (relative sequence number)
        Sequence number (raw): 179869803
        [Next sequence number: 77    (relative sequence number)]
        Acknowledgment number: 1    (relative ack number)
        Acknowledgment number (raw): 3505231624
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x018 (PSH, ACK)
        Window size value: 502
        [Calculated window size: 64256]
        [Window size scaling factor: 128]
        Checksum: 0x9a0c [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [SEQ/ACK analysis]
        [Timestamps]
        TCP payload (76 bytes)
    Hypertext Transfer Protocol
        HEAD / HTTP/1.1\r\n
        Host: netology.ru\r\n
        User-Agent: curl/7.68.0\r\n
        Accept: */*\r\n
        \r\n
        [Full request URI: http://netology.ru/]
        [HTTP request 1/1]
        [Response in frame: 33]


**Кадр 32: ACK от сервера**  

    No.     Time                          Source                Destination           Protocol Length Info
         32 2021-06-22 21:11:40,141900    172.67.43.83          192.168.1.103         TCP      60     80 → 38168 [ACK] Seq=1 Ack=77 Win=65536 Len=0

    Frame 32: 60 bytes on wire (480 bits), 60 bytes captured (480 bits)
    Ethernet II, Src: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc), Dst: PcsCompu_97:b0:ce (08:00:27:97:b0:ce)
    Internet Protocol Version 4, Src: 172.67.43.83, Dst: 192.168.1.103
    Transmission Control Protocol, Src Port: 80, Dst Port: 38168, Seq: 1, Ack: 77, Len: 0
        Source Port: 80
        Destination Port: 38168
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 1    (relative sequence number)
        Sequence number (raw): 3505231624
        [Next sequence number: 1    (relative sequence number)]
        Acknowledgment number: 77    (relative ack number)
        Acknowledgment number (raw): 179869879
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x010 (ACK)
        Window size value: 64
        [Calculated window size: 65536]
        [Window size scaling factor: 1024]
        Checksum: 0x7520 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [SEQ/ACK analysis]
        [Timestamps]

    No.     Time                          Source                Destination           Protocol Length Info
         33 2021-06-22 21:11:40,150298    172.67.43.83          192.168.1.103         HTTP     451    HTTP/1.1 301 Moved Permanently 


**Кадр 33: HTTP-ответ от сервера (301 Moved Permanently)**  

    Frame 33: 451 bytes on wire (3608 bits), 451 bytes captured (3608 bits)
    Ethernet II, Src: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc), Dst: PcsCompu_97:b0:ce (08:00:27:97:b0:ce)
    Internet Protocol Version 4, Src: 172.67.43.83, Dst: 192.168.1.103
    Transmission Control Protocol, Src Port: 80, Dst Port: 38168, Seq: 1, Ack: 77, Len: 397
        Source Port: 80
        Destination Port: 38168
        [Stream index: 1]
        [TCP Segment Len: 397]
        Sequence number: 1    (relative sequence number)
        Sequence number (raw): 3505231624
        [Next sequence number: 398    (relative sequence number)]
        Acknowledgment number: 77    (relative ack number)
        Acknowledgment number (raw): 179869879
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x018 (PSH, ACK)
        Window size value: 64
        [Calculated window size: 65536]
        [Window size scaling factor: 1024]
        Checksum: 0x2f21 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [SEQ/ACK analysis]
        [Timestamps]
        TCP payload (397 bytes)
    Hypertext Transfer Protocol
        HTTP/1.1 301 Moved Permanently\r\n
        Date: Tue, 22 Jun 2021 16:11:40 GMT\r\n
        Connection: keep-alive\r\n
        Cache-Control: max-age=3600\r\n
        Expires: Tue, 22 Jun 2021 17:11:40 GMT\r\n
        Location: https://netology.ru/\r\n
        cf-request-id: 0ad616eeb20000161008b95000000001\r\n
        Server: cloudflare\r\n
        CF-RAY: 6636c0f78b4a1610-DME\r\n
        alt-svc: h3-27=":443"; ma=86400, h3-28=":443"; ma=86400, h3-29=":443"; ma=86400, h3=":443"; ma=86400\r\n
        \r\n
        [HTTP response 1/1]
        [Time since request: 0.048865000 seconds]
        [Request in frame: 31]
        [Request URI: http://netology.ru/]

**Кадр 34: ACK от клиента**  

    No.     Time                          Source                Destination           Protocol Length Info
         34 2021-06-22 21:11:40,150308    192.168.1.103         172.67.43.83          TCP      54     38168 → 80 [ACK] Seq=77 Ack=398 Win=64128 Len=0

    Frame 34: 54 bytes on wire (432 bits), 54 bytes captured (432 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 172.67.43.83
    Transmission Control Protocol, Src Port: 38168, Dst Port: 80, Seq: 77, Ack: 398, Len: 0
        Source Port: 38168
        Destination Port: 80
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 77    (relative sequence number)
        Sequence number (raw): 179869879
        [Next sequence number: 77    (relative sequence number)]
        Acknowledgment number: 398    (relative ack number)
        Acknowledgment number (raw): 3505232021
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x010 (ACK)
        Window size value: 501
        [Calculated window size: 64128]
        [Window size scaling factor: 128]
        Checksum: 0x99c0 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [SEQ/ACK analysis]
        [Timestamps]

**Кадры 35-37: завершение TCP-сессии**  

    No.     Time                          Source                Destination           Protocol Length Info
         35 2021-06-22 21:11:40,150539    192.168.1.103         172.67.43.83          TCP      54     38168 → 80 [FIN, ACK] Seq=77 Ack=398 Win=64128 Len=0

    Frame 35: 54 bytes on wire (432 bits), 54 bytes captured (432 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 172.67.43.83
    Transmission Control Protocol, Src Port: 38168, Dst Port: 80, Seq: 77, Ack: 398, Len: 0
        Source Port: 38168
        Destination Port: 80
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 77    (relative sequence number)
        Sequence number (raw): 179869879
        [Next sequence number: 78    (relative sequence number)]
        Acknowledgment number: 398    (relative ack number)
        Acknowledgment number (raw): 3505232021
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x011 (FIN, ACK)
        Window size value: 501
        [Calculated window size: 64128]
        [Window size scaling factor: 128]
        Checksum: 0x99c0 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [Timestamps]

    No.     Time                          Source                Destination           Protocol Length Info
         36 2021-06-22 21:11:40,199296    172.67.43.83          192.168.1.103         TCP      60     80 → 38168 [FIN, ACK] Seq=398 Ack=78 Win=65536 Len=0

    Frame 36: 60 bytes on wire (480 bits), 60 bytes captured (480 bits)
    Ethernet II, Src: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc), Dst: PcsCompu_97:b0:ce (08:00:27:97:b0:ce)
    Internet Protocol Version 4, Src: 172.67.43.83, Dst: 192.168.1.103
    Transmission Control Protocol, Src Port: 80, Dst Port: 38168, Seq: 398, Ack: 78, Len: 0
        Source Port: 80
        Destination Port: 38168
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 398    (relative sequence number)
        Sequence number (raw): 3505232021
        [Next sequence number: 399    (relative sequence number)]
        Acknowledgment number: 78    (relative ack number)
        Acknowledgment number (raw): 179869880
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x011 (FIN, ACK)
        Window size value: 64
        [Calculated window size: 65536]
        [Window size scaling factor: 1024]
        Checksum: 0x7391 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [SEQ/ACK analysis]
        [Timestamps]

    No.     Time                          Source                Destination           Protocol Length Info
         37 2021-06-22 21:11:40,199320    192.168.1.103         172.67.43.83          TCP      54     38168 → 80 [ACK] Seq=78 Ack=399 Win=64128 Len=0

    Frame 37: 54 bytes on wire (432 bits), 54 bytes captured (432 bits)
    Ethernet II, Src: PcsCompu_97:b0:ce (08:00:27:97:b0:ce), Dst: Tp-LinkT_0e:74:dc (98:da:c4:0e:74:dc)
    Internet Protocol Version 4, Src: 192.168.1.103, Dst: 172.67.43.83
    Transmission Control Protocol, Src Port: 38168, Dst Port: 80, Seq: 78, Ack: 399, Len: 0
        Source Port: 38168
        Destination Port: 80
        [Stream index: 1]
        [TCP Segment Len: 0]
        Sequence number: 78    (relative sequence number)
        Sequence number (raw): 179869880
        [Next sequence number: 78    (relative sequence number)]
        Acknowledgment number: 399    (relative ack number)
        Acknowledgment number (raw): 3505232022
        0101 .... = Header Length: 20 bytes (5)
        Flags: 0x010 (ACK)
        Window size value: 501
        [Calculated window size: 64128]
        [Window size scaling factor: 128]
        Checksum: 0x99c0 [unverified]
        [Checksum Status: Unverified]
        Urgent pointer: 0
        [SEQ/ACK analysis]
        [Timestamps]


## 5. Сколько и каких итеративных запросов будет сделано при резолве домена www.google.co.uk?
* DNS провайдера ищет запись в своем кэше, и при отсутствии посылает запрос **одному из корневых серверов**, на что получает NS-запись о сервере, обслуживающем зону **.uk** (первый по списку - **dns1.nic.uk.**);  
* DNS провайдера посылает запрос серверу **dns1.nic.uk.** и получает NS-запись о сервере, обслуживающем зону **co.uk** (первый по списку - **dns4.nic.uk.**);  
* DNS провайдера посылает запрос серверу **dns4.nic.uk.** и получает NS-запись о сервере, обслуживающемзону **google.co.uk** (первый по списку - **ns1.google.com.**);  
* DNS провайдера посылает запрос серверу **ns1.google.com.** A-запись об имени **www.google.co.uk** (**64.233.161.94**).  
Итого 4 итеративных запроса.

## 6. Сколько доступно для назначения хостам адресов в подсети /25? А в подсети с маской 255.248.0.0. Постарайтесь потренироваться в ручных вычислениях чтобы немного набить руку, не пользоваться калькулятором сразу.
С 25 маской - 126 узлов, с 255.248.0.0 (префикс 21) - 2046 узлов.  

## 7. В какой подсети больше адресов, в /23 или /24?  
С 23 маской адресов вдвое больше.  

## 8. Получится ли разделить диапазон 10.0.0.0/8 на 128 подсетей по 131070 адресов в каждой? Какая маска будет у таких подсетей?
У подсети 10.0.0.0/8 16777216 адресов. Делим на 128, получаем 131072. Вычитая адрес сети и broadcast, получаем 131070 адресов узлов.  
Берем 2 узла у маски 31, начинаем возводить двойку в степень, с каждым шагом уменьшая маску на 1. Получается 131072 на 15 маске.
Итого, у подсетей будет маска 255.254.0.0 (/15).  
