# 1. ipvs. Если при запросе на VIP сделать подряд несколько запросов (например, for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done ), ответы будут получены почти мгновенно. Тем не менее, в выводе ipvsadm -Ln еще некоторое время будут висеть активные InActConn. Почему так происходит?
Думаю, что из-за режима DR. IP-пакет от клиента поступает на балансировщик, далее маршрутизируется на сервер. Между балансировщиком и сервером висит TCP-сессия, однако сервер отдает клиенту ответ напрямую. Эти незакрытые TCP-сессии и висят на балансировщике, пока не будут закрыты по таймауту.


# 2. На лекции мы познакомились отдельно с ipvs и отдельно с keepalived. Воспользовавшись этими знаниями, совместите технологии вместе (VIP должен подниматься демоном keepalived). Приложите конфигурационные файлы, которые у вас получились, и продемонстрируйте работу получившейся конструкции. Используйте для директора отдельный хост, не совмещая его с риалом! Подобная схема возможна, но выходит за рамки рассмотренного на лекции.

## Сетевые настройки:

### **netology1 (client)**

ip address show dev eth1 
     
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:cb:57:2b brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.10/24** scope global eth1  
       valid_lft forever preferred_lft forever  
    inet6 fe80::a00:27ff:fecb:572b/64 scope link  
       valid_lft forever preferred_lft forever  


### **netology2  (ipvsadm master)**

ip address show dev eth1 
      
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:ea:bc:42 brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.50/24** scope global eth1  
       valid_lft forever preferred_lft forever  
    inet **172.28.128.200/24** scope global secondary eth1  
       valid_lft forever preferred_lft forever    
    inet6 fe80::a00:27ff:feea:bc42/64 scope link  
       valid_lft forever preferred_lft forever  


### **netology3 (ipvsadm backup)**

ip address show dev eth1  
       
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:f9:ed:53 brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.60/24** scope global eth1   
       valid_lft forever preferred_lft forever  
    inet6 fe80::a00:27ff:fef9:ed53/64 scope link  
       valid_lft forever preferred_lft forever  

### **netology4 (real 1)**

ip address show  
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000  
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
    inet 127.0.0.1/8 scope host lo  
       valid_lft forever preferred_lft forever  
    inet **172.28.128.200/32** scope global lo:200  
       valid_lft forever preferred_lft forever  
    inet6 ::1/128 scope host  
       valid_lft forever preferred_lft forever  
       
...
       
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:23:1d:22 brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.110/24** scope global eth1  
       valid_lft forever preferred_lft forever  
    inet6 fe80::a00:27ff:fe23:1d22/64 scope link  
       valid_lft forever preferred_lft forever  
       
### **netology5 (real 2)**

ip address show  
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000  
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
    inet 127.0.0.1/8 scope host lo  
       valid_lft forever preferred_lft forever  
    inet **172.28.128.200/32** scope global lo:200  
       valid_lft forever preferred_lft forever  
    inet6 ::1/128 scope host  
       valid_lft forever preferred_lft forever  
       
...
       
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:69:db:85 brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.120/24** scope global eth1  
       valid_lft forever preferred_lft forever  
    inet6 fe80::a00:27ff:fe69:db85/64 scope link  
       valid_lft forever preferred_lft forever  


## Keepalived
### **netology2  (ipvsadm master)**
cat /etc/keepalived/keepalived.conf   
`vrrp_script chk_nginx {`  
`    script "systemctl status nginx"`  
`interval 2`  
`}`  

`vrrp_instance VI_1 {`  
`    state MASTER`  
`    interface eth1`  
`    virtual_router_id 33`  
`    priority 100`  
`    advert_int 1`  
`    authentication {`  
`    auth_type PASS`  
`    auth_pass netology_secret`  
`    }`  
`    virtual_ipaddress {`  
`        172.28.128.200/24 dev eth1`  
`    }`  
`    track_script {`  
`        chk_nginx`  
`        }`  
`}`  

