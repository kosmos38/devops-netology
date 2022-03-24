# Домашнее задание к занятию "12.3 Развертывание кластера на собственных серверах, лекция 1"

# Задание 1: Описать требования к кластеру

Кластер предполагаю состоящий из 3-х control plane node и 5-ти worker node. В расчете потребителей ресурсов на нодах, ресурсы для control plane нод не учитываю, они будут учтены ниже.

Ниже приведена таблица расчитываемого потребления ресурсов на worker nodes:

| Потребитель | CPU (Core) | RAM (GB) | Disk (GB) |
| ---------|-------|----------|----------|
| Kube worker node | 1 | 1 | 100 |
| Kube worker node | 1 | 1 | 100 |
| Kube worker node | 1 | 1 | 100 |
| Kube worker node | 1 | 1 | 100 |
| Kube worker node | 1 | 1 | 100 |
|  |   |   |   |
| Postgres Master | 1 | 4 | 10 |
| Postgres Slave | 1 | 4 | 10 |
| Postgres Slave | 1 | 4 | 10 |
|  |   |   |   |
| Redis | 1 | 4 | 5 |
| Redis | 1 | 4 | 5 |
| Redis | 1 | 4 | 5 |
|  |   |   |   |
| Backend х10 | 10 | 6 | 20 |
| Frontend х5 | 0,5 | 0,025 | 10 |
|  |   |   |   |
| Итого: | 21,5  | 35,25  |  565 |

Здесь приведена таблица ресурсов выделяемых кластеру (включает в себя расход на содержание control plane nodes):

| Потребитель | CPU (Core) | RAM (GB) | Disk (GB) |
| ---------|-------|----------|----------|
| Kube control plane node | 2 | 2 | 50 |
| Kube control plane node | 2 | 2 | 50 |
| Kube control plane node | 2 | 2 | 50 |
| Kube worker node | 6 | 12 | 200 |
| Kube worker node | 6 | 12 | 200 |
| Kube worker node | 6 | 12 | 200 |
| Kube worker node | 6 | 12 | 200 |
| Kube worker node | 6 | 12 | 200 |
|  |   |   |   |
| Итого: | 36  | 66  |  1150 |

Кластер спроектировал с учетом отказоустойчивости. Можно потерять 2  worker node, при этом приложение не почувствует просадки по ресурсам. Ну и соответственно control plane node также отказоустойчивы.