## 1. Настройка проброса портов

```
kubectl create ingress front-13.3 --class=nginx --rule=cp1.cluster.local/*=frontend-svc:8000
kubectl create ingress back-13.3 --class=nginx --rule=cp1.cluster.local/*=backend-svc:9000
kubectl port-forward service/frontend-svc 80:8000 --address=0.0.0.0 &
kubectl port-forward service/backend-svc 81:9000 --address=0.0.0.0 &
kubectl port-forward service/postgresql-svc 5432:5432 --address=0.0.0.0 &
```

## 1.1. Frontend

* Port-forward

`curl http://192.168.1.106`

```
Handling connection for 80
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>

* Exec
`kubectl exec -it frontend-645767c6-sc8fd -c frontend -- curl http://backend-svc:9000`

```
{"detail":"Not Found"}
```


## 1.2. Backend

* Port-forward

`curl http://192.168.1.106:81`

```
Handling connection for 81
{"detail":"Not Found"}
```

* Exec

```
kubectl exec -it backend-db8847ff5-ckjpf -c backend -- sh -c 'apt-get -y install postgresql-client && psql news -h postgresql-svc -U postgres -c "select id from public.news limit 10"'
```

```
Get:1 http://deb.debian.org/debian buster/main amd64 distro-info-data all 0.41+deb10u4 [6880 B]
...
(Reading database ... 24671 files and directories currently installed.)
...
Setting up postgresql-client (11+200+deb10u4) ...
...
Password for user postgres:
 id
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)
```



## 1.3. PostgreSQL

* Port-forward

`psql news -U postgres -h 192.168.1.106 -c "select id from public.news limit 10"`

```
Password for user postgres:
 id
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)
```


* Exec

`kubectl exec -it postgresql-sts-0 -c postgresql -- sh -c 'psql news -U postgres -c "select id from public.news limit 10"'`

```
Password for user postgres:
 id
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
(10 rows)
```