### **netology3  (ipvsadm backup)**
cat /etc/keepalived/keepalived.conf   
`vrrp_script chk_nginx {`  
`    script "systemctl status nginx"`  
`interval 2`  
`}`  

`vrrp_instance VI_2 {`  
`    state BACKUP`  
`    interface eth1`  
`    virtual_router_id 33`  
`    priority 50`  
`    advert_int 1`  
`    authentication {`  
`    auth_type PASS`  
`    auth_pass netology_secret`  
`    }`  
`    virtual_ipaddress {`  
`        172.28.128.200/24 dev eth1`  
`    }`  
`    track_script {`  
`        chk_nginx`  
`        }`  
`}`

## Состояние балансировщика  
### **netology2  (ipvsadm master)**  
ipvsadm -Ln  
`IP Virtual Server version 1.2.1 (size=4096)`  
`Prot LocalAddress:Port Scheduler Flags`  
`  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn`  
`TCP  172.28.128.200:80 rr`  
`  -> 172.28.128.110:80            Route   1      0          0`  
`  -> 172.28.128.120:80            Route   1      0          0`  

### **netology3  (ipvsadm backup)**  
ipvsadm -Ln  
`IP Virtual Server version 1.2.1 (size=4096)`  
`Prot LocalAddress:Port Scheduler Flags`  
`  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn`  
`TCP  172.28.128.200:80 rr`  
`  -> 172.28.128.110:80            Route   1      0          0`  
`  -> 172.28.128.120:80            Route   1      0          0`  


## Тестирование VRRP  
### **netology2  (ipvsadm master)**  
**ip add show eth1**  
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:ea:bc:42 brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.50/24** scope global eth1  
       valid_lft forever preferred_lft forever  
    inet **172.28.128.200/24** scope global secondary eth1  
       valid_lft forever preferred_lft forever  
    inet6 fe80::a00:27ff:feea:bc42/64 scope link  
       valid_lft forever preferred_lft forever  
       
**systemctl stop nginx**  
**ip add show eth1**  
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:ea:bc:42 brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.50/24** scope global eth1  
       valid_lft forever preferred_lft forever  
    inet6 fe80::a00:27ff:feea:bc42/64 scope link  
       valid_lft forever preferred_lft forever  

### **netology3  (ipvsadm backup)**    
**ip add show eth1**  
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
    link/ether 08:00:27:f9:ed:53 brd ff:ff:ff:ff:ff:ff  
    inet **172.28.128.60/24** scope global eth1  
       valid_lft forever preferred_lft forever  
    inet **172.28.128.200/24** scope global secondary eth1  
       valid_lft forever preferred_lft forever  
    inet6 fe80::a00:27ff:fef9:ed53/64 scope link  
       valid_lft forever preferred_lft forever  

## Тестирование балансировки  
### **netology1  (client)**   
for i in {1..50}; do curl -I -s 172.28.128.200 > /dev/null; done

### **netology2  (ipvsadm master)**  
**ipvsadm -Ln --stats**   
IP Virtual Server version 1.2.1 (size=4096)  
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes  
  -> RemoteAddress:Port  
TCP  172.28.128.200:80                  **50**      300        0    19950        0  
  -> 172.28.128.110:80                  **25**      150        0     9975        0  
  -> 172.28.128.120:80                  **25**      150        0     9975        0  

**Результат**: виртуальный IP-адрес перетекает между инстансами VRRP, запросы на 80 порт балансируются поровну между хостами netology 4 и 5. 

# 3. В лекции мы использовали только 1 VIP адрес для балансировки. У такого подхода несколько отрицательных моментов, один из которых – невозможность активного использования нескольких хостов (1 адрес может только переехать с master на standby). Подумайте, сколько адресов оптимально использовать, если мы хотим без какой-либо деградации выдерживать потерю 1 из 3 хостов при входящем трафике 1.5 Гбит/с и физических линках хостов в 1 Гбит/с? Предполагается, что мы хотим задействовать 3 балансировщика в активном режиме (то есть не 2 адреса на 3 хоста, один из которых в обычное время простаивает).
