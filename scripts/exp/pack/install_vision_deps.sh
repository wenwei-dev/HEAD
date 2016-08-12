#!/usr/bin/env bash

source $(dirname $(readlink -f ${BASH_SOURCE[0]}))/common.sh
set -e

install_dlib() {
    wget_cache http://dlib.net/files/dlib-${DLIB_VERSION}.tar.bz2 dlib.tar.bz2
    tar jxf ${HR_CACHE}/dlib.tar.bz2 -C /tmp
    mkdir -p $DLIB_PATH
    mkdir -p $DLIB_PATH/lib/python2.7/site-packages
    mkdir -p /tmp/dlib-${DLIB_VERSION}/build
    cd /tmp/dlib-${DLIB_VERSION}/build && cmake -DCMAKE_INSTALL_PREFIX=${DLIB_PATH} .. && make -j$(nproc) && make install
    cd /tmp/dlib-${DLIB_VERSION} && PYTHONPATH=$PYTHONPATH:$DLIB_PATH/lib/python2.7/site-packages python setup.py install --prefix=$DLIB_PATH
    rm -r /tmp/dlib-${DLIB_VERSION}
}

install_torch() {
    wget_cache https://github.com/hansonrobotics/distro/releases/download/v1.0.0/torch.tar.gz
    mkdir -p /tmp/torch
    tar zxf ${HR_CACHE}/torch.tar.gz -C /tmp/torch

    # TODO
    #bash install-deps

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

    local model_dir=$OPENFACE_DIR/models
    mkdir -p $model_dir/dlib
    if [[ ! -f $model_dir/dlib/shape_predictor_68_face_landmarks.dat ]]; then
        wget_cache http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2
        cp ${HR_CACHE}/shape_predictor_68_face_landmarks.dat.bz2 $model_dir/dlib
        bunzip2 ${model_dir}/dlib/shape_predictor_68_face_landmarks.dat.bz2
        checkmd5 ${model_dir}/dlib/shape_predictor_68_face_landmarks.dat 73fde5e05226548677a050913eed4e04 || rm $model_dir/dlib/shape_predictor_68_face_landmarks.dat
    fi

    mkdir -p $model_dir/openface
    if [[ ! -f $model_dir/openface/nn4.small2.v1.t7 ]]; then
        wget_cache http://openface-models.storage.cmusatyalab.org/nn4.small2.v1.t7
        cp ${HR_CACHE}/nn4.small2.v1.t7 $model_dir/openface
        checkmd5 ${model_dir}/openface/nn4.small2.v1.t7 c95bfd8cc1adf05210e979ff623013b6 || rm ${model_dir}/openface/nn4.small2.v1.t7
    fi
    if [[ ! -f $model_dir/openface/celeb-classifier.nn4.small2.v1.pkl ]]; then
        wget_cache http://openface-models.storage.cmusatyalab.org/celeb-classifier.nn4.small2.v1.pkl
        cp ${HR_CACHE}/celeb-classifier.nn4.small2.v1.pkl $model_dir/openface
        checkmd5 ${model_dir}/openface/celeb-classifier.nn4.small2.v1.pkl 199a2c0d32fd0f22f14ad2d248280475 || rm ${model_dir}/openface/celeb-classifier.nn4.small2.v1.pkl
    fi
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
