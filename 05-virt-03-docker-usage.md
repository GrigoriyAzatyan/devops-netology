## Задача 1 

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование докера? Или лучше подойдет виртуальная машина, физическая машина? Или возможны разные варианты?"

--

Сценарий:

- **Высоконагруженное монолитное java веб-приложение** - лучше на виртуальной машине. Максимум ресурсов вытягивать из железа здесь не обязательно, поэтому виртуализация даст такие плюсы, как легшкое масштабирование выделенных ресурсов, переносимость и восстановление на другом хосте, когда это понадобится.   
- **Go-микросервис для генерации отчетов** - микросервис сам просит упаковать его в контейнер.  
- **Nodejs веб-приложение** - контейнер. Таких однотипных приложений можно запустить много на одном хосте, большие ресурсы им не нужны.  
- **Мобильное приложение c версиями для Android и iOS** - я бы лучше выделил виртуальную машину. Приложение одно, по сути монолит. Изменяется нагрузка по клиентским подключениям - значит, нужно менять выделенные ресурсы. 
- **База данных postgresql используемая, как кэш** - физический сервер, нужно максимум ресурсов и быстрый отклик.  
- **Шина данных на базе Apache Kafka** - Kafka строится из множества узлов, поэтому быстрое их развертывание из контейнеров является наиболее приемлемым вариантом.
- **Очередь для Logstash на базе Redis** - на оф.сайте есть как инсталляторы, так и Docker-образ. Так что можно и установить начисто в виртуальную машину, лиюо развернуть из образа. Если делать таких сервисов много, то удобнее разворачивать их в контейнерах.  
- **Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana** - все эти сервисы можно быстро развернуть в контейнерах, есть официальные Docker-образы.  
- **Мониторинг-стек на базе prometheus и grafana** - контейнер. Таких однотипных приложений можно запустить много на одном хосте, большие ресурсы им не нужны.  
- **Mongodb, как основное хранилище данных для java-приложения** - Mongodb прекрасно работает в контейнере. Можно java-приложение развернуть в соседнем контейнере, они будут обмениваться данными через сетевой порт.
- **Jenkins-сервер** - Jenkins можно установить в контейнере. Есть официальный Docker-образ.

## Задача 2 

docker pull gregory78/netology:latest    
https://hub.docker.com/repository/docker/gregory78/netology  

## Задача 3 

- Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /share/info контейнера;
- Запустите второй контейнер из образа debian:latest в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /info контейнера;
- Подключитесь к первому контейнеру с помощью exec и создайте текстовый файл любого содержания в /share/info ;
- Добавьте еще один файл в папку info на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /info контейнера.

---

### Что сделано:  

    docker pull centos:latest  
    docker run --name centos -v /docker/info:/share/info -td 300e315adb2f  
    
    docker pull debian:latest  
    docker run --name debian -v /docker/info:/info -td 82bd5ee7b1c5
    
    docker exec -it centos bash
    echo `cat /etc/redhat-release` > /share/info/from_centos.txt  
    exit  
    
    echo `hostnamectl` > /docker/info/from_host.txt  
    
    docker exec -it debian bash  
    ls -l /info
    
    total 8  
    -rw-r--r-- 1 root root 262 Sep  6 18:46 from_host.txt  
    -rw-r--r-- 1 root root  30 Sep  6 18:45 from_centos.txt 
