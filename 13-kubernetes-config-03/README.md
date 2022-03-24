# Домашнее задание к занятию "13.3 работа с kubectl"

## Задание 1: проверить работоспособность каждого компонента

Для целей отладки я захотел временно подключиться к бэкенду (сервис обеспечивает доступ только внутри кластера)

Смотрю имена подов:

```
root@kube-master1:/home/kosmos$ kubectl get po -n prod
NAME                        READY   STATUS    RESTARTS   AGE
backend-6cf8b746fb-f226x    1/1     Running   0          22h
db-0                        1/1     Running   0          10d
frontend-6d9664fd8b-kvwmj   1/1     Running   0          22h
```

Пробрасываю порт бэкенда 9000 на localhost:30300:

```
root@kube-master1:/home/kosmos$ kubectl port-forward backend-6cf8b746fb-f226x -n prod 30300:9000
```

Проверяю http запросы к бэкенду:

```
root@kube-master1:/home/kosmos$ curl http://localhost:30300/api/news/1
{"id":1,"title":"title 0","short_description":"small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0","description":"0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, ","preview":"/static/image.png"}

```

Сделать отладку запросов к postgres можно следующим образом:

```
root@kube-master1:/home/kosmos$ kubectl exec db-0 -it -n prod -- psql -U postgres news
psql (13.4)
Type "help" for help.

news=#
news=# select title from news;
  title
----------
 title 0
 title 1
 title 2
 title 3
 title 4
 title 5
 title 6
 title 7
 title 8
 title 9
 title 10
 title 11
 title 12
 title 13
 title 14
 title 15
 title 16
 title 17
 title 18
 title 19
 title 20
 title 21
 title 22
 title 23
 title 24
(25 rows)
```

## Задание 2: ручное масштабирование

Проверяю состояние deployments:

```
root@kube-master1:/home/kosmos$ kubectl get deployments -n prod
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
backend    1/1     1            1           23h
frontend   1/1     1            1           23h
```

Увеличиваю количество реплик бэкенда:

```
root@kube-master1:/home/kosmos$ kubectl scale --replicas=3 deployment/backend -n prod
deployment.apps/backend scaled
```
Проверяю результат:

```
root@kube-master1:/home/kosmos$ kubectl get po -n prod -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
backend-6cf8b746fb-f226x    1/1     Running   0          23h   10.233.103.36   kube-node2   <none>           <none>
backend-6cf8b746fb-hcbhh    1/1     Running   0          19s   10.233.103.42   kube-node2   <none>           <none>
backend-6cf8b746fb-vzzqd    1/1     Running   0          19s   10.233.103.41   kube-node2   <none>           <none>
db-0                        1/1     Running   0          10d   10.233.101.35   kube-node1   <none>           <none>
frontend-6d9664fd8b-kvwmj   1/1     Running   0          23h   10.233.101.40   kube-node1   <none>           <none>
```

Увеличиваю количество реплик фронтенда:

```
root@kube-master1:/home/kosmos$ kubectl scale --replicas=3 deployment/frontend -n prod
deployment.apps/frontend scaled
```

Проверяю результат:

```
root@kube-master1:/home/kosmos$ kubectl get po -n prod -o wide
NAME                        READY   STATUS    RESTARTS   AGE    IP              NODE         NOMINATED NODE   READINESS GATES
backend-6cf8b746fb-f226x    1/1     Running   0          23h    10.233.103.36   kube-node2   <none>           <none>
backend-6cf8b746fb-hcbhh    1/1     Running   0          2m3s   10.233.103.42   kube-node2   <none>           <none>
backend-6cf8b746fb-vzzqd    1/1     Running   0          2m3s   10.233.103.41   kube-node2   <none>           <none>
db-0                        1/1     Running   0          10d    10.233.101.35   kube-node1   <none>           <none>
frontend-6d9664fd8b-dgk4j   1/1     Running   0          35s    10.233.103.43   kube-node2   <none>           <none>
frontend-6d9664fd8b-kvwmj   1/1     Running   0          23h    10.233.101.40   kube-node1   <none>           <none>
frontend-6d9664fd8b-pzd6x   1/1     Running   0          34s    10.233.103.44   kube-node2   <none>           <none>
```

Возвращаю количество реплик к 1:

```
root@kube-master1:/home/kosmos$ kubectl scale --replicas=1 deployment/frontend deployment/backend -n prod
deployment.apps/frontend scaled
deployment.apps/backend scaled
```

Проверяю результат:

```
root@kube-master1:/home/kosmos$ kubectl get po -n prod -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
backend-6cf8b746fb-f226x    1/1     Running   0          23h   10.233.103.36   kube-node2   <none>           <none>
db-0                        1/1     Running   0          10d   10.233.101.35   kube-node1   <none>           <none>
frontend-6d9664fd8b-kvwmj   1/1     Running   0          23h   10.233.101.40   kube-node1   <none>           <none>
```