#!/usr/bin/env bash

trap 'rm -f /tmp/hr' SIGINT SIGTERM EXIT

get_hr() {
    if hash hr 1>/dev/null 2>&1; then
        echo "hr has already been installed."
        echo "Run 'hr update hr' to update it."
        exit
    fi
    local url=https://raw.githubusercontent.com/hansonrobotics/HEAD/master/scripts/hr/hr
    local file=/tmp/hr
    curl -sLo $file ${url}
    bash_flag=$(file $file | grep bash | wc -l)
    if [[ $bash_flag != "1" ]]; then
        echo "Can't get hr"
        exit 1
    fi
    bash $file install hr
    rm -f $file
}

get_hr
