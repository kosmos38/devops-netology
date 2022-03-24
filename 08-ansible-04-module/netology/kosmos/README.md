# Ansible Collection - netology.kosmos

Данная коллекция содержит в себе модуль `plugins/modules/create_file`.
Данный модуль создаёт файл в указанной директории с указанным содержимым.
Все вводные данные передаеются роли через переменные

### Запуск коллекции:
``
ansible-playbook site.yml --module-path plugins/modules/ -i inventories/netology
``

### Описание переменных используемых ролью create-file-role:
   * `name_dir:` "название создаваемого файла"
   * `path_to_dir:` "путь к директории с файлом"
   * `text:` "текст/контет файла"
   * `force:` False (булевое значение, перезаписывать файл?)

### Данная коллекция успешно прошла тесты:

   * в виртуальном окружении 
    `python -m ansible.modules.create_file payload.json`
   * в виртуальном окружении через ansible
    `ansible-playbook playbook.yml`
   * в реальном окружении в виде single task playbook 
   * Далее преобразована в `single task role` и перенесена в `collection`
   * Протестирована возможность передачи коллекции в виде tar.gz. `build` и `install` в новой директории прошла успешно

