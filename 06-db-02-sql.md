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



# Задача 2

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

`SELECT * FROM information_schema.table_privileges WHERE grantee = 'test-simple-user' OR grantee = 'test-admin-user';`  

 |grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy|
|----------|------------------|---------------|--------------|------------|----------------|--------------|---------------|
 |postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO|
| postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES|
| postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO|
| postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO|
 |postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO|
| postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES|
| postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO|
| postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO|

- список пользователей с правами над таблицами test_db:

| Schema |  Name  | Type  |        Access privileges         | Column privileges | Policies|
|--------|--------|-------|----------------------------------|-------------------|----------|
| public | orders | table | postgres=arwdDxt/postgres       +|                   |     |
|        |        |       | "test-simple-user"=arwd/postgres |                   |      |
| public | clients | table | postgres=arwdDxt/postgres       +|                   |    |
|        |         |       | "test-simple-user"=arwd/postgres |                   |    |

* Примечание: test-admin-user здесь явно не светится, т.к. я ему дал привилегии не на таблицы, а на всю базу. На практике проверено, от имени этого юзверя любой доступ работает.  

# Задача 3

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

## SQL-запросы:   
```
INSERT INTO public.orders(id,Наименование,Цена) VALUES (0,NULL,0);
INSERT INTO public.orders(Наименование,Цена) VALUES ('Шоколад',10);
INSERT INTO public.orders(Наименование,Цена) VALUES('Принтер',3000);
INSERT INTO public.orders(Наименование,Цена) VALUES('Книга',500);
INSERT INTO public.orders(Наименование,Цена) VALUES('Монитор',7000);
INSERT INTO public.orders(Наименование,Цена) VALUES('Гитара',4000);

INSERT INTO public.clients("Фамилия", "Страна проживания", "Заказ") VALUES('Иванов Иван Иванович','USA', 0);
INSERT INTO public.clients("Фамилия", "Страна проживания", "Заказ") VALUES('Петров Петр Петрович','Canada', 0);
INSERT INTO public.clients("Фамилия", "Страна проживания", "Заказ") VALUES('Иоганн Себастьян Бах','Japan', 0);
INSERT INTO public.clients("Фамилия", "Страна проживания", "Заказ") VALUES('Ронни Джеймс Дио','Russia', 0);	
INSERT INTO public.clients("Фамилия", "Страна проживания", "Заказ") VALUES('Ritchie Blackmore','Russia', 0);		
```
* Примечание. Для того, чтобы поначалу завести пользователей, у которых еще нет заказов, я создал дополнительную строку с id 0 в public.orders, означающую "нет заказа". Пришлось, т.к. foreign key у нас NOT NULL и надо по любому туда что-то заносить. Поэтому заполнил нулями столбцы с заказом в public.clients, без этого ругалось, не давало выполнить запрос.  


Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы. Приведите в ответе запросы и результаты их выполнения.
  
`SELECT COUNT(*) FROM public.clients;`  

| count|
|------|
 |    5|
|(1 row)|

`SELECT COUNT(*) FROM public.orders;`  

| count|
|------|
 |    6|
|(1 row)|
 


# Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

## SQL-запросы для выполнения данных операций:

```
UPDATE public.clients SET "Заказ"=(SELECT id FROM public.orders WHERE "Наименование"='Книга') 
WHERE Фамилия='Иванов Иван Иванович';   
UPDATE public.clients SET "Заказ"=(SELECT id FROM public.orders WHERE "Наименование"='Монитор') 
WHERE Фамилия='Петров Петр Петрович';   
UPDATE public.clients SET "Заказ"=(SELECT id FROM public.orders WHERE "Наименование"='Гитара') 
WHERE Фамилия='Иоганн Себастьян Бах';   
```



## SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса:  
```
SELECT C."Фамилия", C."Страна проживания", O."Наименование" Товар  FROM public.clients C
INNER JOIN public.orders O ON C.Заказ=O.id
WHERE O.id != 0;
```
|             Фамилия             | Страна проживания |   Товар   |
|---------------------------------|-------------------|-----------|
 |Иванов Иван Иванович            | USA               | Книга     |
 |Петров Петр Петрович            | Canada            | Монитор   |
 |Иоганн Себастьян Бах            | Japan             | Гитара    |


# Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Ответ:  
```
EXPLAIN ANALYZE 
SELECT C."Фамилия", C."Страна проживания", O."Наименование" Товар  
FROM public.clients C 
INNER JOIN public.orders O ON C.Заказ=O.id 
WHERE O.id != 0;
```

```  
 ----------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=1.14..2.21 rows=4 width=654) (actual time=0.024..0.026 rows=3 loops=1)
   Hash Cond: (c."Заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..1.05 rows=5 width=440) (actual time=0.005..0.006 rows=5 loops=1)
   ->  Hash  (cost=1.07..1.07 rows=5 width=222) (actual time=0.009..0.010 rows=5 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Seq Scan on orders o  (cost=0.00..1.07 rows=5 width=222) (actual time=0.004..0.005 rows=5 loops=1)
               Filter: (id <> 0)
               Rows Removed by Filter: 1
 Planning Time: 0.093 ms
 Execution Time: 0.043 ms
``` 

Здесь мы видим примерно следующее:   
- Seq Scan - последовательное чтение из таблиц orders и clients;  
- Запрос по таблице clients продлился 0.005 с и прошелся по 5 строкам;  
- Hash - было выполнено соединение, данные скопировались в хэш-таблицу в памяти, время 0.010 с, 5 строк;   
- Запрос по таблице orders продлился 0.004 (или 0.005?) секунд, затронул 5 строк.  
- Планировалось выполнить весь запрос за 0.093 ms, получилась пятилетка в три года (0.043 ms).  

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
`pg_dump -U postgres -O -F p -C test_db > /var/lib/postgresql/12/backup/test_db.bak`   

Остановите контейнер с PostgreSQL (но не удаляйте volumes).
` docker stop pgsql`  

Поднимите новый пустой контейнер с PostgreSQL.
`docker run -dt --name pgsql2 -v pgsql_backup:/var/lib/postgresql/12/backup -p 5432:5432 pgsql:latest`  

Восстановите БД test_db в новом контейнере. Приведите список операций, который вы применяли для бэкапа данных и восстановления:   
```
docker exec -it pgsql2 bash  
psql -U postgres   
CREATE DATABASE "test_db" OWNER=postgres;  
\q  
psql -U postgres test_db < /var/lib/postgresql/12/backup/test_db.bak  
psql -U postgres test_db  
SELECT COUNT(*) FROM public.clients; 

| count|
|------|
 |    5|
|(1 row)|



