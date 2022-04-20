# 1. Настройка политик

## Разверываем web-сервер, публикуем на порту 80  

```
kubectl run web --image=nginx --labels="app=web" --expose --port=80
```

```
NAME   TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
web    ClusterIP   10.12.0.211   <none>        80/TCP    142m

```

## Создаем два пода

```
kubectl run -i -t --image=alpine test1 
kubectl run -i -t --image=alpine test2 
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

## Создаем запрещающую политику по умолчанию

nano web-deny-all.yaml

```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-deny-all
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```
 
`kubectl apply -f web-deny-all.yaml`  
`networkpolicy.networking.k8s.io/web-deny-all created`


## Проверяем доступ, вернее его отсутствие

`kubectl attach test1 -c test1 -i -t`

```
/ # wget -qO- --timeout=2 http://web

wget: download timed out
```

## Создаем разрешающую политику пода test1

`nano allow-to-web.yaml`

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-to-web
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            run: test1

 ``` 

`kubectl apply -f allow-to-web.yaml`

## Проверяем доступ для пода test1

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


## Проверяем доступ для пода test2

`kubectl attach test2 -c test2 -i -t`

```
/ # wget -qO- --timeout=2 http://web
wget: bad address 'web'

/ # wget -qO- --timeout=2 http://10.12.0.211
wget: download timed out
```















