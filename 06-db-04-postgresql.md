# Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

## Dockerfile:
```
FROM ubuntu:focal-20210827  
ENV TZ=Asia/Yekaterinburg  
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone  
RUN apt -y update && apt -y install  gnupg wget lsb-release
RUN /bin/bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && apt-get update && apt-get -y install postgresql-13
RUN mv /etc/postgresql/13/main/pg_hba.conf /etc/postgresql/13/main/pg_hba.conf.old && /bin/bash -c "echo listen_addresses = \'*\' >> /etc/postgresql/13/main/postgresql.conf"
COPY ./pg_hba.conf /etc/postgresql/13/main
EXPOSE 5432
ENTRYPOINT pg_ctlcluster 13 main start && su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password 'Qwerty123';\"" && /bin/sh
```

## Запуск:
```
docker volume create pgsql-13_data
docker run -dt --name pgsql-13 -v pgsql-13_data:/var/lib/postgresql/13/main -p 5432:5432 pgsql-13v2:latest
```

**Найдите и приведите** управляющие команды для:
- вывода списка БД
```
postgres=# \l
                                Список баз данных
    Имя    | Владелец | Кодировка | LC_COLLATE | LC_CTYPE |     Права доступа
-----------+----------+-----------+------------+----------+-----------------------
 postgres  | postgres | UTF8      | C.UTF-8    | C.UTF-8  |
 template0 | postgres | UTF8      | C.UTF-8    | C.UTF-8  | =c/postgres          +
           |          |           |            |          | postgres=CTc/postgres
 template1 | postgres | UTF8      | C.UTF-8    | C.UTF-8  | =c/postgres          +
           |          |           |            |          | postgres=CTc/postgres
(3 строки)
```

 
- подключения к БД
```
postgres=# \c postgres;
SSL-соединение (протокол: TLSv1.3, шифр: TLS_AES_256_GCM_SHA384, бит: 256, сжатие: выкл.)
Вы подключены к базе данных "postgres" как пользователь "postgres".
```

- вывода списка таблиц
```
postgres=# \dt *.*
                         Список отношений
       Схема        |           Имя           |   Тип   | Владелец
--------------------+-------------------------+---------+----------
 information_schema | sql_features            | таблица | postgres
 information_schema | sql_implementation_info | таблица | postgres
 information_schema | sql_parts               | таблица | postgres
 information_schema | sql_sizing              | таблица | postgres
 pg_catalog         | pg_aggregate            | таблица | postgres
 pg_catalog         | pg_am                   | таблица | postgres
 ...
 ...
 ...
 ```

- вывода описания содержимого таблиц
```
postgres=# \d pg_namespace;
                      Таблица "pg_catalog.pg_namespace"
 Столбец  |    Тип    | Правило сортировки | Допустимость NULL | По умолчанию
----------+-----------+--------------------+-------------------+--------------
 oid      | oid       |                    | not null          |
 nspname  | name      |                    | not null          |
 nspowner | oid       |                    | not null          |
 nspacl   | aclitem[] |                    |                   |
Индексы:
    "pg_namespace_nspname_index" UNIQUE, btree (nspname)
    "pg_namespace_oid_index" UNIQUE, btree (oid)
```
Аналогично - для каждой таблицы.

- выхода из psql  
`\q`

## Задача 2

Используя psql создайте БД test_database:  
`psql -h 172.17.0.2 -U postgres -c "CREATE DATABASE "test_db" OWNER=postgres;"` 

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в test_database:  
`psql -h 172.17.0.2 -U postgres test_db < /docker/pgsql/dump.sql`

Перейдите в управляющую консоль `psql` внутри контейнера.
```
docker exec -it pgsql-13 bash
psql -U postgres
```
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```
postgres=# \c test_db
```

```
test_db=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах. **Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.
```
test_db=# select attname, avg_width from pg_stats where tablename='orders' order by avg_width desc limit 1;
 attname | avg_width
---------+-----------
 title   |        16
(1 row)

```


## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?



## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

