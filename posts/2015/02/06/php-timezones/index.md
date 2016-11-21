# Список часовых поясов на PHP «как у взрослых»

После нескольких месяцев активной разработки “внезапно” выяснилось, что пользователи зачастую не знают, в каком часовом поясе они находятся, а потому конструкция подобного вида повергает народ в смятение: <select><option value="-13:00">UTC-13:00</option><option value="-12:30">UTC-12:30</option><option value="-12:00">UTC-12:00</option><option value="-11:30">UTC-11:30</option><option value="-11:00">UTC-11:00</option><option value="-10:30">UTC-10:30</option><option value="-10:00">UTC-10:00</option><option value="-09:30">UTC-09:30</option><option value="-09:00">UTC-09:00</option><option value="-08:30">UTC-08:30</option><option value="-08:00">UTC-08:00</option><option value="-07:30">UTC-07:30</option><option value="-07:00">UTC-07:00</option><option value="-06:30">UTC-06:30</option><option value="-06:00">UTC-06:00</option><option value="-05:30">UTC-05:30</option><option value="-05:00">UTC-05:00</option><option value="-04:30">UTC-04:30</option><option value="-04:00">UTC-04:00</option><option value="-03:30">UTC-03:30</option><option value="-03:00">UTC-03:00</option><option value="-02:30">UTC-02:30</option><option value="-02:00">UTC-02:00</option><option value="-01:30">UTC-01:30</option><option value="-01:00">UTC-01:00</option><option value="-00:30">UTC-00:30</option><option value="+00:00">UTC+00:00</option><option value="+00:30">UTC+00:30</option><option value="+01:00">UTC+01:00</option><option value="+01:30">UTC+01:30</option><option value="+02:00">UTC+02:00</option><option value="+02:30">UTC+02:30</option><option value="+03:00">UTC+03:00</option><option value="+03:30">UTC+03:30</option><option value="+04:00">UTC+04:00</option><option value="+04:30">UTC+04:30</option><option value="+05:00">UTC+05:00</option><option value="+05:30">UTC+05:30</option><option value="+06:00">UTC+06:00</option><option value="+06:30">UTC+06:30</option><option value="+07:00">UTC+07:00</option><option value="+07:30">UTC+07:30</option><option value="+08:00">UTC+08:00</option><option value="+08:30">UTC+08:30</option><option value="+09:00">UTC+09:00</option><option value="+09:30">UTC+09:30</option><option value="+10:00">UTC+10:00</option><option value="+10:30">UTC+10:30</option><option value="+11:00">UTC+11:00</option><option value="+11:30">UTC+11:30</option><option value="+12:00">UTC+12:00</option><option value="+12:30">UTC+12:30</option><option value="+13:00">UTC+13:00</option></select>

К тому же, использование часовых поясов, заданных в формате “+ЧЧ:ММ” создавало дополнительные сложности для жителей тех регионов, где существует разделение на зимнее и летнее время или часовой пояс сменился по государственным причинам.

Чужие наработки на уровне фреймворков, жестко пробитых в массиве значений или сторонних сервисов были отметены сразу, поэтому было принято волевое решение: сделать свой, “как у взрослых”, список часовых поясов и использовать в работе не смещение относительно UTC, а аббревиатуры часовых поясов, благо, PostgreSQL умеет работать с обоими форматами:

    SELECT dt AT TIME ZONE '+03:00' FROM t;
    SELECT dt AT TIME ZONE 'EET'    FROM t;

Критерии “взрослости” были выбраны следующие:

1. удобное представление
2. полнота
3. локализуемость

С первым критерием разобрались быстро: достаточно было посмотреть, как сделаны переключатели часовых поясов в любой ОС с GUI — да хоть в Windows.

