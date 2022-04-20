# 1. Настройка политик

## Разверываем echoserver, публикуем на порту 8080  

```
kubectl create deployment echoserver --image=bluebrown/echoserver
kubectl expose deployment echoserver --type=ClusterIP --port=8080
```

```
kubectl get service echoserver
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
echoserver   ClusterIP   10.12.0.86   <none>        8080/TCP   36m
```


## Проверяем доступ с соседнего пода

`kubectl run --rm -it --image=alpine test-$RANDOM -- sh`

```
If you don't see a command prompt, try pressing enter.

/ # wget -qO- http://10.12.0.86:8080
OS HOSTNAME: echoserver-86cd9cfc59-w7gpm

GET / HTTP/1.1
Host: 10.12.0.86:8080
Connection: close
Connection: close
User-Agent: Wget
```

## Создаем запрещающую политику по умолчанию

nano default.yml

```

```


`kubectl apply -f default.yml`
`networkpolicy.networking.k8s.io/default-deny-ingress created`








```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-echoserver
  namespace: ingress-nginx
spec:
  podSelector: 
    matchLabels:
      app: echoserver
  policyTypes:
    - Ingress
  ingress: 
    - {}
 ``` 






















