## Задача 1. Настроить terraform cloud

Зарегистрировал, выполнил plan, скриншот успешного plan во вложении к ДЗ

## Задача 2. Написать серверный конфиг для атлантиса

Ссылка на конфигурацию atlantis:
https://github.com/kosmos38/devops-netology/tree/main/07-terraform-04-teamwork/atlantis


>>server.yaml

```
repos:
  github.com/kosmos38
- id: github.com/kosmos38/atlantis
  branch: /.*/
  apply_requirements: [approved, mergeable]
  workflow: custom
  allowed_overrides: [apply_requirements, workflow, delete_source_branch_on_merge]
  allowed_workflows: [custom]
  allow_custom_workflows: true
  delete_source_branch_on_merge: true
  
workflows:
  custom:
    plan:
      steps:
      - init
      - plan:
          extra_args: ["-lock", "false"]
    apply:
      steps:
      - apply
```

>> atlantis.yaml

```
version: 3
automerge: true
delete_source_branch_on_merge: true
projects:
- name: netology-project1
  dir: .
  workspace: stage
  terraform_version: v0.11.0
  delete_source_branch_on_merge: true
  autoplan:
    when_modified: ["*.tf", "../modules/**.tf"]
    enabled: true
  apply_requirements: [mergeable, approved]
  workflow: workflow_stage
- name: netology-project1
  dir: .
  workspace: prod
  terraform_version: v0.11.0
  delete_source_branch_on_merge: true
  autoplan:
    when_modified: ["*.tf", "../modules/**.tf"]
    enabled: true
  apply_requirements: [mergeable, approved]
  workflow: workflow_prod
workflows:
  workflow_stage:
    plan:
      steps: [init, plan]
    apply:
      steps: [apply]
  workflow_prod:
    plan:
      steps:
      - run: my-custom-command arg1 arg2
      - init
      - plan:
      - run: my-custom-command arg1 arg2
    apply:
      steps:
      - run: echo hi
      - apply
```

## Задача 3. Знакомство с каталогом модулей.

Модуль ec2-instance попробовал в своём проекте, маловероятно что буду  использоваь его в работе.
Проще выстроить свою логику в конфиге, с нужными параметрами и вызвать resource "aws_instance"

```
module "ec2-instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "ubuntu-web-module-1"
  instance_count         = 1

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4"

  tags = {
  Name = "ubuntu-web-module-1"
  }
}
```

Ссылка на проект с модулем:
https://github.com/kosmos38/devops-netology/tree/main/07-terraform-04-teamwork/terraform-modules

Также исправил в этом проекте ошибку из прошлого задания, поправил блок for each