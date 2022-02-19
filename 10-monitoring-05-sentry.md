# Задание 1

## скриншот меню Projects  
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/Sentry_projects.jpg)

## Код на Python  

```
#! /usr/bin/env python3

import sentry_sdk
sentry_sdk.init(
    "https://c63884114d9641b898b85b6764373069@o1147850.ingest.sentry.io/6219206",
    traces_sample_rate=1.0
)

if True == True:
    print("Да что же такое! Никогда ведь не было - и вот опять!")
    division_by_zero = 1 / 0
```

# Задание 2

## Скриншот Stack trace  
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/Sentry_stack_trace.jpg)

## Список событий проекта, после нажатия Resolved  
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/Sentry_events.jpg)

# Задание 3

## Cкриншот тела сообщения из оповещения на почте
![](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/Sentry_events.jpg)

