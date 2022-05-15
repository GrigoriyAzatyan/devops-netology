# Задание 1

`kubectl exec -i -t apache-stage-57bc686965-npdvl -c backend -- sh -c "echo 444 > /static/file4"`

![Результат](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/13-kubernetes-config-02-mounts/stage.jpg)

# Задание 2

`kubectl exec -i -t prod-depl-backend-9f669dc47-7bftn -c backend -- sh -c "echo 22222 > /static/file02"`

![Результат](https://github.com/GrigoriyAzatyan/devops-netology/blob/main/13-kubernetes-config-02-mounts/prod.jpg)
