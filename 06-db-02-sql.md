# Задача 1
## Dockerfile  
```
FROM ubuntu:focal-20210827  
ENV TZ=Asia/Yekaterinburg  
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone  
RUN yes | apt update && yes | apt install postgresql postgresql-contrib
RUN mv /etc/postgresql/12/main/pg_hba.conf /etc/postgresql/12/main/pg_hba.conf.old
COPY ./pg_hba.conf /etc/postgresql/12/main
EXPOSE 5432
ENTRYPOINT  pg_ctlcluster 12 main start && /bin/sh
```
## Команды для запуска  
```
docker volume create pgsql_data
docker volume create pgsql_backup
docker run -dt --name pgsql -v pgsql_data:/var/lib/postgresql/12/main -v pgsql_backup:/var/lib/postgresql/12/backup -p 5432:5432 pgsql:latest
```



## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db:  
`CREATE USER "test-admin-user";`  
`CREATE DATABASE "test_db" OWNER=postgres;`   
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже):  
`CREATE TABLE orders(id serial PRIMARY KEY, "Наименование" character varying(100), "Цена" integer);`   
`CREATE TABLE clients(id serial PRIMARY KEY, "Фамилия" character varying(100), "Страна проживания" character varying(100), "Заказ" serial, FOREIGN KEY ("Заказ") REFERENCES orders(id));`       
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db:  
`GRANT ALL PRIVILEGES ON DATABASE "test_db" TO "test-admin-user";`   
- создайте пользователя test-simple-user:  
`CREATE USER "test-simple-user";`  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db:  
`GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";`  

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше:

|   Name    |  Owner   | Encoding | Collate |  Ctype  |       Access privileges        |  Size   | Tablespace |                Description                |
|-----------|----------|----------|---------|---------|--------------------------------|---------|------------|-------------------------------------------|
| postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |                                | 7953 kB | pg_default | default administrative connection database|
| template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres                   +| 7809 kB | pg_default | unmodifiable empty database               |
|           |          |          |         |         | postgres=CTc/postgres          |         |            |                                           |
| template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres                   +| 7953 kB | pg_default | default template for new databases        |
|           |          |          |         |         | postgres=CTc/postgres          |         |            |                                           |
| test_db   | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres                  +| 8089 kB | pg_default |                                           |
|           |          |          |         |         | postgres=CTc/postgres         +|         |            |                                           |
|           |          |          |         |         | "test-admin-user"=CTc/postgres |         |            |                                           |


- описание таблиц (describe):  

                                                      **Table "public.orders"**  

|          Column          |          Type          | Collation | Nullable |              Default              |
|--------------------------|------------------------|-----------|----------|-----------------------------------|
| id                       | integer                |           | not null | nextval('orders_id_seq'::regclass)|
|Наименование              | character varying(100) |           |          |                                   |
|Цена                      | integer                |           |          |                                   |
|Indexes:                  |"orders_pkey" PRIMARY KEY, btree (id)                                              |
|Referenced by:            | TABLE "clients" CONSTRAINT "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)|


                                                      **Table "public.clients"**  
                                                      
|              Column               |          Type          | Collation | Nullable |                    Default                    |
|-----------------------------------|------------------------|-----------|----------|-----------------------------------------------|
| id                                | integer                |           | not null | nextval('clients_id_seq'::regclass)           |
| Фамилия                           | character varying(100) |           |          |                                               |
| Страна проживания                 | character varying(100) |           |          |                                               |
| Заказ                             | integer                |           | not null | nextval('"clients_Заказ_seq"'::regclass)      |
|Indexes:                           |"clients_pkey" PRIMARY KEY, btree (id)                                                         |
|Foreign-key constraints:           |"clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)                               |


- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db:

`SELECT table_catalog, table_schema, table_name, privilege_type FROM information_schema.table_privileges WHERE grantee = 'test-simple-user' OR grantee = 'test-admin-user';`  

| table_catalog | table_schema | table_name | privilege_type|
|---------------|--------------|------------|---------------|
| test_db       | public       | orders     | INSERT|
| test_db       | public       | orders     | SELECT|
| test_db       | public       | orders     | UPDATE|
| test_db       | public       | orders     | DELETE|
| test_db       | public       | clients    | INSERT|
| test_db       | public       | clients    | SELECT|
| test_db       | public       | clients    | UPDATE|
 |test_db       | public       | clients    | DELETE|


- список пользователей с правами над таблицами test_db:

| Schema |  Name  | Type  |        Access privileges         | Column privileges | Policies|
|--------|--------|-------|----------------------------------|-------------------|----------|
| public | orders | table | postgres=arwdDxt/postgres       +|                   |     |
|        |        |       | "test-simple-user"=arwd/postgres |                   |      |
| public | clients | table | postgres=arwdDxt/postgres       +|                   |    |
|        |         |       | "test-simple-user"=arwd/postgres |                   |    |

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
