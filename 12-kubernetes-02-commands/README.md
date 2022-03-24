# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"

## Задание 1: Запуск пода из образа в деплойменте
Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2).

Создал отдельный namespace для работы приложения:

    root@centos8:/home/kosmos$ kubectl create namespace hello-node

Создал deployment в нужном namespace:
```    
root@centos8:~/.kube$ kubectl get deployment -n hello-node
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           4d22h
```
Увеличил количество реплик:

```
root@centos8:/home/kosmos$ kubectl scale --replicas=2 deployment hello-node -n hello-node
deployment.apps/hello-node scaled

root@centos8:/home/kosmos$ kubectl get po -n hello-node
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-lknlx   1/1     Running   0          4s
hello-node-7567d9fdc9-mjxrt   1/1     Running   0          4d21h

root@centos8:/home/kosmos$ kubectl get deployment -n hello-node
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           4d22h
```

## Задание 2: Просмотр логов для разработки

Создение роли RO:
```
root@centos8:/etc/kubernetes$ kubectl create serviceaccount readonlyuser -n hello-node
serviceaccount/readonlyuser created

root@centos8:/etc/kubernetes$ kubectl create clusterrole readonlyuser --verb=get --verb=list --verb=watch --resource=pods -n hello-node
clusterrole.rbac.authorization.k8s.io/readonlyuser created

root@centos8:/etc/kubernetes$ kubectl create clusterrolebinding readonlyuser --serviceaccount=hello-node:readonlyuser --clusterrole=readonlyuser -n hello-node
clusterrolebinding.rbac.authorization.k8s.io/readonlyuser created

root@centos8:/etc/kubernetes$ TOKEN=$(kubectl describe secrets -n hello-node "$(kubectl describe serviceaccount readonlyuser -n hello-node | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')

root@centos8:/etc/kubernetes$ echo $TOKEN
eyJhbGciO...

root@centos8:/etc/kubernetes$ kubectl config set-credentials developer --token=$TOKEN
User "developer" set.

root@centos8:/etc/kubernetes$ kubectl config set-context podreader --cluster=kubernetes --user=developer
Context "podreader" created.
```
Переключаю контекст:

    kubectl config use-context podreader


Проверяю права:
```
root@centos8:~/.kube$ kubectl auth can-i get pods -n hello-node
yes
root@centos8:~/.kube$ kubectl auth can-i get pods/log -n hello-node
yes
root@centos8:~/.kube$ kubectl auth can-i get pods/describe -n hello-node
yes
root@centos8:~/.kube$ kubectl auth can-i create pods -n hello-node
no
root@centos8:~/.kube$ kubectl auth can-i delete pods -n hello-node
no
```

Просмотр логов все таки не сработал, хотя kubectl auth говорил об обратном:
```
root@centos8:~/.kube$ kubectl auth can-i get pods/log -n hello-node
yes
```

Поэтому пришлось добавить ещё pods/log:
```
kubectl edit clusterrole readonlyuser
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: "2021-10-11T15:24:07Z"
  name: readonlyuser
  resourceVersion: "357761"
  uid: 16cbf38f-0120-48e7-884d-67279b21314e
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - pods/log
  verbs:
  - get
  - list
  - watch
```

Конфиг ~/.kube/config:

```
root@centos8:~/.kube$ cat ./config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /root/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Mon, 11 Oct 2021 23:36:52 +08
        provider: minikube.sigs.k8s.io
        version: v1.23.2
      name: cluster_info
    server: https://192.168.134.11:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Mon, 11 Oct 2021 23:36:52 +08
        provider: minikube.sigs.k8s.io
        version: v1.23.2
      name: context_info
    namespace: default
    user: minikube
  name: minikube
- context:
    cluster: minikube
    user: developer
  name: podreader
current-context: minikube
kind: Config
preferences: {}
users:
- name: developer
  user:
    token: eyJhbGci....
- name: minikube
  user:
    client-certificate: /root/.minikube/profiles/minikube/client.crt
    client-key: /root/.minikube/profiles/minikube/client.key
```

## Задание 3: Изменение количества реплик

Переключаем контекст:
```
root@centos8:~/.kube$ kubectl config use-context minikube
Switched to context "minikube".
```

Увеличиваем количество реплик:
```
root@centos8:~/.kube$ kubectl scale --replicas=5 deployment hello-node -n hello-node
deployment.apps/hello-node scaled
```

Проверяем:
```
root@centos8:~/.kube$ kubectl get po -n hello-node
NAME                          READY   STATUS    RESTARTS      AGE
hello-node-7567d9fdc9-gnxqt   1/1     Running   1 (62m ago)   90m
hello-node-7567d9fdc9-ksbql   1/1     Running   0             80s
hello-node-7567d9fdc9-m594c   1/1     Running   1 (62m ago)   87m
hello-node-7567d9fdc9-tgt8p   1/1     Running   0             80s
hello-node-7567d9fdc9-vsvk7   1/1     Running   0             80s
```