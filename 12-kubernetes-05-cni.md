# 1. Настройка политик

## Разверываем echoserver, публикуем на порту 8080  

```
kubectl create deployment echoserver --image=bluebrown/echoserver
kubectl expose deployment echoserver --type=ClusterIP --port=80
```

```
kubectl get service echoserver
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
echoserver   ClusterIP   10.12.0.111   <none>        80/TCP    8s

```

## Создаем два пода, один маркируем меткой access=true

```
kubectl run -i -t --image=alpine test1 
kubectl run -i -t --image=alpine test2 
kubectl label pod test2 access=true
```

## Проверяем, что по умолчанию все работает

`kubectl attach test1 -c test1 -i -t`


`/ # wget -qO- --timeout=2 http://web`

```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
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






















