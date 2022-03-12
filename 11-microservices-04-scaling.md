## Kubernetes 
- Наиболее распространенное и популярное средство оркестрации контейнеров;
- Обладает собственным функционалом обнаружения сервисов;
- Возможности горизонтального и вертикального масштабирования.
- Kubernetes позволяет программно управлять релизами на серверах под своим управлением:
    - накатить релиз одной кнопкой;
    - быстро откатить релиз;
    - сделать a/b тестирование;
    - выкатывать постепенно (по процентам), следя за показателями мониторинга, чтобы быстро обнаружить возможные ошибки в новой версии;
    - автоматически увеличить или уменьшить размер кластера, то есть добавить или убрать ноды в зависимости от нагрузки;
    - следить, чтобы было ровно заданное количество инстансов приложения, например — быстро доводить их до нужного числа при потере части инстансов из-за какого-либо сбоя.
- Отказоустойчивость приложений за счет автоматического распределения нагрузки на физические серверы;
- Автоматизация процессов: приложения в k8s выкатываются и тестируются без участия администраторов. РВ иделале вся операционная поддержка работы софта лежит на плечах программистов, а администраторы следят, чтобы стабильно работал слой облачной инфраструктуры — то есть, сам Kubernetes.


## GitLab CI
- Собственное хранилище репозиториев и Docker Registry.
- Подробная документация и простое управление.
- Удобный пользовательский интерфейс для наблюдения за результатами тестирования.
- Можно дать права на чтение и изменение как отдельным людям, так и группе пользователей.
- Легкое назначение контрольных точек проекта и их группировка по задачам.
- Удобное параллельное тестирование pull requests и веток, что делает его хорошим выбором для opensource-проектов.
- Вообще в Gitlab есть [инструмент хранения паролей в хешированном виде](https://docs.gitlab.com/ee/security/password_storage.html) Но наверное, все же надежнее доверить эту функцию специализированному приложению - Hashicorp Vault, учитывая, что к конфиденциальным данным относятся не только пароли, но и другие данные (SSH-ключи, токены и др.). [См. пример такой   настройки.](https://www.dmosk.ru/miniinstruktions.php?mini=gitlab-hashicorp-vault)


## Hashicorp Vault
- Все данные хранятся в зашифрованном контейнере. Получение самого контейнера не раскрывает данные.
- Гибкие политики доступа. Вы можете создать столько токенов для доступа и управления секретами, сколько вам нужно. И дать им те разрешения, которые необходимы и достаточны для выполнения работ.
- Возможность аудирования доступа к секретам. Каждый запрос к Vault будет записан в лог для последующего аудита.
- Поддерживается автоматическая генерация секретов для нескольких популярных баз данных (postgresql, mysql, mssql, cassandra), для rabbitmq, ssh и для aws.
- Поддержка шифрования-дешифрования данных без их сохранения. Это может быть удобно для передачи данных в зашифрованном виде по незащищённым каналам связи.
- Поддержка полного жизненного цикла секрета: создание/отзыв/завершение срока хранения/продление.
- Возможность создания собственного CA (Certificate Authority) для управления самоподписанными сертификатами внутри своей инфраструктуры.
- Бэкенд Cubbyhole позволяет создать собственное хранилище секретов, не доступное даже другим root-токенам.
- Готовые модули и плагины для популярных систем управления конфигурацией.