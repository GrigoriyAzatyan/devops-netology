## Задание 1: Запуск пода из образа в деплойменте

### kubectl get deployment
```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-node         2/2     2            2           10d
httpd-deployment   1/1     1            1           4d
```

### kubectl get pods
```
NAME                                READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-cd6lh         1/1     Running   0          31s
hello-node-6b89d599b9-fsttx         1/1     Running   0          10d
httpd-deployment-856fbf5ffd-rjtd7   1/1     Running   0          4d
```

## Задание 2: Просмотр логов для разработки
### Выполненные команды:   
```
openssl genrsa -out jean.key 2048
openssl req -new -key jean.key -out jean.csr -subj "/CN=jean"
openssl x509 -req -in jean.csr -CA /var/lib/minikube/certs/ca.crt -CAkey /var/lib/minikube/certs/ca.key -CAcreateserial -out jean.crt -days 500
useradd -s /bin/bash jean
passwd jean
mkdir /home/jean/.certs && mv jean.* /home/jean/.certs
kubectl create namespace app-namespace
kubectl run nginx --image=nginx --namespace=app-namespace
kubectl config set-credentials jean --client-certificate=/home/jean/.certs/jean.crt --client-key=/home/jean/.certs/jean.key
kubectl config set-context jean-context --cluster=minikube --user=jean --namespace=app-namespace
```

### Конфиг пользователя jean:
```
mkdir /home/jean/.kube && nano /home/jean/.kube/config

apiVersion: v1
clusters:
- cluster:
    certificate-authority: /var/lib/minikube/certs/ca.crt
    extensions:
    - extension:
        last-update: Sun, 03 Apr 2022 09:00:50 UTC
        provider: minikube.sigs.k8s.io
        version: v1.25.2
      name: cluster_info
    server: https://10.128.0.19:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: jean
  name: jean-context
current-context: jean-context
kind: Config
preferences: {}
users:
- name: jean
  user:
    client-certificate: /home/jean/.certs/jean.crt
    client-key: /home/jean/.certs/jean.key
```

### Дальнейшие команды:
```
chown -R jean:jean /home/jean
```

### Yaml для роли:

cat ./role.yaml

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: read-pods
  namespace: app-namespace
rules:
- apiGroups: ["","extensions", "apps"]
  resources: ["pods", "pods/log"]
  verbs: ["get", "watch", "list"]
```

### Yaml для rolebinding:

cat ./role-binding.yaml

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jean
  namespace: app-namespace
subjects:
- kind: User
  name: jean
  apiGroup: ""
roleRef:
  kind: Role
  name: read-pods
  apiGroup: ""
```

### Дальнейшие команды:
```
kubectl create -f ./role.yaml
kubectl create -f ./role-binding.yaml
```


### Авторизуемся под пользователем jean:   
```
user@minikube:~$ su jean
Password:
```
### Получаем список подов в app-namespace:
```
jean@minikube:~$ kubectl get pods -n app-namespace

NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          40m
```

### Получаем логи nginx:
```
jean@minikube:~$ kubectl logs nginx -n app-namespace

/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2022/04/03 10:20:39 [notice] 1#1: using the "epoll" event method
2022/04/03 10:20:39 [notice] 1#1: nginx/1.21.6
2022/04/03 10:20:39 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
2022/04/03 10:20:39 [notice] 1#1: OS: Linux 5.4.0-96-generic
2022/04/03 10:20:39 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2022/04/03 10:20:39 [notice] 1#1: start worker processes
2022/04/03 10:20:39 [notice] 1#1: start worker process 33
2022/04/03 10:20:39 [notice] 1#1: start worker process 34
2022/04/03 10:20:39 [notice] 1#1: start worker process 35
2022/04/03 10:20:39 [notice] 1#1: start worker process 36
```

### Пробуем создать новый namespace:
```
jean@minikube:~$ kubectl create namespace 123
Error from server (Forbidden): namespaces is forbidden: User "jean" cannot create resource "namespaces" in API group "" at the cluster scope
```

### Пробуем создать новый под:
```
jean@minikube:~$ kubectl run nginx2 --image=nginx --restart=Never -n app-namespace
Error from server (Forbidden): pods is forbidden: User "jean" cannot create resource "pods" in API group "" in the namespace "app-namespace"
```

### Пробуем просмотреть поды в namespace default:
```
jean@minikube:~$ kubectl get pods -n default
Error from server (Forbidden): pods is forbidden: User "jean" cannot list resource "pods" in API group "" in the namespace "default"
```

### То же из-под основного пользователя:
```
root@minikube:/home/user# kubectl get pods -n default
NAME                                READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-2lqpk         1/1     Running   0          4d17h
hello-node-6b89d599b9-4vs8k         1/1     Running   0          4d17h
hello-node-6b89d599b9-cd6lh         1/1     Running   0          4d17h
hello-node-6b89d599b9-fsttx         1/1     Running   0          15d
hello-node-6b89d599b9-l5km6         1/1     Running   0          4d17h
httpd-deployment-856fbf5ffd-rjtd7   1/1     Running   0          8d
```


## Задание 3: Изменение количества реплик

### kubectl get deployment
```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-node         5/5     5            5           10d
httpd-deployment   1/1     1            1           4d
```
### kubectl get pods
```
NAME                                READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-2lqpk         1/1     Running   0          7s
hello-node-6b89d599b9-4vs8k         1/1     Running   0          7s
hello-node-6b89d599b9-cd6lh         1/1     Running   0          3m32s
hello-node-6b89d599b9-fsttx         1/1     Running   0          10d
hello-node-6b89d599b9-l5km6         1/1     Running   0          7s
httpd-deployment-856fbf5ffd-rjtd7   1/1     Running   0          4d
```
