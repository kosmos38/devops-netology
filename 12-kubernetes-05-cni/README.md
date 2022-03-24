# Домашнее задание к занятию "12.5 Сетевые решения CNI"

## Задание 1: установить в кластер CNI плагин Calico
После развертывания кластера с помощью kubespray из прошлого задания, уже был установлен плагин calico
При необходимости изменить плагин, нужно править файл: inventory/cluster/group_vars/k8s_cluster/k8s_cluster.yml

```
# Choose network plugin (cilium, calico, weave or flannel. Use cni for generic cni plugin)
# Can also be set to 'cloud', which lets the cloud provider setup appropriate routing
kube_network_plugin: calico
```

Как видим из описания, kubespray даёт выбор: cilium, calico, weave or flannel
Также в директории inventory/cluster/group_vars/ имеются файлы конфигураций для каждого плагина

### Применение и проверка сетевой политики

Развернул deployments и services из шаблона:

```
root@kube-master1:/home/kosmos/devkub-homeworks/12-kubernetes-05-cni$ kubectl apply -f ./templates/main/
deployment.apps/frontend created
service/frontend created
deployment.apps/backend created
service/backend created
deployment.apps/cache created
service/cache created
```

```
root@kube-master1:/home/kosmos$ kubectl get po -o wide
NAME                       READY   STATUS    RESTARTS      AGE     IP              NODE         NOMINATED NODE   READINESS GATES
backend-7b4877445f-dpn29   1/1     Running   0             4m31s   10.233.103.10   kube-node2   <none>           <none>
cache-6df6d7d7df-dlpst     1/1     Running   0             4m31s   10.233.101.15   kube-node1   <none>           <none>
frontend-7f74b5fd7-n4q5j   1/1     Running   0             4m31s   10.233.101.14   kube-node1   <none>           <none>
nginx-6799fc88d8-75g6c     1/1     Running   3 (23h ago)   3d1h    10.233.101.13   kube-node1   <none>           <none>
nginx-6799fc88d8-7zzv7     1/1     Running   3 (23h ago)   3d1h    10.233.103.9    kube-node2   <none>           <none>
```

```
root@kube-master1:/home/kosmos$ kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
backend      ClusterIP   10.233.30.110   <none>        80/TCP    95s
cache        ClusterIP   10.233.16.63    <none>        80/TCP    94s
frontend     ClusterIP   10.233.60.102   <none>        80/TCP    96s
kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP   3d3h
```

Проверяю доступность подов внутри кластера
curl от backend до cache по имени сервиса отдает ip пода:

```
bash-5.1# curl -s cache
Praqma Network MultiTool (with NGINX) - cache-6df6d7d7df-dlpst - 10.233.101.15
```

ping по имени сервиса возвращает ip сервиса:

```
bash-5.1# ping cache
PING cache.default.svc.kosmos.local (10.233.16.63) 56(84) bytes of data.
64 bytes from cache.default.svc.kosmos.local (10.233.16.63): icmp_seq=1 ttl=64 time=0.046 ms
64 bytes from cache.default.svc.kosmos.local (10.233.16.63): icmp_seq=2 ttl=64 time=0.085 ms
```

Аналогичная ситуация происходит между другими сервисами, без применения политик.

Закрыл frontend на вход (странная ситуация, но все же )) ):

```
root@kube-master1:/home/kosmos/devkub-homeworks/12-kubernetes-05-cni$ kubectl apply -f ./templates/network-policy/10-frontend.yaml
networkpolicy.networking.k8s.io/frontend created
```

Проверил доступ к frontend из cache, curl до пода по 80 порту не отвечает:

```
root@kube-master1:/home/kosmos$ kubectl exec -it cache-6df6d7d7df-dlpst bash 
bash-5.1# curl -s frontend
bash-5.1#
```

Но ping до сервиса, проходит (так и должно быть, на то он и сервис):

```
bash-5.1# ping frontend
PING frontend.default.svc.kosmos.local (10.233.60.102) 56(84) bytes of data.
64 bytes from frontend.default.svc.kosmos.local (10.233.60.102): icmp_seq=1 ttl=64 time=0.071 ms
64 bytes from frontend.default.svc.kosmos.local (10.233.60.102): icmp_seq=2 ttl=64 time=0.072 ms
```

## Задание 2: изучить, что запущено по умолчанию

Позволяет отбражать информацию по нодам:
```
root@kube-master1:/home/kosmos$ calicoctl get nodes
NAME
kube-master1
kube-node1
kube-node2
```

Например есть такая утилита, показывает какие ноды с какими IP и в каком режиме соединения:
```
root@kube-master1:~$ calicoctl node status
Calico process is running.

IPv4 BGP status
+----------------+-------------------+-------+------------+-------------+
|  PEER ADDRESS  |     PEER TYPE     | STATE |   SINCE    |    INFO     |
+----------------+-------------------+-------+------------+-------------+
| 192.168.134.13 | node-to-node mesh | up    | 2021-10-19 | Established |
| 192.168.134.14 | node-to-node mesh | up    | 2021-10-19 | Established |
+----------------+-------------------+-------+------------+-------------+
```

Показывает существующий пул, Calico позволяет разделить пулы на меньшие по размеру блоки при желании:
```
root@kube-master1:/home/kosmos$ calicoctl get ippool
NAME           CIDR             SELECTOR
default-pool   10.233.64.0/18   all()
```

Ещё есть такая утилита, отображает количество использованных IP итд.:
```
root@kube-master1:~$ calicoctl ipam show
+----------+----------------+-----------+------------+--------------+
| GROUPING |      CIDR      | IPS TOTAL | IPS IN USE |   IPS FREE   |
+----------+----------------+-----------+------------+--------------+
| IP Pool  | 10.233.64.0/18 |     16384 | 13 (0%)    | 16371 (100%) |
+----------+----------------+-----------+------------+--------------+
```


```
root@kube-master1:/home/kosmos$ calicoctl get profile
NAME
projectcalico-default-allow
kns.default
kns.kube-node-lease
kns.kube-public
kns.kube-system
kns.kubernetes-dashboard
ksa.default.admin
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
ksa.kubernetes-dashboard.default
ksa.kubernetes-dashboard.kubernetes-dashboard
```