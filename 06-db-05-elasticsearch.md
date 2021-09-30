# Задача 1

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

## Ответ
- текст Dockerfile манифеста
```
FROM centos:centos7.9.2009
WORKDIR /usr/src/elasticsearch
RUN yum -y install wget sudo perl-Digest-SHA && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-linux-x86_64.tar.gz && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-linux-x86_64.tar.gz.sha512 && shasum -a 512 -c elasticsearch-oss-7.10.2-linux-x86_64.tar.gz.sha512 && tar -xzf elasticsearch-oss-7.10.2-linux-x86_64.tar.gz
RUN /bin/sh -c 'mkdir /var/lib/elasticsearch && mkdir /var/lib/elasticsearch/logs && mkdir /var/lib/elasticsearch/data && useradd -s /sbin/nologin elastic'
RUN /bin/sh -c 'rm -f /usr/src/elasticsearch/elasticsearch-7.10.2/config/elasticsearch.yml'
COPY ./elasticsearch.yml /usr/src/elasticsearch/elasticsearch-7.10.2/config
RUN /bin/sh -c 'chown -R elastic /usr/src/elasticsearch/elasticsearch-7.10.2 && chown -R elastic /var/lib/elasticsearch'
EXPOSE 9200
EXPOSE 9300
ENTRYPOINT sudo -u elastic /usr/src/elasticsearch/elasticsearch-7.10.2/bin/elasticsearch
```

- ссылку на образ в репозитории dockerhub  
https://hub.docker.com/repository/docker/gregory78/elasticsearch

- ответ `elasticsearch` на запрос пути `/` в json виде  

![Скриншот](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/GET.jpg)

### Примечание
Также для запуска контейнера пришлось применить следующую команду:  `sysctl -w vm.max_map_count=262144`

# Задача 2

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

## Добавление индексов:  
```
curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}' http://localhost:9200/ind-1
curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 2, "number_of_replicas": 1}}}' http://localhost:9200/ind-2
curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 4, "number_of_replicas": 2}}}' http://localhost:9200/ind-3
```

## Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.  

```
curl http://localhost:9200/_cat/indices  

green  open ind-1 DPKEoEAlT-ayiG4knJaL0w 1 0 0 0 208b 208b
yellow open ind-3 7TaCyURsQJmEC5ybCao8bg 4 2 0 0 832b 832b
yellow open ind-2 A9Q8jr6hQqmDZPBARGr37g 2 1 0 0 416b 416b

```

## Получите состояние кластера elasticsearch, используя API.

```
curl http://localhost:9200/_cluster/health

{
"cluster_name": "netology",
"status": "yellow",
"timed_out": false,
"number_of_nodes": 1,
"number_of_data_nodes": 1,
"active_primary_shards": 7,
"active_shards": 7,
"relocating_shards": 0,
"initializing_shards": 0,
"unassigned_shards": 10,
"delayed_unassigned_shards": 0,
"number_of_pending_tasks": 0,
"number_of_in_flight_fetch": 0,
"task_max_waiting_in_queue_millis": 0,
"active_shards_percent_as_number": 41.17647058823529
}
```

## Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?  
Потому что в кластере всего один узел, а мы насоздавали реплики для индексов, и привязать их некуда.   

## Удалите все индексы.
Кластер облегченно вздохнул:  
```
curl -X DELETE http://localhost:9200/ind-{1..3} 

{"acknowledged":true}
{"acknowledged":true}
{"acknowledged":true}
```

# Задача 3

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.   
Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.  

## Приведите в ответе запрос API и результат вызова API для создания репозитория.  

```
curl -X PUT -H "Content-Type:application/json" -d '{"type": "fs", "settings": {"location": "/usr/src/elasticsearch/elasticsearch-7.10.2/snapshots"}}' http://localhost:9200/_snapshot/netology_backup

{"acknowledged":true}
```

```
curl http://localhost:9200/_snapshot/netology_backup

{
  "netology_backup": {
    "type": "fs",
    "settings": {
      "location": "/usr/src/elasticsearch/elasticsearch-7.10.2/snapshots"
    }
  }
}
```


## Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```
curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}' http://localhost:9200/test

{"acknowledged":true,"shards_acknowledged":true,"index":"test"}
```

## Создайте snapshot состояния кластера `elasticsearch`.
```
curl -X PUT -H "Content-Type:application/json" http://localhost:9200/_snapshot/netology_backup/snapshot_1?wait_for_completion=true

{
  "snapshot": {
    "snapshot": "snapshot_1",
    "uuid": "TdQTCV2iTE2yfoL0fbBx3g",
    "version_id": 7100299,
    "version": "7.10.2",
    "indices": [
      "test"
    ],
    "data_streams": [],
    "include_global_state": true,
    "state": "SUCCESS",
    "start_time": "2021-09-30T16:40:30.920Z",
    "start_time_in_millis": 1633020030920,
    "end_time": "2021-09-30T16:40:30.920Z",
    "end_time_in_millis": 1633020030920,
    "duration_in_millis": 0,
    "failures": [],
    "shards": {
      "total": 1,
      "failed": 0,
      "successful": 1
    }
  }
}

```

## Приведите в ответе список файлов в директории со snapshotами.

```
ls -l /usr/src/elasticsearch/elasticsearch-7.10.2/snapshots/
total 20
-rw-r--r-- 1 elastic elastic  434 Sep 30 16:40 index-0
-rw-r--r-- 1 elastic elastic    8 Sep 30 16:40 index.latest
drwxr-xr-x 3 elastic elastic 4096 Sep 30 16:40 indices
-rw-r--r-- 1 elastic elastic  299 Sep 30 16:40 meta-TdQTCV2iTE2yfoL0fbBx3g.dat
-rw-r--r-- 1 elastic elastic  266 Sep 30 16:40 snap-TdQTCV2iTE2yfoL0fbBx3g.dat
```

## Удалите индекс test и создайте индекс test-2. Приведите в ответе список индексов.

```
curl -X DELETE http://localhost:9200/test
{"acknowledged":true}

curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}' http://localhost:9200/test-2
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}

curl http://localhost:9200/_cat/indices
green open test-2 XHrn3FsrQ_epPdQHCT_6hA 1 0 0 0 208b 208b
```

## Восстановите состояние кластера elasticsearch из snapshot, созданного ранее. Приведите в ответе запрос к API восстановления и итоговый список индексов.

```
curl -X POST http://localhost:9200/_snapshot/netology_backup/snapshot_1/_restore
{"accepted":true}

curl http://localhost:9200/_cat/indices
green open test-2 XHrn3FsrQ_epPdQHCT_6hA 1 0 0 0 208b 208b
green open test   rymNrEb6REWzbLTGMydikw 1 0 0 0 208b 208b
```

