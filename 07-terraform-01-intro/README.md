## Задача 1. Выбор инструментов.

>Для этого в рамках совещания надо будет выяснить подробности о проекте, что бы в итоге определиться с инструментами:
>    1. Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый?
>    2. Будет ли центральный сервер для управления инфраструктурой?
>    3. Будут ли агенты на серверах?
>    4. Будут ли использованы средства для управления конфигурацией или инициализации ресурсов?

>Ответить на четыре вопроса представленных в разделе "Легенда":

    1. Тип инфраструктуры неизменяемый, это более эффективный подход в нашем случае.
    2. Будем развиваться без применения центрального сервера, т.к. в проекте уже начали использовать Terraform и Ansible.
    3. Будем придерживаться реализации без применения агентов.
    4. Да будут, Terraform для инициализации ресурсов, Ansible для управления конфигурацией.

>Какие инструменты из уже используемых вы хотели бы использовать для нового проекта?

Packer, Terraform, Docker, Kubernetes, Ansible, Teamcity


>Хотите ли рассмотреть возможность внедрения новых инструментов для этого проекта?

С данным набором инструментов можно построить DevOps.

## Задача 2. Установка терраформ.
>Установите терраформ при помощи менеджера пакетов используемого в вашей операционной системе. 
>В виде результата этой задачи приложите вывод команды terraform --version.

```
kosmos@centos:~$ export VER="0.15.4"
kosmos@centos:~$ wget https://releases.hashicorp.com/terraform/${VER}/terraform_${VER}_linux_amd64.zip
kosmos@centos:~$ unzip terraform_${VER}_linux_amd64.zip
kosmos@centos:~$ sudo mv terraform /usr/local/bin/

kosmos@centos:~$ terraform --version
Terraform v0.15.4
on linux_amd64
```


## Задача 3. Поддержка легаси кода.
>Необходимо сделать так, чтобы вы могли одновременно использовать последнюю версию терраформа 
>установленную при помощи штатного менеджера пакетов и устаревшую версию 0.12.

Создаю различные каталоги для обоих версий и помещаю в них bin файлы terraform:


		root@centos:/usr/local$ mkdir -p /usr/local/terraform
		root@centos:/usr/local$ mkdir -p /usr/local/terraform/15
		root@centos:/usr/local$ mkdir -p /usr/local/terraform/12


Создаю символические ссылки для обеих версий Terraform в каталоге /usr/local/bin/:

		root@centos:/usr/local/bin$ ln -s /usr/local/terraform/15/terraform /usr/local/bin/terraform15
		root@centos:/usr/local/bin$ ln -s /usr/local/terraform/12/terraform /usr/local/bin/terraform12

Задаю ссылкам права на исполнение:

		root@centos:/usr/local/bin$ chmod ugo+x /usr/local/bin/terraform*

Проверяю:

		root@centos:/usr/local/bin$ which terraform12
		/usr/local/bin/terraform12
		
		root@centos:/usr/local/bin$ which terraform15
		/usr/local/bin/terraform15

Вызов различных версий:
Теперь команда terraform12 вызывает версию 0.12, а terraform15 -версию 0.15
Пример: 

```
root@centos:/usr/local/bin$ terraform12 --version
Terraform v0.12.31

Your version of Terraform is out of date! The latest version
is 0.15.4. You can update by downloading from https://www.terraform.io/downloads.html

root@centos:/usr/local/bin$ terraform15 --version
Terraform v0.15.4
on linux_amd64
```

Хранение двоичных файлов в отдельных каталогах также помогает отделить их плагины, не мешая друг другу.
