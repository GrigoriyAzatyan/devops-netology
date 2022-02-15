# Задание 1

**Примечание**: я использовал директорию help, но конфигурация из нее оказалась нерабочей. Пришлось переделать как docker-compose.yml, так и конфиги сервисов.

## Скриншот docker ps через 5 минут после старта всех контейнеров (их должно быть 5)
Привожу вывод из консоли:  
```
# docker ps

CONTAINER ID   IMAGE                                                  COMMAND                  CREATED         STATUS         PORTS                                                           NAMES
170f549a0799   docker.elastic.co/kibana/kibana:7.11.0                 "/bin/tini -- /usr/l…"   9 minutes ago   Up 9 minutes   0.0.0.0:5601->5601/tcp, :::5601->5601/tcp                       kibana
60fe8aa4d456   docker.elastic.co/logstash/logstash:6.3.2              "/usr/local/bin/dock…"   9 minutes ago   Up 9 minutes   5044/tcp, 9600/tcp, 0.0.0.0:5046->5046/tcp, :::5046->5046/tcp   logstash
88b3cb008ac2   docker.elastic.co/elasticsearch/elasticsearch:7.11.0   "/bin/tini -- /usr/l…"   9 minutes ago   Up 9 minutes   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 9300/tcp             es-hot
b3af0e4733e4   docker.elastic.co/elasticsearch/elasticsearch:7.11.0   "/bin/tini -- /usr/l…"   9 minutes ago   Up 9 minutes   9200/tcp, 9300/tcp                                              es-warm
d0bb46d55756   python:3.9-alpine                                      "python3 /opt/run.py"    9 minutes ago   Up 9 minutes                                                                   some_app

```

## Скриншот интерфейса kibana
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/Kibana1.jpg)

## docker-compose манифест (если вы не использовали директорию help)
https://github.com/GrigoriyAzatyan/devops-netology/blob/main/ELK_docker_compose.yml

## Ваши yml конфигурации для стека (если вы не использовали директорию help)
https://github.com/GrigoriyAzatyan/devops-netology/blob/main/logstash.yml  
https://github.com/GrigoriyAzatyan/devops-netology/blob/main/logstash.conf  
https://github.com/GrigoriyAzatyan/devops-netology/blob/main/filebeat.yml  

# Задание 2
ELK доступна [по этому адресу](http://84.201.159.251:5601).

Скриншот:  
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/ELK.jpg)
