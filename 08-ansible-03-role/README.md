# Домашнее задание к занятию "08.03 Работа с Roles"

* Ссылка на переработанный [playbook](https://github.com/kosmos38/mnt-netology/tree/master/08-ansible-03-role) с ролями. Данная конфигурация успешно проходит тесты и удовлетворяет требованиям из основной части домашнего задания

* Ссылка на репозиторий с ролью [elastic-role](https://github.com/kosmos38/elastic-role)

* Ссылка на репозиторий с ролью [kibana-role](https://github.com/kosmos38/kibana-role)

### С помощью `requirements.yml` выкачиваются указанные роли:

```
kosmos@centos:/git/tmp$ ansible-galaxy install -r requirements.yml
Starting galaxy role install process
- extracting java-role to /home/kosmos/.ansible/roles/java-role
- java-role (1.0.1) was installed successfully
- extracting elastic-role to /home/kosmos/.ansible/roles/elastic-role
- elastic-role (1.0.0) was installed successfully
- extracting kibana-role to /home/kosmos/.ansible/roles/kibana-role
- kibana-role (1.0.0) was installed successfully
```

### Все роли успешно проходят все тесты через `molecule test`