#!/usr/bin/env bash

_BASEDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
source ${_BASEDIR}/config.sh
unset _BASEDIR

COLOR_INFO='\033[32m'
COLOR_WARN='\033[33m'
COLOR_ERROR='\033[31m'
COLOR_RESET='\033[0m'
info() {
    printf "${COLOR_INFO}[INFO] ${1}${COLOR_RESET}\n"
}
warn() {
    printf "${COLOR_WARN}[WARN] ${1}${COLOR_RESET}\n"
}
error() {
    printf "${COLOR_ERROR}[ERROR] ${1}${COLOR_RESET}\n"
}

wget_cache() {
    local url=$1
    local ofile=${2-${url##*/}}
    [[ -f ${HR_CACHE}/${ofile} ]] || wget ${url} -O ${HR_CACHE}/${ofile}
}

md5str() {
  local FNAME=$1
  case $(uname) in
    "Linux")
      echo $(md5sum "$FNAME" | cut -d ' ' -f 1)
      ;;
    "Darwin")
      echo $(md5 -q "$FNAME")
      ;;
  esac
}

checkmd5() {
    local FNAME=$1
    if [[ ! -f $FNAME ]]; then
        error "$FNAME is not a file"
        return 1
    fi
    local EXPECTED=$2
    local ACTUAL=$(md5str "$FNAME")
    if [ $EXPECTED = $ACTUAL ]; then
        info "$FNAME: successfully checked"
        return 0
    else
        error "$FNAME md5sum did not match."
        error "Expected: $EXPECTED"
        error "Actual: $ACTUAL"
        rm $FNAME && warn "$FNAME is removed"
        return 1
    fi
}
