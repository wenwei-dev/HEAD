#!/usr/bin/env bash

set -e

if [[ $# != 1 ]];then
    echo "Usage: bash $0 <PREFIX>"
    exit 1
fi

BASEDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
PREFIX=${1}
HR_CACHE=~/.hr/cache

wget_cache() {
    local url=$1
    local ofile=${2-${url##*/}}
    [[ -f ${HR_CACHE}/${ofile} ]] || wget ${url} -O ${HR_CACHE}/${ofile}
}

mkdir -p $HR_CACHE
mkdir -p $PREFIX
pip2 install -t $PREFIX/lib/python2.7/dist-packages -r $BASEDIR/requirements

wget_cache https://github.com/marytts/marytts/releases/download/v5.1.2/marytts-5.1.2.zip
unzip -od $PREFIX $HR_CACHE/marytts-5.1.2.zip
