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

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
