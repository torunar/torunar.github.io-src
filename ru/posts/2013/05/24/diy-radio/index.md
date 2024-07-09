# MPD + NCMPCPP + Icecast2: интернет-радио из палок и желудей

* * *
Идея организации потокового вещания в сети посещала меня еще с начала года: возможность слушать музыку, находящуюся на домашней машине, в любом месте, где есть интернет — весьма заманчивая перспектива.
* * *

Предприняв несколько неудачных попыток и отказавшись от множества неподходящих решений, только несколько дней назад смог добиться желаемого.

Для осуществления затеи понадобятся:

- MPD — Music Player Daemon. MPD — штука настолько же уникальная, насколько и универсальная. Он предоставляет возможность воспроизведения музыки по клиент-серверной технологии.
- NCMPCPP — собственно, клиент для MPD, через который мы будем играть музыку.
- Icecast2 — ПО для организации потокового цифрового аудио и видеовещания. Icecast2 предоставляет возможность организации трансляции в форматах HTTP и SHOUTcast. В принципе, обойтись можно было и без него, поскольку MPD умеет самостоятельно воспроизводить музыку по HTTP, но… Многие аудиоплееры, например, старый Winamp, которым я пользуюсь в Windows, или же радиоплеер моей PSP, умеют работать с трансляциями исключительно по протоколу SHOUTcast. Кроме того, Icecast2 предоставляет информационную веб-страницу, на которой отображается текущий статус вещания.

Ставим все необходимые пакеты:

    sudo apt-get install mpd ncmpcpp icecast2

При установке Icecast2 предложит провести первичную настройку — этот пункт можно спокойно пропускать, конфиг все равно придется переписывать.

  
### MPD

Правим файл настройки, расположенный в /etc/mpd.conf:

    # Directories
    music_directory           "MUSIC_DIR"
    playlist_directory        "/home/USER/.mpd/playlists"
    db_file                   "/home/USER/.mpd/tag_cache"
    log_file                  "/var/log/mpd/mpd.log"
    pid_file                  "/home/USER/.mpd/pid"
    state_file                "/home/USER/.mpd/state"
    sticker_file              "/home/USER/.mpd/sticker.sql"
    
    # Permissions
    user                      "USER"
    #group                    "nogroup"
    
    # Network
    bind_to_address           "localhost"
    port                      "MPD_PORT"
    
    # Log
    log_level                 "default"
    
    # Playback
    gapless_mp3_playback      "yes"
    follow_outside_symlinks   "yes"
    follow_inside_symlinks    "yes"
    
    # Buffering
    audio_buffer_size         "2048"
    buffer_before_play        "5%"
    #max_output_buffer_size   "8192"
    
    # Playlist and DB
    save_absolute_paths_in_playlists  "yes"
    metadata_to_use           "artist,album,title,track,name"
    auto_update               "yes"
    auto_update_depth         "10"
    #max_playlist_length      "16384"
    
    # Clients' connection
    connection_timeout        "30"
    max_connections           "10"
    #max_command_list_size    "2048"
    
    # Charsets
    filesystem_charset        "UTF-8"
    id3v1_encoding            "WINDOWS 1251"
    
    # Zeroconf and Avahi
    zeroconf_enabled          "no"
    #zeroconf_name            "Music Player"
    
    # Input
    input {
            plugin "curl"
    }
    
    mixer_type                "software"
    
    # ALSA
    #audio_output {
    # type           "alsa"
    # name           "alsa"
    # device         "hw:0,0"
    # format         "44100:16:2"
    # mixer_device   "default"
    # mixer_control  "PCM"
    # mixer_index    "0"
    #}
    
    # IceCast
    audio_output {
      type         "shout"
      encoding     "ogg"
      name         "icecast"
      host         "localhost"
      port         "PORT"
      mount        "/radio.ogg"
      password     "PASSWORD"
      quality      "5.0"
    # bitrate      "128"
      format       "44100:16:1"
      protocol     "icecast2"
    # user         "source"
      description  "DESCRIPTION"
      genre        "GENRE"
      public       "yes"
      timeout      "120"
    }
    
    # Pulse
    audio_output {
      type    "pulse"
      name    "pulseauido"
    }

