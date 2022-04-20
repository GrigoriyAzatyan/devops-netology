# 1. Настройка политик

## Разверываем echoserver, публикуем на порту 8080  

```
kubectl create namespace ingress-nginx
kubectl create deployment echoserver --image=bluebrown/echoserver --namespace=ingress-nginx
kubectl expose deployment echoserver --type=ClusterIP --port=8080 --namespace=ingress-nginx
```

## Проверяем доступ с соседнего пода

`root@cp1:/home/user/policies# kubectl run --rm -it --image=alpine test-$RANDOM -- sh`

```
If you don't see a command prompt, try pressing enter.
/ # wget -qO- http://echoserver:8080
wget: bad address 'echoserver:8080'
/ # wget -qO- http://10.12.0.86:8080
OS HOSTNAME: echoserver-86cd9cfc59-w7gpm

GET / HTTP/1.1
Host: 10.12.0.86:8080
Connection: close
Connection: close
User-Agent: Wget
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
  






















