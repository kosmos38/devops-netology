# devops-netology
# 24.01.2021
# 26.01.2021 Commit из IDE в ветку main

# Игонирурем системные файлы terraform, плагины итд
**/.terraform/*

# Исключаем файлы по маске
*.tfstate
*.tfstate.*

# Исключаем конкретный файл crash.log
crash.log

# Исключаем файлы с раширением *.tfvars, так как они содержат пароли, ключи и тд.
*.tfvars

# Игнорируем файлы "override" по шаблону, так как они обычно используются для локальных настроек
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Добавляем в исключения файлы "override", которые не попадут под вышестоящий шаблон
# !example_override.tf

# Исключаем все файлы которые в названии содержат "tfplan"
# example: *tfplan*

# Игнорировать файлы конфигурации CLI
.terraformrc
terraform.rc
