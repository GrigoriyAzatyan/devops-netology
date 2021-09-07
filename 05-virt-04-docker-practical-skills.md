# Задача 1 

Измените базовый образ предложенного Dockerfile на Arch Linux c сохранением его функциональности.

```text
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:vincent-c/ponysay && \
    apt-get update
 
RUN apt-get install -y ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```

### Результат   
- Написанный вами Dockerfile   
```
    FROM archlinux:latest
    RUN yes | pacman -Suy && yes | pacman -S ponysay
    ENTRYPOINT ["/usr/bin/ponysay"]
    CMD ["Hey, netology"]
```

- Скриншот вывода командной строки после запуска контейнера из вашего базового образа

![pony](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/pony.jpg)

- **Ссылка на образ в хранилище docker-hub**: 
  - https://hub.docker.com/repository/docker/gregory78/pony_archlinux/tags?page=1&ordering=last_updated
  - docker pull gregory78/pony_archlinux:latest


# Задача 2 

В данной задаче вы составите несколько разных Dockerfile для проекта Jenkins, опубликуем образ в `dockerhub.io` и посмотрим логи этих контейнеров.

## Образ 2
### Dockerfile
```
    FROM ubuntu:focal-20210827  
    ENV TZ=Asia/Yekaterinburg  
    RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone  
    RUN apt-get -y update && \  
    apt -y install default-jre && \  
    apt -y install default-jdk && \  
    apt-get -y install wget gnupg2 tini && \  
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - && \  
    sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && \  
    apt-get -y update && \  
    apt-get -y install jenkins  
    EXPOSE 8080  
    EXPOSE 50000  
    ENTRYPOINT /bin/sh -c 'service jenkins start' && /bin/sh  
```
### Скриншот работы Jenkins  
![Jenkins](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/Jenkins.jpg)

### Скриншот логов контейнера  
![logs_ver2](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/ver2_logs.jpg)

### Ссылка на Dockerhub   
https://hub.docker.com/layers/166118965/gregory78/jenkins_ubuntu/ver2/images/sha256-516cb567a9bdf9fd91ef7d07df07fc9f65feddab8e3fb98d8b3be8a443c982ad?context=repo

       
    - Спецификация первого образа:
        - Базовый образ - [amazoncorreto](https://hub.docker.com/_/amazoncorretto)
        - Присвоить образу тэг `ver1` 
    
    - Спецификация второго образа:
        - Базовый образ - [ubuntu:latest](https://hub.docker.com/_/ubuntu)
        - Присвоить образу тэг `ver2` 

- Соберите 2 образа по полученным Dockerfile
- Запустите и проверьте их работоспособность
- Опубликуйте образы в своём dockerhub.io хранилище

Для получения зачета, вам необходимо предоставить:
- Наполнения 2х Dockerfile из задания
- Скриншоты логов запущенных вами контейнеров (из командной строки)
- Скриншоты веб-интерфейса Jenkins запущенных вами контейнеров (достаточно 1 скриншота на контейнер)
- Ссылки на образы в вашем хранилище docker-hub

## Задача 3 

В данном задании вы научитесь:
- объединять контейнеры в единую сеть
- исполнять команды "изнутри" контейнера

Для выполнения задания вам нужно:
- Написать Dockerfile: 
    - Использовать образ https://hub.docker.com/_/node как базовый
    - Установить необходимые зависимые библиотеки для запуска npm приложения https://github.com/simplicitesoftware/nodejs-demo
    - Выставить у приложения (и контейнера) порт 3000 для прослушки входящих запросов  
    - Соберите образ и запустите контейнер в фоновом режиме с публикацией порта

- Запустить второй контейнер из образа ubuntu:latest 
- Создайть `docker network` и добавьте в нее оба запущенных контейнера
- Используя `docker exec` запустить командную строку контейнера `ubuntu` в интерактивном режиме
- Используя утилиту `curl` вызвать путь `/` контейнера с npm приложением  

Для получения зачета, вам необходимо предоставить:
- Наполнение Dockerfile с npm приложением
- Скриншот вывода вызова команды списка docker сетей (docker network cli)
- Скриншот вызова утилиты curl с успешным ответом
