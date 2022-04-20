# Задание 1

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

# Задание 2

## Установка calicoctl

```
curl -L https://github.com/projectcalico/calico/releases/download/v3.22.2/calicoctl-linux-arm64 -o kubectl-calico
chmod +x kubectl-calico
mv kubectl-calico /usr/local/bin
```

## Список нод

```
calicoctl get nodes -o wide

NAME    ASN       IPV4               IPV6
cp1     (64512)   192.168.1.106/24
node1   (64512)   192.168.1.104/24
node2   (64512)   192.168.1.103/24
```

## IPPool

```
calicoctl get ippool -o wide
NAME           CIDR            NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR
default-pool   10.244.0.0/24   true   Never      Always      false      false              all()
```


## Profile

```
calicoctl get profile
NAME
projectcalico-default-allow
kns.default
kns.kube-node-lease
kns.kube-public
kns.kube-system
ksa.default.default
ksa.kube-node-lease.default
ksa.kube-public.default
ksa.kube-system.attachdetach-controller
ksa.kube-system.bootstrap-signer
ksa.kube-system.calico-kube-controllers
ksa.kube-system.calico-node
ksa.kube-system.certificate-controller
ksa.kube-system.clusterrole-aggregation-controller
ksa.kube-system.coredns
ksa.kube-system.cronjob-controller
ksa.kube-system.daemon-set-controller
ksa.kube-system.default
ksa.kube-system.deployment-controller
ksa.kube-system.disruption-controller
ksa.kube-system.dns-autoscaler
ksa.kube-system.endpoint-controller
ksa.kube-system.endpointslice-controller
ksa.kube-system.endpointslicemirroring-controller
ksa.kube-system.ephemeral-volume-controller
ksa.kube-system.expand-controller
ksa.kube-system.generic-garbage-collector
ksa.kube-system.horizontal-pod-autoscaler
ksa.kube-system.job-controller
ksa.kube-system.kube-proxy
ksa.kube-system.namespace-controller
ksa.kube-system.node-controller
ksa.kube-system.nodelocaldns
ksa.kube-system.persistent-volume-binder
ksa.kube-system.pod-garbage-collector
ksa.kube-system.pv-protection-controller
ksa.kube-system.pvc-protection-controller
ksa.kube-system.replicaset-controller
ksa.kube-system.replication-controller
ksa.kube-system.resourcequota-controller
ksa.kube-system.root-ca-cert-publisher
ksa.kube-system.service-account-controller
ksa.kube-system.service-controller
ksa.kube-system.statefulset-controller
ksa.kube-system.token-cleaner
ksa.kube-system.ttl-after-finished-controller
ksa.kube-system.ttl-controller
```



