# Задача 1

Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).

Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её 
нужно прервать. 

Вы как инженер поддержки решили произвести данную операцию.

## Ответ

**Напишите список операций, которые вы будете производить для остановки запроса пользователя**  

```
db.currentOp().inprog.forEach(
  function(op) {
    if(op.secs_running > 60) printjson(op);
  }
)
```
В ответ получим ID выявленного запроса, например: `"opid": 1349152`.

Далее - убиваем запрос: `db.killOp(1349152)`


   

**Предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB**  

Причина 1. Проблемы с производительностью могут указывать на то, что база данных работает на пределе возможностей и что пришло время добавить в базу данных дополнительную емкость. В частности, рабочий набор приложения должен помещаться в доступной физической памяти.  

Причина 2. Неоптимальный код в запросах, вызывающий долгое выполнение. 

Что нужно сделать:  

- Исследовать утилизацию ресурсов сервера. 
- Исследовать производительность кластера с помощью облачного мониторинга Free Monitoring;
- Выявить с помощью db.currentOp() наиболее проблемные запросы и найти способ оптимизации их кода с целью снижения нагрузки на систему.


# Задача 2

Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).

Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL. 
Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и
увеличивается пропорционально количеству реплик сервиса. 

При масштабировании сервиса до N реплик вы увидели, что:
- сначала рост отношения записанных значений к истекшим
- Redis блокирует операции записи

Как вы думаете, в чем может быть проблема?

## Ответ
В документации насчет этого есть такой фрагмент:  
```
The active expiring is designed to be adaptive. An expire cycle is started every 100 milliseconds (10 times per second), and will do the following:

- Sample ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP keys, evicting all the keys already expired.
- If the more than 25% of the keys were found expired, repeat.

Given that ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP is set to 20 by default, and the process is performed ten times per second, usually just 200 keys per second are actively expired. This is enough to clean the DB fast enough even when already expired keys are not accessed for a long time, so that the lazy algorithm does not help. At the same time expiring just 200 keys per second has no effects in the latency a Redis instance.

However the algorithm is adaptive and will loop if it finds more than 25% of keys already expired in the set of sampled keys. But given that we run the algorithm ten times per second, this means that the unlucky event of more than 25% of the keys in our random sample are expiring at least in the same second.

Basically this means that if the database has many many keys expiring in the same second, and these make up at least 25% of the current population of keys with an expire set, Redis can block in order to get the percentage of keys already expired below 25%.

This approach is needed in order to avoid using too much memory for keys that are already expired, and usually is absolutely harmless since it's strange that a big number of keys are going to expire in the same exact second, but it is not impossible that the user used EXPIREAT extensively with the same Unix time.

In short: be aware that many keys expiring at the same moment can be a source of latency.
```

То есть, если в базе данных много ключей, срок действия которых истекает в одну секунду, и они составляют не менее 25% от текущей совокупности ключей с истекающим сроком, Redis может применить блокировки, чтобы получить процент уже истекших ключей ниже 25%.

Таким образом, большое количество ключей, истекающиих в один и тот же момент, может быть источником задержки.



# Задача 3

Перед выполнением задания познакомьтесь с документацией по [Common Mysql errors](https://dev.mysql.com/doc/refman/8.0/en/common-errors.html).

Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
пользователи начали жаловаться на ошибки вида:
```python
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```
  
## Ответ

- **Как вы думаете, почему это начало происходить и как локализовать проблему?**  
Возможно, запрос затронул огромное число строк, так что его выполнение оборвалось по таймауту.   

- **Какие пути решения данной проблемы вы можете предложить?**  
Увеличить значение системной переменной net_read_timeout.  
Возможно, шардирование и использование индексов поможет ускорить работу запросов.  


# Задача 4

Перед выполнением задания ознакомтесь со статьей [Common PostgreSQL errors](https://www.percona.com/blog/2020/06/05/10-common-postgresql-errors/) из блога Percona.

Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с большим объемом данных лучше, чем MySQL.
После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:

`postmaster invoked oom-killer`

Как вы думаете, что происходит? Как бы вы решили данную проблему?

## Ответы

Происходит это из-за нехватки доступной памяти на сервере.

Решение:   
- Попытаться меньшить в конфиге postgresql.conf значения, влияющие на потребляемую сервером память: shared_buffers, work_mem, maintenance_work_mem, temp_buffers;
- Если эти действия решили проблему с oom-killer, но замедлили работу СУБД - добавить память на сервере.



