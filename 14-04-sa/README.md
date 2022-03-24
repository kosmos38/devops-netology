# Домашнее задание к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl

Все команды попробовал в задании 2, здесь привожу только выводы созданного serviceaccount

Как просмотреть список сервис-акаунтов?

```
$ kubectl get serviceaccounts -n prod
NAME      SECRETS   AGE
default   1         44d
kosmos    1         53m
```

Как выгрузить сервис-акаунты и сохранить его в файл?

```
$ kubectl get serviceaccount kosmos -n prod -o json > kosmos.json
root@kube-master1:/home/kosmos$ cat kosmos.json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2021-12-19T11:35:10Z",
        "name": "kosmos",
        "namespace": "prod",
        "resourceVersion": "10605499",
        "uid": "94a3edee-2338-4cb3-935d-5e37526e4dcb"
    },
    "secrets": [
        {
            "name": "kosmos-token-bhlsr"
        }
    ]
}

$ kubectl get serviceaccount kosmos -n prod -o yaml > kosmos.yaml
$ cat kosmos.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2021-12-19T11:35:10Z"
  name: kosmos
  namespace: prod
  resourceVersion: "10605499"
  uid: 94a3edee-2338-4cb3-935d-5e37526e4dcb
secrets:
- name: kosmos-token-bhlsr

```

## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

Подготовил переменные:

```
$ ACCOUNT_NAME=kosmos
$ NAMESPACE=prod
$ ROLENAME=read-exec-create-pods-svc-ing
```

Создал serviceaccount с правами на создание подов:

```
$ kubectl create serviceaccount $ACCOUNT_NAME --namespace $NAMESPACE

$ kubectl get serviceAccounts -n prod
NAME      SECRETS   AGE
default   1         44d
kosmos    1         26s
```

Создал роль:

    kubectl apply -f $ROLENAME-role.yaml -n $NAMESPACE

Создаль rolebinding:

    kubectl apply -f $ROLENAME-rolebinding.yaml -n $NAMESPACE

Конфигурационный файл [role](read-exec-create-pods-svc-ing.yaml)

Конфигурационный файл [rolebinding](read-exec-create-pods-svc-ing-rolebinding.yaml)

Запустил под с Fedora от имени созданного serviceacount:

```
$ kubectl --kubeconfig=$CLUSTER_NAME-$ACCOUNT_NAME-kube.conf exec -it frontend-6d9664fd8b-kvwmj -n prod -- bash
```

Установил нужные переменные в поде:

```
root@frontend-6d9664fd8b-kvwmj:/app# K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
root@frontend-6d9664fd8b-kvwmj:/app# SADIR=/var/run/secrets/kubernetes.io/serviceaccount
root@frontend-6d9664fd8b-kvwmj:/app# TOKEN=$(cat $SADIR/token)
root@frontend-6d9664fd8b-kvwmj:/app# CACERT=$SADIR/ca.crt
root@frontend-6d9664fd8b-kvwmj:/app# NAMESPACE=$(cat $SADIR/namespace)
```

Обратился к API k8s из пода и получил успешный вывод в json формате:

```
root@frontend-6d9664fd8b-kvwmj:/app# curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
...
```