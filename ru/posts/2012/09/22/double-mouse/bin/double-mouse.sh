#!/usr/bin/env bash
vendor="Elantech"
if [ $1 ]; then
    case $1 in
        'on')
            active=$(xinput list | grep 'Auxiliary pointer')
            if [ -n "$active" ]; then
                echo 'Already active'
            else
                touchpad=$(xinput list | grep "$vendor" | egrep -o '=[0-9]*' | egrep -o '[0-9]{1,2}')
                xinput create-master Auxiliary
                xinput reattach $touchpad "Auxiliary pointer"
            fi
            ;;
        'off')
            active=$(xinput list | grep 'Auxiliary pointer')
            if [ -z "$active" ]; then
                echo 'Already inactive'
            else
                touchpad=$(xinput list | grep "$vendor" | egrep -o '=[0-9]*' | egrep -o '[0-9]{1,2}')
                group=$(xinput list | grep 'Auxiliary pointer' | egrep -o '=[0-9]*' | egrep -o '[0-9]{1,2}')
                xinput reattach $touchpad "Virtual core pointer"
                xinput remove-master $group
            fi
            ;;
        *)
            echo 'Usage: double-mouse.sh on|off'
            ;;
    esac
else
    echo 'Usage: double-mouse.sh on|off'
fi