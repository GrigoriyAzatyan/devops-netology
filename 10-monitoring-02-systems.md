## 1. Опишите основные плюсы и минусы pull и push систем мониторинга.

### Push-модель

- Плюсы:

  - Упрощение репликации данных в разные системы мониторинга или их резервные копии (на клиенте настраивается конечная точка отправки или набор таких точек);
  - Более гибкая настройка отправки пакетов данных с метриками (на каждом клиенте задается объем данных и частоту отправки);
  - UDP является менее затратным способом передачи данных, вследствии чего может вырасти производительность сбора метрик (обратной стороной медали является гарантия доставки пакетов).

- Минусы:

  - Нет гарантии опроса только тех агентов, которые настроены в системе мониторинга;
  - Не получится настроить безопасное взаимодействие агентов с сервером через единый Proxy;
  - Сложнее собирать логи с агентов.


### Pull-модель

- Плюсы:

  - Легче контролировать подлинность данных (гарантия опроса только тех агентов, которые настроены в системе мониторинга);   
  - Можно настроить единый proxy-server до всех агентов с TLS (таким образом мы можем разнести систему мониторинга и агенты, с гарантией безопасности их взаимодействия);   
  - Упрощенная отладка получения данных с агентов (так как данные запрашиваются посредством HTTP, можно самостоятельно запрашивать эти данные, используя ПО вне системы мониторинга).

- Минусы:

  - Сложно организовать репликацию данных между разными системами мониторинга или их резервными копиями;   
  - Менее гибкая настройка отправки пакетов данных с метриками. Например, в Zabbix можно настроить частоту сбора метрик в рамках целого элемента данных, с которым может быть связано много конечных узлов. Если надо на каждом узле указать индивидуальную частоту, придется создавать новый элемент данных и шаблон для каждого узла;   
  - Сетевое взаимодействие по протоколу TCP: надежно, но не так быстро.  

## Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?
| Система | Тип | 
|---------|-----|
| Prometheus | Pull  | 
| TICK | Гибридная  | 
| Zabbix | Гибридная | 
| VictoriaMetrics | Гибридная  | 
| Nagios   | Pull | 

# 3.
Вроде работает:   
![Скриншот](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/TICK.jpg)

Контейнеры запустились:

```
$ docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED          STATUS          PORTS                                                                                                                             NAMES
7ed991230565   chrono_config           "/entrypoint.sh chro…"   13 minutes ago   Up 13 minutes   0.0.0.0:8888->8888/tcp, :::8888->8888/tcp  sandbox_chronograf_1
7d3ee24e59ac   telegraf                "/entrypoint.sh tele…"   13 minutes ago   Up 13 minutes   8092/udp, 8125/udp, 8094/tcp     sandbox_telegraf_1
71b0b3678d9e   kapacitor               "/entrypoint.sh kapa…"   13 minutes ago   Up 13 minutes   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp  sandbox_kapacitor_1
27be07161858   influxdb:2.1            "/entrypoint.sh infl…"   13 minutes ago   Up 13 minutes   0.0.0.0:8082->8082/tcp, :::8082->8082/tcp, 0.0.0.0:8086->8086/tcp, :::8086->8086/tcp, 0.0.0.0:8089->8089/udp, :::8089->8089/udp   sandbox_influxdb_1
fbc70d4af3fa   sandbox_documentation   "/documentation/docu…"   13 minutes ago   Up 13 minutes   0.0.0.0:3010->3000/tcp, :::3010->3000/tcp  sandbox_documentation_1
```

На запросы к API - пустые ответы. Возможно, потому что система еще не сконфигурирована:

`$ curl http://localhost:8086/ping`   

`$ curl -I http://localhost:8086/ping` 
```
HTTP/1.1 204 No Content
Content-Type: application/json
Request-Id: d7894c02-7d3a-11ec-805d-0242ac140003
X-Influxdb-Build: OSS
X-Influxdb-Version: 1.8.10
X-Request-Id: d7894c02-7d3a-11ec-805d-0242ac140003
Date: Mon, 24 Jan 2022 17:27:01 GMT
```

`$ curl http://localhost:8086/ping`

`$ curl http://localhost:8888`
```
<!DOCTYPE html><html><head><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>Chronograf</title><link rel="icon shortcut" href="/favicon.fa749080.ico"><link rel="stylesheet" href="/src.3dbae016.css"></head><body> <div id="react-root" data-basepath=""></div> <script src="/src.fab22342.js"></script> </body></html>
```

`$ curl http://localhost:9092/kapacitor/v1/ping`

`$ curl -I http://localhost:9092/kapacitor/v1/ping`

```
HTTP/1.1 204 No Content
Content-Type: application/json; charset=utf-8
Request-Id: ecfadcec-7d3a-11ec-8033-000000000000
X-Kapacitor-Version: 1.6.2
Date: Mon, 24 Jan 2022 17:27:37 GMT
```
