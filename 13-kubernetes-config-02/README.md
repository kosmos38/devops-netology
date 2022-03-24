# Домашнее задание к занятию "13.2 разделы и монтирование"

## Задание 1: подключить для тестового конфига общую папку

С целью экспиремента создал volume для stage окружения в режиме: hostPath

Конфигурационный файл stage окружения c volume [/app-volume](https://github.com/kosmos38/devkub-homeworks/tree/master/13-kubernetes-config-02/stage)

Проверка:

Создаю файл в контейнере backend
```
root@kube-master1:/home/kosmos/13-kubernetes/stage$ kubectl exec -it app-6bfcf95458-st9k4 -n stage  -c backend bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@app-6bfcf95458-st9k4:/app# touch /static/1.txt
root@app-6bfcf95458-st9k4:/app# ls /static/
1.txt
```

Создаю файл в контейнере frontend
```
root@kube-master1:/home/kosmos/13-kubernetes/stage$ kubectl exec -it app-6bfcf95458-st9k4 -n stage  -c frontend bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@app-6bfcf95458-st9k4:/app# touch /static/2.txt
root@app-6bfcf95458-st9k4:/app# ls /static/
1.txt  2.txt
```

Проверяю на какой ноде запущен под:
```
root@kube-master1:/home/kosmos$ kubectl get po -n stage -o wide
NAME                   READY   STATUS    RESTARTS   AGE     IP              NODE         NOMINATED NODE   READINESS GATES
app-6bfcf95458-st9k4   2/2     Running   0          5m59s   10.233.103.31   kube-node2   <none>           <none>
db-0                   1/1     Running   0          9d      10.233.101.36   kube-node1   <none>           <none>
```

Проверяю наличие файлов в директории на наде kube-node2:
```
kosmos@kube-node2:/opt/stage/static$ ls -lah
total 0
drwxr-xr-x. 2 root root 32 Nov 14 20:32 .
drwxr-xr-x. 3 root root 20 Nov 14 20:28 ..
-rw-r--r--. 1 root root  0 Nov 14 20:30 1.txt
-rw-r--r--. 1 root root  0 Nov 14 20:32 2.txt
```

## Задание 2: подключить общую папку для прода

Конфигурационные файлы prod окружения c nfs volumes [/nfs-volumes](https://github.com/kosmos38/devkub-homeworks/tree/master/13-kubernetes-config-02/prod)

Проверил доступность NFS:

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get po
NAME                                  READY   STATUS    RESTARTS      AGE
nfs-server-nfs-server-provisioner-0   1/1     Running   2 (18m ago)   39m
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get sc
NAME   PROVISIONER                                       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    cluster.local/nfs-server-nfs-server-provisioner   Delete          Immediate           true                   39m
```

Проверил доступность контейнеров prod окружения:

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get po -n prod -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
backend-6cf8b746fb-f226x    1/1     Running   0          11m   10.233.103.36   kube-node2   <none>           <none>
db-0                        1/1     Running   0          9d    10.233.101.35   kube-node1   <none>           <none>
frontend-6d9664fd8b-kvwmj   1/1     Running   0          11m   10.233.101.40   kube-node1   <none>           <none>
```

Проверяю доступность файлов в контенере backend:

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl exec -it backend-6cf8b746fb-f226x -n prod bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@backend-6cf8b746fb-f226x:/app# cd /static/
root@backend-6cf8b746fb-f226x:/static# ls
root@backend-6cf8b746fb-f226x:/static# touch 1-2.txt
root@backend-6cf8b746fb-f226x:/static# ls
1-2.txt
```

Проверяю доступность файлов в контенере frontend, вижу файлы обоих контейнеров:

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl exec -it frontend-6d9664fd8b-kvwmj -n prod bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@frontend-6d9664fd8b-kvwmj:/app# cd /static/
root@frontend-6d9664fd8b-kvwmj:/static# ls
1-2.txt
root@frontend-6d9664fd8b-kvwmj:/static# touch 2-2.txt
root@frontend-6d9664fd8b-kvwmj:/static# ls
1-2.txt  2-2.txt
```

Вывод информации о pvc и pv:

```
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get pvc -n prod
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
static-nfs-pvc   Bound    pvc-f7e63bd9-964c-4648-a46c-678b055e19e2   1Gi        RWX            nfs            14m
root@kube-master1:/home/kosmos/13-kubernetes/prod$ kubectl get pv -n prod
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
pvc-f7e63bd9-964c-4648-a46c-678b055e19e2   1Gi        RWX            Delete           Bound    prod/static-nfs-pvc   nfs                     14m
```