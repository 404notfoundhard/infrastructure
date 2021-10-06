# infrastructure

## Cloud-1

<details>

<summary>Solution</summary>

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

</details>

## Cloud-2

<details>

<summary>Solution</summary>

### *Disclaimer*

В этот раз я использовала Virtual Box и виртуалку на Kali Linux.

### Tasks

1: Установить Google Cloud SDK, создать инстанс, установить Ruby, установить MongoDB, деплой приложения с репы github  
2: Команды по настройке системы и деплоя приложения завернуть в bash-скрипты

- *install_ruby.sh* должен содержать команды по установке Ruby
- *install_mongodb.sh* должен содержать команды по установке MongoDB
- *deploy.sh* должен содержать команды скачивания кода, установки зависимостей через bundler и запуск приложения  

3: Дополнительная задача: использовать скрипты из пункта 2 для создания startup script, который будет запускать при создании инстанса  
4: Дополнительная задача: создать правило fw для инстанса через gcloud

### *Step-by-step* 

#### Задача n1 
Первый пункт (установка и настройка вручную) без проблем прошёл.

#### Задача n2
Смотреть скрипты в /Cloud-2. Запуск вручную работает
>sokolova@new-test-app:~$ systemctl status mongod  
● mongod.service - MongoDB Database Server  
   Loaded: loaded (/lib/systemd/system/mongod.service; enabled; vendor p  
   **Active: active (running)** since Wed 2021-10-06 05:07:25 UTC; 4min 27s   
     Docs: https://docs.mongodb.org/manual  
 Main PID: 19360 (mongod)  
   CGroup: /system.slice/mongod.service  
           └─19360 /usr/bin/mongod --config /etc/mongod.conf  
Oct 06 05:07:25 new-test-app systemd[1]: Started MongoDB Database Server  
Oct 06 05:11:27 new-test-app systemd[1]: Started MongoDB Database Server  
sokolova@new-test-app:~$   
sokolova@new-test-app:~$ ps aux | grep puma  
sokolova 21053  1.3  1.5 515404 26904 ?        Sl   05:11   0:00 **puma 3.10.0 (tcp://0.0.0.0:9292) [reddit]**  
sokolova 21069  0.0  0.0  12944  1088 pts/0    S+   05:12   0:00 grep --color=auto puma

#### Задача n3
Результат: инстанс поднимает, но без приложения. Возможно проблемы с хождением в Github, потому что если вручную на инстансе запустить, он устанавливает Монго и Руби, а на моменте пулла Reddit ошибка (если добавить потом ключ и запустить вручную снова - всё ставится и запускается).

**Команда поднять инстанс с startup script**
>root@ana:~/otes_gcp# gcloud compute instances create new-test-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --metadata=startup-script=/root/otes_gcp/startup.sh

>Created [https://www.googleapis.com/compute/v1/projects/infra-325609/zones/asia-east1-b/instances/new-test-app].  
NAME          ZONE          MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS  
new-test-app  asia-east1-b  g1-small                   10.140.0.4   34.80.154.236  RUNNING

**Ошибка запуска вручную startup.sh**
>Cloning into 'reddit'...  
The authenticity of host 'github.com (52.192.72.89)' can't be established.  
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.  
Are you sure you want to continue connecting (yes/no)? yes  
Warning: Permanently added 'github.com,52.192.72.89' (RSA) to the list of known hosts.  
Permission denied (publickey).  
fatal: Could not read from remote repository.  
Please make sure you have the correct access rights  
and the repository exists.  
deploy.sh: 4: cd: can't cd to /home/sokolova/reddit  
Could not locate Gemfile or .bundle/ directory  
deploy.sh: 7: deploy.sh: puma: not found  

#### Задача n4 
Пока разбиралась с предыдущими и оставила её, позже сделаю и добавлю сюда

</details>
