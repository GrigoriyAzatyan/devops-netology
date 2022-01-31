## Задание 1
Скриншот веб-интерфейса grafana со списком подключенных Datasource:
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/grafana.jpg)

## Задание 2
**Promql запросы для выдачи метрик**

- Утилизация CPU в процентах:   
`100 - (avg by (instance) (rate(node_cpu_seconds_total{job="nodeexporter",mode="idle"}[1m])) * 100)`

- Количество свободной оперативной памяти:   
`node_memory_MemFree_bytes`

- Количество места на файловой системе:   
`node_filesystem_free_bytes{device="/dev/vda2", fstype="xfs", instance="nodeexporter:9100", job="nodeexporter", mountpoint="/"}`

- CPULA 1/5/15   
```
node_load1{instance="nodeexporter:9100",job="nodeexporter"}
node_load5{instance="nodeexporter:9100",job="nodeexporter"}
node_load15{instance="nodeexporter:9100",job="nodeexporter"}
```

Скриншот получившейся Dashboard:
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/dashboard.jpg)


## Задание 3
Алерты выставляются только для пары графиков, для остальных видов визуализации они оказались недоступны.
Пришлось по этой причине переделать вид некоторых панелей. Чтобы все не было совсем одинаковым, оставил хотя бы CPU в виде спидометра.
Алерт для памяти очень маленький, его не видно (выставлен алерт при 1 свободном гигабайте).

Скриншот  итоговой Dashboard:
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/grafana2.jpg)


## Задание 4
Здесь причведен [JSON Dashboard-а](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/dashboard.json).


