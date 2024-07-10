# Переносим репозитории с BitBucket на GitHub

*** 

В прошлом году я переезжал с одной VCS на другую. Ретроспективно рассказываю, как перенести репозитории с BitBucket на GitHub, и как сделать бэкап всех репозиториев.

***

Долгое время BitBucket был моей основной VCS: бесплатные приватные репозитории и поддержка Mercurial закрывали все рабочие потребности.
Со временем GitHub'а по работе становилось все больше, а потом туда и бесплатные приватные репозитории подъехали, и CI/CD завезли — стало вообще хорошо, надо было переезжать.
На BitBucket у меня к тому времени оставалось около 40 проектов разной степени актуальности, руками их перенести можно было бы, но долго.

Написал утилиту для автоматизации переноса, которая через API получает данные о репозиториях в одной VCS, создает репозитории в другой VSC и переносит все данные.

[👉 **torunar/repository-migrator**](https://github.com/torunar/repository-migrator)

Внутри она использует не самую часто упоминаемую опцию команды `git clone` — `--mirror`.
При ее включении будут сгружены все ветки и теги — в результате будет создана полная локальная копия репозитория из VCS.

## Как установить утилиту

* Установите Python 3.
* Создайте app password для BitBucket с правами `Repositories: Read`, `Repositories: Write` и `Repositories: Admin`: [bitbucket.org/account/settings/app-passwords/new](https://bitbucket.org/account/settings/app-passwords/new).
* Создайте personal token для GitHub с правами `repo`: [github.com/settings/tokens/new](https://github.com/settings/tokens/new).
* Склонируйте репозиторий:

        $ git clone git@github.com:torunar/repository-migrator.git
    
* Установите зависимости:
    
        $ cd repository-migrator
        $ pip3 install -r requirements.txt

## Как перенести репозитории с BitBucket на GitHub
    
    $ python3 repository-migrator \
        --input=bitbucket \
        --output=github \
        --bitbucket-login='Ник на BitBucket' \ 
        --bitbucket-password='App password для BitBucket' \
        --github-login='Ник на GitHub' \
        --github-password='Personal access token для GitHub'

## Как перенести репозитории с GitHub на BitBucket

    $ python3 repository-migrator \
        --input=github \
        --output=bitbucket \
        --bitbucket-login='Ник на BitBucket' \ 
        --bitbucket-password='App password для BitBucket' \
        --github-login='Ник на GitHub' \
        --github-password='Personal access token для GitHub'

## Как сделать бэкап репозиториев с GitHub

    $ python3 repository-migrator \
        --input=github \
        --output=local \
        --github-login='Ник на GitHub' \
        --github-password='Personal access token для GitHub' \
        --storage-path='Папка для бэкапов (должна быть создана заранее)'

## Как сделать бэкап репозиториев с BitBucket

    $ python3 repository-migrator \
        --input=bitbucket \
        --output=local \
        --bitbucket-login='Ник на BitBucket' \ 
        --bitbucket-password='App password для BitBucket' \
        --storage-path='Папка для бэкапов (должна быть создана заранее)'

## Как актуализировать локальные копии репозиториев

Если после бэкапа репозиториев их нужно актуализировать, нет необходимости заново выкачивать весь репозиторий, можно использовать команду:

    $ git remote update

Если все репозитории хранятся в одной папке `/directory/with/backup`, их можно обновить так:

    $ for REPO_DIR in $(find /directory/with/backups -d 1 -type d); do 
        git -C $REPO_DIR remote update
    done
