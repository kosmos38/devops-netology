# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"

Для выполнения задания я запушил образы приложения в свой docker hub (по образам из папки 13-kubernetes-config):

https://hub.docker.com/repository/docker/kosmos38/13-kubernetes-frontend
https://hub.docker.com/repository/docker/kosmos38/13-kubernetes-backend


Конфигурационные файлы stage окружения [/stage](https://github.com/kosmos38/devkub-homeworks/tree/master/13-kubernetes-config-01/stage)

Конфигурационные файлы prod окружения  [/prod](https://github.com/kosmos38/devkub-homeworks/tree/master/13-kubernetes-config-01/prod)

## Задание 1: подготовить тестовый конфиг для запуска приложения

Создал namespace для тестового окружения:

```
root@kube-master1:/home/kosmos/13-kubernetes/stage$ kubectl create namespace stage
namespace/stage created
```

Применил свои манифесты:

```
root@kube-master1:/home/kosmos/13-kubernetes/stage$ kubectl apply -f ./
deployment.apps/app created
statefulset.apps/db created
service/app created
service/db created
```

Результат:

```
root@kube-master1:/home/kosmos$ kubectl get service -n stage -o wide
NAME   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE     SELECTOR
app    NodePort    10.233.14.245   <none>        80:30001/TCP   4m40s   app=app
db     ClusterIP   10.233.17.89    <none>        5432/TCP       5m9s    app=db
```

```
root@kube-master1:/home/kosmos$ kubectl get deploy -n stage -o wide
NAME   READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS         IMAGES                                                           SELECTOR
app    1/1     1            1           4m49s   frontend,backend   kosmos38/13-kubernetes-frontend,kosmos38/13-kubernetes-backend   app=app
```

```
root@kube-master1:/home/kosmos$ kubectl get statefulset -n stage -o wide
NAME   READY   AGE     CONTAINERS   IMAGES
db     1/1     4m56s   db           postgres:13-alpine
```

```
root@kube-master1:/home/kosmos$ kubectl get po -n stage -o wide
NAME                   READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
app-65f9757997-x9jqn   2/2     Running   0          13m   10.233.103.30   kube-node2   <none>           <none>
db-0                   1/1     Running   0          13m   10.233.101.36   kube-node1   <none>           <none>
```

## Задание 2: подготовить конфиг для production окружения

Создал namespace для продуктового окружения:

```
root@kube-master1:/home/kosmos/13-kubernetes/stage$ kubectl create namespace prod
namespace/prod created
```

Применил свои манифесты:

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl apply -f ./
deployment.apps/backend created
deployment.apps/frontend created
statefulset.apps/db created
service/backend created
service/frontend created
service/db created
```

Результат выполенения:

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get services -n prod -o wide
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
backend    ClusterIP   10.233.2.22     <none>        9000/TCP       81m   app=backend
db         ClusterIP   10.233.35.68    <none>        5432/TCP       81m   app=db
frontend   NodePort    10.233.31.255   <none>        80:30000/TCP   81m   app=frontend
```

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get deploy -n prod -o wide
NAME       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                            SELECTOR
backend    1/1     1            1           81m   backend      kosmos38/13-kubernetes-backend    app=backend
frontend   1/1     1            1           81m   frontend     kosmos38/13-kubernetes-frontend   app=frontend
```

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get statefulset -n prod -o wide
NAME   READY   AGE   CONTAINERS   IMAGES
db     1/1     77m   db           postgres:13-alpine
```

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get po -n prod -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
backend-7cfc754dfd-nr9pk   1/1     Running   0          83m   10.233.103.28   kube-node2   <none>           <none>
db-0                       1/1     Running   0          75m   10.233.101.35   kube-node1   <none>           <none>
frontend-bfcd649bd-gt8xs   1/1     Running   0          38m   10.233.103.29   kube-node2   <none>           <none>
```

Наружу смотрит только frontend.
