#!/usr/bin/env bash

source $(dirname $(readlink -f ${BASH_SOURCE[0]}))/common.sh
set -e

install_dlib() {
    local dlib_version=19.0
    wget_cache https://raw.githubusercontent.com/hansonrobotics/binary_dependency/master/src/dlib-${dlib_version}.tar.bz2
    # original link
    # wget_cache http://dlib.net/files/dlib-${dlib_version}.tar.bz2 dlib-${dlib_version}.tar.bz2
    rm -rf /tmp/dlib
    tar jxf ${HR_CACHE}/dlib-${dlib_version}.tar.bz2 -C /tmp
    mv /tmp/dlib-${dlib_version} /tmp/dlib
    # mkdir -p $DLIB_PATH
    # mkdir -p $DLIB_PATH/lib/python2.7/site-packages
    # mkdir -p /tmp/dlib-${dlib_version}/build
    # cd /tmp/dlib-${dlib_version}/build && cmake -DCMAKE_INSTALL_PREFIX=${DLIB_PATH} .. && make -j$(nproc) && make install
    # cd /tmp/dlib-${dlib_version} && PYTHONPATH=$PYTHONPATH:$DLIB_PATH/lib/python2.7/site-packages python setup.py install --prefix=$DLIB_PATH
    # rm -r /tmp/dlib
}

install_torch() {
    wget_cache https://github.com/hansonrobotics/distro/releases/download/v1.0.0/torch.tar.gz
    mkdir -p /tmp/torch
    tar zxf ${HR_CACHE}/torch.tar.gz -C /tmp/torch

    # TODO
    #bash install-deps
    # sudo apt-get update
    # sudo apt-get install -y build-essential gcc g++ curl cmake libreadline-dev git-core libqt4-dev libjpeg-dev libpng-dev ncurses-dev imagemagick libzmq3-dev gfortran unzip gnuplot gnuplot-x11 libopenblas-dev liblapack-dev libqt4-core libqt4-gui

    mkdir -p $TORCH_DIR
    cd /tmp/torch
    echo no | PREFIX=$TORCH_DIR ./install.sh

    cd $TORCH_DIR/bin
    ./luarocks install nn
    ./luarocks install dpnn
    ./luarocks install image
    ./luarocks install optim
    ./luarocks install csvigo
    ./luarocks install sys

    rm $TORCH_DIR/install.log
    #rm -r /tmp/torch
}

install_openface() {
    wget_cache https://github.com/hansonrobotics/openface/archive/master.tar.gz openface.tar.gz
    tar zxf ${HR_CACHE}/openface.tar.gz -C /tmp
    mkdir -p $OPENFACE_DIR
    cp -r /tmp/openface-master/* $OPENFACE_DIR
    rm -r /tmp/openface-master
}

install_emotime() {
    wget_cache https://github.com/hansonrobotics/emotime/archive/master.tar.gz emotime.tar.gz
    tar zxf ${HR_CACHE}/emotime.tar.gz -C /tmp
    mkdir -p /tmp/emotime-master/build
    cd /tmp/emotime-master/build && cmake -DCMAKE_INSTALL_PREFIX=${EMOTIME_DIR} .. && make -j$(nproc) && make install
    rm -r /tmp/emotime-master
}

install_cppmt() {
    wget_cache https://github.com/hansonrobotics/CppMT/archive/wrapper.tar.gz CppMT.tar.gz
    tar zxf ${HR_CACHE}/CppMT.tar.gz -C /tmp
    mkdir -p /tmp/CppMT-wrapper/build
    cd /tmp/CppMT-wrapper/build && cmake -DCMAKE_INSTALL_PREFIX=${CPPMT_DIR} .. && make -j$(nproc) && make install
}

install_dlib
install_torch
install_openface
install_emotime
install_cppmt
