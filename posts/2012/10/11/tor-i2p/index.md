# Tor и I2P в Linux незаметно от санитаров

* * *
Для тех, кто не хочет тратить драгоценные 15 минут в Google.
* * *

  
### Tor

1. Установка Tor

        sudo apt-get install tor

2. Запуск Tor

        sudo service tor start
      
### I2P

1. Скачивание и установка [i2prouter](http://www.i2p2.de/debian.html)

2. Запуск роутера:

        i2prouter start

3. Добавление подписок в [адресную книгу](http://127.0.0.1:7657/dns):

        http:⁄⁄www.i2p2.i2p/hosts.txt
        http:⁄⁄i2host.i2p/cgi-bin/i2hostetag
        http:⁄⁄stats.i2p/cgi-bin/newhosts.txt
        http:⁄⁄inr.i2p/export/alive-hosts.txt
        http:⁄⁄joajgazyztfssty4w2on5oaqksz6tqoxbduy553y34mf4byv6gpq.b32.i2p/export/alive-hosts.txt
        http:⁄⁄tino.i2p/hosts.txt
        http:⁄⁄dream.i2p/hosts.txt
        http:⁄⁄hosts.i2p/
        http:⁄⁄biw5iauxm7cjkakqygod3tq4w6ic4zzz5mtd4c7xdvvz54fyhnwa.b32.i2p/uncensored_hosts.txt
        http:⁄⁄trevorreznik.i2p/hosts.txt
        http:⁄⁄cipherspace.i2p/addressbook.txt
        http:⁄⁄hosts.i2p/hosts.cgi?filter=all
        http:⁄⁄bl.i2p/hosts2.txt
        http:⁄⁄rus.i2p/hosts.txt


### Настройка браузера (на примере Firefox)

1. Установка [Proxy Selector](https://addons.mozilla.org/ru/firefox/addon/proxy-selector/)

2. Настройка прокси для **Tor**:

    **Тип прокси**: Socks v5  
    **Host**: localhost  
    **Port**: 9050

3. Настройка прокси для **I2P**:

    **Тип прокси**: HTTP    
    **Host**: localhost  
    **Port**: 4444
    
4. Настройка DNS для использования .onion-сервисов:
    
    На странице расширенных настроек <about:config> нужно выставить настройку `network.proxy.socks_remote_dns` в `true`