Здесь необходимо указать:

- `MUSIC_DIR` — папка, где лежит музыка.
- `MPD_PORT` — порт, на котором MPD будет висеть в самой системе.
- `PORT` — порт, на котором будет висеть Icecast2. Не должен совпадать с `MPD_PORT`!
- `USER` — пользователь, от которого будет запущен MPD. Рекомендую указывать того пользователя, под которым осуществляется работа, в этом случае MPD не будет вступать в соревнование за систему аудиовывода.
- `PASSWORD` — пароль на подключение к Icecast2.
- `DESCRIPTION` — описание радиостанции.
- `GENRE` — жанр радиостанции.

В данном конфиге приведен пример вывода звука через Pulseaudio. Если предпочитаете ALSA — просто закоментируйте секцию Pulseaudio и раскоменнтируйте нужное.

Настройка MPD на этом еще не закончена. Чтобы он работал с указанными папками, необходимо:

    $ mkdir ~/.mpd
    $ mkdir ~/.mpd/playlists
    $ cp /var/lib/mpd/tag_cache ~/.mpd/
    $ sudo service mpd restart

Если все сделано правильно, MPD должен перезапуститься с новыми настройками.

  
### NCMPCPP

Создаем копию стандартного файла настройки:

    $ mdkir ~/.ncmpcpp
    $ cp /usr/share/doc/ncmpcpp/examples/* ~/.ncmpcpp/
    
После чего правим файл настройки, расположенный в ~/.ncmpcpp/config:

    # MPD settings
    mpd_host = "localhost"
    mpd_port = "MPD_PORT"
    mpd_music_dir = "MUSIC_DIR"
    mpd_connection_timeout = "40"
    mpd_crossfade_time = "2"
    
    # Charset
    system_encoding = "UTF-8"
    
    # Delays
    playlist_disable_highlight_delay = "5"
    message_delay_time = "4"
    
    # UI format
    song_list_format = "{%a - }{%t}|{$8%f$9}$R{(%l)$9}"
    song_status_format = "{%a - }{%t}{ (%b)}|{%f}"
    song_library_format = "{%n - }{%t}|{%f}"
    tag_editor_album_format = "{(%y) }%b"
    now_playing_prefix = "$b"
    now_playing_suffix = "$/b"
    browser_playlist_prefix = "$2playlist$9 "
    selected_item_prefix = "$6"
    selected_item_suffix = "$9"
    song_window_title_format = "{%a - }{%t}|{%f}"
    song_columns_list_format = "(7f)[green]{l} (25)[cyan]{a} (40)[]{t|f} (30)[red]{b}"
    
    # UI settings
    user_interface = "classic"
    browser_display_mode = "classic"
    search_engine_display_mode = "classic"
    discard_colors_if_item_is_selected = "yes"
    autocenter_mode = "no"
    centered_cursor = "no"
    progressbar_look = "=>"
    header_visibility = "yes"
    statusbar_visibility = "yes"
    titles_visibility = "yes"
    header_text_scrolling = "no"
    fancy_scrolling = "no"
    cyclic_scrolling = "no"
    lines_scrolled = "2"
    enable_window_title = "yes"
    display_remaining_time = "no"
    clock_display_seconds = "no"
    display_volume_level = "yes"
    display_bitrate = "yes"
    
    # Screens
    display_screens_numbers_on_start = "no"
    screen_switcher_mode = "sequence: 2 -> 3"
    startup_screen = "2"
    
    # Playlist and media library
    show_hidden_files_in_local_browser = "no"
    allow_physical_files_deletion = "no"
    allow_physical_directories_deletion = "no"
    ask_before_clearing_main_playlist = "no"
    ncmpc_like_songs_adding = "no"
    jump_to_now_playing_song_at_start = "yes"
    ignore_leading_the = "no"
    empty_tag_marker = "<...>"
    media_library_display_date = "no"
    media_library_display_empty_tag = "no"
    media_library_disable_two_column_mode = "yes"
    media_library_left_column = "a"
    playlist_show_remaining_time = "no"
    playlist_shorten_total_times = "no"
    playlist_separate_albums = "no"
    playlist_display_mode = "classic"
    default_space_mode = "add"
    
    # Seeking
    incremental_seeking = "yes"
    seek_time = "5"
    
    # Search
    default_place_to_search_in = "database"
    default_find_mode = "wrapped"
    regular_expressions = "basic"
    block_search_constraints_change_if_items_found = "yes"
    
    # Mouse
    mouse_support = "yes"
    mouse_list_scroll_whole_page = "no"
    search_engine_default_search_mode = "1"
    
    # Exec
    execute_on_song_change = ""
    
    # Tag editor
    default_tag_editor_left_col = "dirs"
    default_tag_editor_pattern = "%n - %t"
    external_editor = "vim"
    use_console_editor = "yes"
    tag_editor_extended_numeration = "no"
    
    # Colors
    colors_enabled = "yes"
    empty_tag_color = "cyan"
    header_window_color = "default"
    volume_color = "white"
    state_line_color = "default"
    state_flags_color = "default"
    main_window_color = "white"
    color1 = "white"
    color2 = "white"
    main_window_highlight_color = "blue"
    progressbar_color = "white"
    statusbar_color = "grey"
    active_column_color = "cyan"
    visualizer_color = "yellow"
    window_border_color = "white"
    active_window_border = "white"

Как видно, большая часть конфига представляет из себя описание интерфейса плеера, а в задании нуждаются `MPD_PORT` и `MUSIC_DIR`, описанные выше.

Помимо интерфейсных настроек, я заменил еще и клавиатурные сочетания, чтобы максимально приблизить NCMPCPP к уже привычному MOC — они настраиваются в ~/.ncmpcpp/keys:

    key_up = 259
    key_down = 258
    key_up_album = 0
    key_down_album = 0
    key_up_artist = 0
    key_down_artist = 0
    key_page_up = 339
    key_page_down = 338
    key_home = 262
    key_end = 360
    key_space = 'a'
    key_enter = 10
    key_delete = 330 'd'
    key_volume_up = '.'
    key_volume_down = ','
    key_prev_column = 0
    key_next_column = 0
    key_toggle_space_mode = 0
    key_toggle_add_mode = 0
    key_toggle_mouse = 0
    key_toggle_bitrate_visibility = 0
    key_screen_switcher = 9
    key_help = '1'
    key_playlist = '2'
    key_browser = '3'
    key_search_engine = '4'
    key_media_library = 0
    key_playlist_editor = 0
    key_tag_editor = 0
    key_outputs = '6'
    key_music_visualizer = 0
    key_clock = 0
    key_server_info = '5'
    key_stop = 's'
    key_pause = 32 'p'
    key_next = 'n'
    key_prev = 'b'
    key_replay = 263 127
    key_seek_forward = 261
    key_seek_backward = 260
    key_toggle_repeat = 'R'
    key_toggle_random = 'S'
    key_toggle_single = 0
    key_toggle_consume = 0
    key_toggle_replay_gain_mode = 0
    key_shuffle = 0
    key_toggle_crossfade = 0
    key_set_crossfade = 0
    key_update_db = 'U'
    key_sort_playlist = 22
    key_apply_filter = 6
    key_find_forward = '/'
    key_find_backward = '?'
    key_next_found_position = 0
    key_prev_found_position = 0
    key_toggle_find_mode = 0
    key_edit_tags = 0
    key_go_to_position = 'J'
    key_song_info = 0
    key_artist_info = 0
    key_lyrics = 0
    key_reverse_selection = 0
    key_deselect_all = 0
    key_select_album = 0
    key_add_selected_items = 0
    key_clear = 'C'
    key_crop = 0
    key_move_song_up = 'u'
    key_move_song_down = 'j'
    key_move_to = 0
    key_move_before = 0
    key_move_after = 0
    key_add = 0
    key_save_playlist = 0
    key_go_to_now_playing = 0
    key_toggle_auto_center = 0
    key_toggle_display_mode = 0
    key_toggle_separators_in_playlist = 0
    key_toggle_lyrics_db = 0
    key_go_to_containing_directory = 0
    key_go_to_media_library = '~'
    key_go_to_parent_dir = 263 127
    key_switch_tag_type_list = 0
    key_quit = 'Q'

Указанных настроек достаточно, чтобы начать слушать музыку через MPD локально: запустите в консоли ncmpcpp, обновите музыкальную базу (U) и поставьте что-нибудь на воспроизведение. Убедитесь, что на вкладке источников (6) выбран pulseaudio/alsa.

  
### Icecast2

Правим файл настройки, расположенный в /etc/icecast2/icecast.xml:

    <icecast>
        <limits>
            <clients>10</clients>
            <sources>1</sources>
            <threadpool>5</threadpool>
            <queue-size>524288</queue-size>
            <client-timeout>60</client-timeout>
            <header-timeout>30</header-timeout>
            <source-timeout>20</source-timeout>
            <burst-on-connect>1</burst-on-connect>
            <burst-size>65535</burst-size>
        </limits>
    
        <authentication>
            <source-password>PASSWORD</source-password>
            <relay-password>PASSWORD</relay-password>
            <admin-user>admin</admin-user>
            <admin-password>PASSWORD</admin-password>
        </authentication>
    
        <shoutcast-mount>/radio.ogg</shoutcast-mount>
    
        <hostname>HOST</hostname>
        <listen-socket>
            <port>PORT</port>
        </listen-socket>
    
        <fileserve>1</fileserve>
        <paths>
            <basedir>/usr/share/icecast2</basedir>
            <logdir>/var/log/icecast2</logdir>
            <webroot>/usr/share/icecast2/web</webroot>
            <adminroot>/usr/share/icecast2/admin</adminroot>
            <alias source="/radio" dest="/radio.ogg"/>
            <alias source="/play" dest="/radio.ogg"/>
            <alias source="/" dest="/status.xsl"/>
            <alias source="/status" dest="/status.xsl"/>
            <alias source="/status/" dest="/status.xsl"/>
        </paths>
    
        <logging>
            <accesslog>access.log</accesslog>
            <errorlog>error.log</errorlog>
            <loglevel>3</loglevel> <!-- 4 Debug, 3 Info, 2 Warn, 1 Error -->
            <logsize>10000</logsize> <!-- Max size of a logfile -->
            <logarchive>1</logarchive>
        </logging>
    
        <security>
            <chroot>0</chroot>
            <!--
            <changeowner>
                <user>nobody</user>
                <group>nogroup</group>
            </changeowner>
            -->
        </security>
    </icecast>

Здесь нужно указать те же `PORT` и `PASSWORD`, что и при настройке MPD. В качестве HOST указывается адрес, на котором будет вещать радио.

Если есть желание сделать все более безопасным, можно зачрутить работу демона — выставьте последний параметр в единицу и укажите пользователя и группу. Также придется переписать настройки папок, чтобы они были относительными для basedir.

Чтобы проверить, работает ли Icecast2 как таковой, зайдите в браузере по адресу `http://HOST:PORT` — должна загрузиться стандартная страница статуса сервера.

### Палки и желуди

Последний рывок. Чтобы наконец-то начать вещание, запустите ncmpcpp, на экране источников включите icecast, заполните плейлист и начните воспроизведение.

На странице статуса Icecast2 в графе Current Song должно показаться название воспроизводимой композиции, а само радио можно слушать в браузере или любом умеющем потоковые трансляции плеере по адресу `http://HOST:PORT/radio.ogg`. Проверена работоспособность в MOC, VLC, MPlayer, Media Player и Winamp.