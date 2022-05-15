# Задание 1
[Манифесты по заданию 1](https://github.com/GrigoriyAzatyan/devops-netology/tree/main/13-kubernetes-config-02-mounts/Task_1_(stage))

### Проверка работы:
`kubectl exec -i -t apache-stage-57bc686965-npdvl -c backend -- sh -c "echo 444 > /static/file4"`

### Результат:   
![Результат](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/13-kubernetes-config-02-mounts/stage.jpg)

# Задание 2
[Манифесты по заданию 2](https://github.com/GrigoriyAzatyan/devops-netology/tree/main/13-kubernetes-config-02-mounts/Task_2_(prod))

### Проверка работы:  
`kubectl exec -i -t prod-depl-backend-9f669dc47-7bftn -c backend -- sh -c "echo 22222 > /static/file02"`

### Результат:   
![Результат](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/13-kubernetes-config-02-mounts/prod.jpg)
