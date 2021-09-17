# Задача 1

Используя docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

```
FROM ubuntu:focal-20210827  
ENV TZ=Asia/Yekaterinburg  
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone  
RUN yes | apt update && yes | apt install mysql-server mysql-client
EXPOSE 3306
ENTRYPOINT  /bin/sh
```

```
docker volume create mysql_data
docker run -dt --name mysql -v mysql_data:/var/lib/mysql -v /docker/mysql/backup:/backup -p 3306:3306 mysql:latest
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него:

```
mysql -uroot  
CREATE DATABASE test_db;  
\q  
mysql test_db < /backup/test_dump.sql  
```

Перейдите в управляющую консоль `mysql` внутри контейнера.  
Используя команду `\h` получите список управляющих команд.  
Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД:   

```
mysql> \s
--------------
mysql  Ver 8.0.26-0ubuntu0.20.04.2 for Linux on x86_64 ((Ubuntu))

Connection id:          15
Current database:       test_db
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.26-0ubuntu0.20.04.2 (Ubuntu)
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 3 min 52 sec
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД:  
```
mysql> use test_db;  
mysql> show tables;  
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

**Приведите в ответе** количество записей с `price` > 300:

```
mysql> select * from orders where price > 300;   
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

```
CREATE USER 'test'@'%' IDENTIFIED BY 'Pa$$w0rd'   
WITH   
MAX_QUERIES_PER_HOUR 100  
PASSWORD EXPIRE INTERVAL 180 DAY   
FAILED_LOGIN_ATTEMPTS 3  
ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';   
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`: 
```
GRANT SELECT ON test_db.* TO 'test'@'%';  
```
   
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.   
```
mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES where user = 'test';
+------+------+---------------------------------------+
| USER | HOST | ATTRIBUTE                             |
+------+------+---------------------------------------+
| test | %    | {"fname": "James", "lname": "Pretty"} |
+------+------+---------------------------------------+
1 row in set (0.00 sec)
```
Вот еще:  
```
mysql> SELECT User, max_questions, password_lifetime, User_attributes  FROM mysql.user where user='test';
+------+-------------+---------------+-------------------+-------------------------------------------------------------+
| User | max_questions | password_lifetime | User_attributes                                                                                                       
+------+-------------+---------------+-------------------+-------------------------------------------------------------+
| test |           100 |               180 | {"metadata": {"fname": "James", "lname": "Pretty"}, "Password_locking": 
                                           | {"failed_login_attempts": 3, "password_lock_time_days": 0}}               |
+------+---------------+-------------------+---------------------------------------------------------------------------+
1 row in set (0.00 sec)

```






## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**:  
```
mysql> SHOW CREATE TABLE orders;

|--------|---------------------------------------------------|
| Table  | Create Table                                      |
|--------|---------------------------------------------------|                                                           
| orders | CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(80) NOT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) 
ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`  
```
ALTER TABLE orders ENGINE=MyISAM;  
show profiles;  
+----------+------------+----------------------------------+
| Query_ID | Duration   | Query                            |
+----------+------------+----------------------------------+
|       36 | 0.01115200 | ALTER TABLE orders ENGINE=MyISAM |
+----------+------------+----------------------------------+
```
- на `InnoDB`:
```
ALTER TABLE orders ENGINE=InnoDB;   
show profiles;  
+----------+------------+----------------------------------+
| Query_ID | Duration   | Query                            |
+----------+------------+----------------------------------+
|       37 | 0.02306500 | ALTER TABLE orders ENGINE=InnoDB |
+----------+------------+----------------------------------+
```


## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
