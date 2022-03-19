# 1. Установка minikube и Docker:
```
sudo sysctl fs.protected_regular=0
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo apt-get update && sudo apt-get install docker.io conntrack -y
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
minikube delete
minikube start --vm-driver=none
```
```
root@minikube:/home/user# minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

## Установка дополнений, Запуск Dashboard

```
minikube addons list
minikube addons enable ingress
minikube dashboard --url=false &
kubectl proxy --port=8081 --disable-filter=true --address=0.0.0.0 &
```

В результате интерфейс Dashboard доступен по адресу: 
http://51.250.1.82:8081/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/workloads?namespace=default

# 2. Запуск Hello World
```
kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
```

```
kubectl get deployments

NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           24m
```

```
kubectl get pods

NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-fsttx   1/1     Running   0          24m
```

```
apt-get -y install socat
kubectl expose deployment hello-node --type=LoadBalancer --port=8080
kubectl port-forward hello-node-6b89d599b9-fsttx 8082:8080 --address=0.0.0.0 &
```

## Результат:   
http://51.250.1.82:8082/



# 3. Установка cubectl

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.5", GitCommit:"c285e781331a3785a7f436042c65c5641ce8a9e9", GitTreeState:"clean", BuildDate:"2022-03-16T15:58:47Z", GoVersion:"go1.17.8", Compiler:"gc", Platform:"linux/amd64"}
```

```
curl http://51.250.1.82:8082/


CLIENT VALUES:
client_address=127.0.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://51.250.1.82:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=51.250.1.82:8082
user-agent=curl/7.68.0
BODY:
```