С полнотой проблем тоже не было — в PHP уже имеется класс [DateTimeZone](http://php.net/manual/en/class.datetimezone.php), с помощью которого можно получить список идентификаторов часовых поясов и всю информацию о них. Обновляется он отдельно от системы и ее tzdata, поэтому до сих пор в некоторых дистрибутивах Москва, например, проходит как GMT+04:00 — проблему эту можно устранить, [установив PECL'овский пакет timezonedb](http://php.net/manual/en/datetime.installation.php).

Самые большие проблемы создала локализация — проще говоря, перевод получаемого списка, который был целиком на английском, что уже было гвоздем в крышку гроба всевозможных благих начинаний.

Зарывшись в интернеты, используя гугл-фу [Александра Ушакова](https://www.facebook.com/alexander.ushakov.353), получилось выйти на класс [IntlTimeZone](http://php.net/manual/en/class.intltimezone.php) из пакета php5-intl, который делал то, что нужно: превращал “Europe/Moscow” в желанное “Московское время”. С одной лишь оговоркой: перевод был крайне платформозависимым: так, на FreeBSD “Europe/Moscow” переводилось как “Москва время”, а в Linux — как “Россия (Москва)”. Учитывая такие различия, сосредоточились на production-варианте. Вторым смертным грехом было отсутствие документации на пакет [Intl (Internationalization Functions)](http://php.net/manual/en/book.intl.php), в результате на руках у нас зачаствую были лишь имена методов, иногда их описания и имена аргументов.

Первое, что выяснилось — что IntlTimeZone не очень хорошо подходит для получения аббревиатур часовых поясов. Однако, в этом себя отлично проявляет класс [DateTimeZone](http://php.net/manual/en/class.datetimezone.php). Поэтому, была написана первая функция, получающая аббревиатуру (“EET”) для идентификатора часового пояса (“Europe/Kaliningrad”):

    <?php
    /**
     * Gets timezone abbreviation from the timezone identifier.
     *
     * @param string $identifier Timezone identifier (e.g. Europe/Moscow)
     *
     * @return string Abbreviation (e.g. MSK)
     */
    public static function getTimeZoneAbbreviation($identifier)
    {
        $dt = new DateTime();
        $dtz = new DateTimeZone($identifier);

        return $dt->setTimezone($dtz)->format('T');
    }

Получаемый в результате список был бы исчерпывающим описанием всех часовых поясов, но возникла проблема: группировка. Без нее получалась полная каша. Используя штатные возможности DateTimeZone::listIdentifiers() можно было получать список по регионам, но от этого мы отказались сразу — регион очень мало говорит о стране, к которой принадлежит тот или иной идентификатор.

Что делать? Добавить к городам и областям страны, конечно же!  
Но вот только IntlTimeZone ничего не знает о странах.  
Но зато о них знает DateTimeZone, к которому IntlTimeZone приводится.  
Но DateTimeZone не может предоставить локализованное имя государства — только его двухбуквенный код.  
Но класс [Locale](http://php.net/manual/en/class.locale.php) может предоставить нам имя государства по связанной с ним локали.  
Но у нас нет локали, есть только двубуквенный код.  
Но метод Locale::getDisplayName() умный и с криво переданными ему локалями работает хорошо — скормить ему код страны под видом локали все-таки выйдет.

Итак, у нас есть города. Есть страны. Есть коды часовых поясов. Есть информация о смещении относительно UTC. Остается все собрать.

    /**
     * Gets localized list of timezones.
     *
     * @param string $locale Locale to get list for (e.g. en_US)
     *
     * @return array List of timezones
     */
    public static function getList($locale = 'en_US')
    {
        $tzs = [];

        $identifiers = DateTimeZone::listIdentifiers();
        foreach ($identifiers as $identifier) {
            // create date time zone from identifier
            $dtz = new DateTimeZone($identifier);

            // create timezone from identifier
            $tz = IntlTimeZone::createTimeZone($identifier);

            // get two-letter country code
            $countryCode = $dtz->getLocation()['country_code'];

            // get country name from country code
            $country = Locale::getDisplayName('_' . $countryCode, $locale);

            // replace [] with ()
            $country = str_replace(['[', ']'], ['(', ')'], $country);

            // time offset
            $offset = $dtz->getOffset(new DateTime());
            $sign = ($offset < 0) ? '-' : '+';
            $row = [
                'id' => $tz->getDisplayName(false, 3, $locale),
                'country' => $country,
                'code' => self::getTimeZoneAbbreviation($identifier),
                'offset' => $sign . date('H:i', $offset)
            ];

            // if IntlTimeZone is unaware of timezone ID, use identifier as name
            if ($tz->getID() == 'Etc/Unknown') {
                $identifier = explode('/', $identifier);
                $row['id'] = array_pop($identifier);
            }

            $tzs[] = $row;
        }

        self::sortList($tzs);

        return $tzs;
    }

Весь класс целиком доступен [в репозитории](https://bitbucket.org/torunar/tzs).

`Tzs::getList()` принимает на вход локаль языка, на котором нужно выводить список.

Такие вот веселые пироги получились. На исследования и написание кода ушло два или даже три дня работы, зато полученный список точно можно будет использовать в дальнейшем — и это уже совсем другая история…