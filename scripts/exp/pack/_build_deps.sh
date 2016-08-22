#!/usr/bin/env bash

set -e

if [[ $# != 1 ]];then
    echo "Usage: bash $0 <PREFIX>"
    exit 1
fi

BASEDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
export HR_PREFIX=${1}

if [[ ! "$HR_PREFIX" = /* ]]; then
    HR_PREFIX=$(pwd)/$HR_PREFIX
fi

source ${BASEDIR}/common.sh

mkdir -p $HR_CACHE
mkdir -p $HR_PREFIX

pip2 install -t $HR_PREFIX/lib/python2.7/dist-packages -r $BASEDIR/requirements
bash ${BASEDIR}/install_marytts.sh
bash ${BASEDIR}/install_manyears_deps.sh
bash ${BASEDIR}/install_vision_deps.sh
