# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Попробовал предложенные команды:

```
$ kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key -n prod
secret/domain-cert created

$ kubectl get secrets -n prod
NAME                  TYPE                                  DATA   AGE
default-token-kfk6h   kubernetes.io/service-account-token   3      27d
domain-cert           kubernetes.io/tls                     2      32s
netology              Opaque                                2      25m

$ kubectl get secret netology -n prod
NAME       TYPE     DATA   AGE
netology   Opaque   2      26m
$ kubectl get secret domain-cert -n prod
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      74s


$ kubectl describe secrets domain-cert -n prod
Name:         domain-cert
Namespace:    prod
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.key:  3243 bytes
tls.crt:  1931 bytes
$ kubectl describe secrets netology -n prod
Name:         netology
Namespace:    prod
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
PASS:  8 bytes
USER:  4 bytes
```

## Задача 2 (*): Работа с секретами внутри модуля

Подготовил [yaml файл своего секрета](secret_prod_backend.yaml)  и применил:

        $ kubectl apply -f secret_prod_backend.yaml


Подгтовил [deployment](deploy-prod-backend.yaml) и применил:

        $ kubectl apply -f deploy-prod-backend.yaml


Проверил ENV:

```
$ kubectl -n prod exec -it backend-668d8dfb84-2zjdf bash

root@backend-668d8dfb84-2zjdf:/app# env | grep 'USER\|PASS'
USER=user
PASS=password
```

Проверил наличие проброшенного сертификата:

```
root@backend-c854ffffb-28qbf:/app/certs# ls -l
total 0
lrwxrwxrwx. 1 root root 14 Dec  2 17:35 tls.crt -> ..data/tls.crt
lrwxrwxrwx. 1 root root 14 Dec  2 17:35 tls.key -> ..data/tls.key
```