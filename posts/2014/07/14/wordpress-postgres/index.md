# Wordpress + Postgres via pg4wp: костыли и подпорки 

Столкнулся со следующей проблемой при использовании Wordpress в связке с Postgres, а не с предлагаемым по умолчанию MySQL: несмотря на установленное и активированное расширение pg4wp, WP пытается долбиться в базу данных через драйвер mysqli.

Интернеты предлагают [различные волшебные патчи](http://wordpress.org/support/topic/not-working-with-39) на интерфейсы к БД, но проблема кроется чуть [глубже](https://github.com/WordPress/WordPress/blob/master/wp-includes/wp-db.php):

    if (function_exists('mysqli_connect')) {
        if (defined('WP_USE_EXT_MYSQL')) {
            $this->use_mysqli = !WP_USE_EXT_MYSQL;
        } elseif (version_compare(phpversion(), '5.5', '>=') || !function_exists('mysql_connect')) {
            $this->use_mysqli = true;
        } elseif (false !== strpos($GLOBALS['wp_version'], '-')) {
            $this->use_mysqli = true;
        }
    }

Как видно, если используется PHP версии 5.5 и выше, то WP будет принудительно использовать mysqli, если предварительно в `wp_config.php` не выставлен флаг `WP_USE_EXT_MYSQL`.

Установкой данного флага означенная проблема и лечится:

    define('WP_USE_EXT_MYSQL', true);