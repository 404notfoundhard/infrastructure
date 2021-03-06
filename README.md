# infrastructure

## Cloud-1 Task n1

### *Disclaimer*
Т.к. у меня домашняя ОС это Windows, то я использовала ВМ в GCP как «локальную».
Ключ от «локальной» подложила только в ВМ (не в Метаданные-Ключ), сгенерила ключ на «локальной» тачке и его подложила уже в Метаданные (который по всем ВМ).

### *Step-by-step* 

1. Подключаюсь к bastion с **fakelocalhost**:
> sokolova@fakelocalhost:~/.ssh$ ssh -i ~/.ssh/id_rsa sokolova@34.125.228.210
2. Пробую подключиться к someinternalhost с bastion:
> sokolova@bastion:~$ ssh 10.132.0.4

> Permission denied (publickey).
3. Запускаю на fakelocalhost ssh-agent:
> eval $(ssh-agent -s)
4. Настраиваю SSH Forwarding на «локальной»:
> sokolova@fakelocalhost:~/.ssh$ ssh-add –L

> The agent has no identities.
5. Добавляю приватный ключа в ssh-agent:
> sokolova@fakelocalhost:~/.ssh$ ssh-add ~/.ssh/id_rsa

> Identity added: /home/sokolova/.ssh/id_rsa (/home/sokolova/.ssh/id_rsa)
6. Пробую подключиться к bastion, но с пробросом ssh-agent:
> sokolova@fakelocalhost:~/.ssh$ ssh -i ~/.ssh/id_rsa -A sokolova@34.125.228.210

> @bastion:~$
7. Затем с bastion подключаюсь к someinternalhost:
> sokolova@bastion:~$ ssh 10.132.0.4

> @someinternalhost:~$

## Cloud-1 Task n2

### Tasks

1: Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства, проверить работоспособность найденного решения и внести его в README.md в вашем репозитории

2: Предложить вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли рабочего устройства, чтобы подключение выполнялось по алиасу someinternalhost и внести его в README.md в вашем репозитории

### Answers

1: Тут я не понимаю, у меня ведь ключик лежит в Метаданные, и я могу просто *ssh someinternalhost* подключиться к хосту.
> sokolova@fakelocalhost:~/.ssh$ ssh 10.132.0.4

> sokolova@someinternalhost:~$

Но полагаю я должна была использовать команду проброса подсети/хоста? Типа sshutle или ssh -L и т.д.

2: Тут вероятно тоже должны были быть трудности? При ssh подключении просто указываю hostname и сервер самостоятельно обрабатывает alias:
> sokolova@fakelocalhost:~/.ssh$ ssh someinternalhost

> The authenticity of host 'someinternalhost (10.132.0.4)' can't be established.
ECDSA key fingerprint is SHA256:fOOYCh+6lDMBong+CSHkom+E1ZQUQ+AZJxRzTk1Lr9w.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'someinternalhost' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.15.0-1098-gcp x86_64)

> Last login: Sat Sep 11 15:51:28 2021 from 10.132.0.3

> sokolova@someinternalhost:~$

