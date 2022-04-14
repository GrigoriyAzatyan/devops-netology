## IP-адреса нод

№ | Имя| IP
--| --|---
1 |cp1 | 192.168.1.106
2 |node1|192.168.1.104
3 |node2|192.168.1.103

## hosts.yaml

```
all:
  hosts:
    cp1:
      ansible_host: 192.168.1.106
      ansible_connection: ssh
      ansible_user: user
    node1:
      ansible_host: 192.168.1.104
      ansible_connection: ssh
      ansible_user: user
    node2:
      ansible_host: 192.168.1.103
      ansible_connection: ssh
      ansible_user: user
  children:
    kube_control_plane:
      hosts:
        cp1:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        cp1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```

## Фрагменты k8s-cluster.yml

```
kube_network_plugin: calico
container_manager: containerd
```

## Результат установки
```
ssh user@192.168.1.106
```

```
root@cp1:/home/user# kubectl version

Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.5", GitCommit:"c285e781331a3785a7f436042c65c5641ce8a9e9", GitTreeState:"clean", BuildDate:"2022-03-16T15:58:47Z", GoVersion:"go1.17.8", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.5", GitCommit:"c285e781331a3785a7f436042c65c5641ce8a9e9", GitTreeState:"clean", BuildDate:"2022-03-16T15:52:18Z", GoVersion:"go1.17.8", Compiler:"gc", Platform:"linux/amd64"}
```

```
root@cp1:/home/user# kubectl get nodes
NAME    STATUS   ROLES                  AGE     VERSION
cp1     Ready    control-plane,master   4m51s   v1.23.5
node1   Ready    <none>                 3m47s   v1.23.5
node2   Ready    <none>                 3m47s   v1.23.5
```

```
root@cp1:/home/user# kubectl get po -o wide
NAME                     READY   STATUS              RESTARTS   AGE   IP       NODE    NOMINATED NODE   READINESS GATES
nginx-7c658794b9-b7gdr   0/1     ContainerCreating   0          29s   <none>   node1   <none>           <none>
nginx-7c658794b9-fn5vr   0/1     ContainerCreating   0          29s   <none>   node2   <none>           <none>
```

## Добавляем ноды в кластер
`ansible-playbook -i inventory/mycluster/hosts.yml scale.yml -b -v`

## Окончательный результат
```
root@cp1:/home/user# kubectl get po -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP           NODE    NOMINATED NODE   READINESS GATES
nginx-7c658794b9-b7gdr   1/1     Running   0          8m43s   10.244.0.7   node1   <none>           <none>
nginx-7c658794b9-fn5vr   1/1     Running   0          8m43s   10.244.0.6   node2   <none>           <none>
```
