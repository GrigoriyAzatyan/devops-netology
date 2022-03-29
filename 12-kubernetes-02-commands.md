## Задание 1: Запуск пода из образа в деплойменте

```
root@minikube:/etc/kubernetes# kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-node         2/2     2            2           10d
httpd-deployment   1/1     1            1           4d
```

```
root@minikube:/etc/kubernetes# kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-cd6lh         1/1     Running   0          31s
hello-node-6b89d599b9-fsttx         1/1     Running   0          10d
httpd-deployment-856fbf5ffd-rjtd7   1/1     Running   0          4d
```

## Задание 2: Просмотр логов для разработки



## Задание 3: Изменение количества реплик

```
root@minikube:/etc/kubernetes# kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-node         5/5     5            5           10d
httpd-deployment   1/1     1            1           4d
```
```
root@minikube:/etc/kubernetes# kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-2lqpk         1/1     Running   0          7s
hello-node-6b89d599b9-4vs8k         1/1     Running   0          7s
hello-node-6b89d599b9-cd6lh         1/1     Running   0          3m32s
hello-node-6b89d599b9-fsttx         1/1     Running   0          10d
hello-node-6b89d599b9-l5km6         1/1     Running   0          7s
httpd-deployment-856fbf5ffd-rjtd7   1/1     Running   0          4d
```
