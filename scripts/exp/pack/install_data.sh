#!/usr/bin/env bash

source $(dirname $(readlink -f ${BASH_SOURCE[0]}))/common.sh
set -e

install_openface_data() {
    mkdir -p $HR_PREFIX/data/openface/models
    local model_dir=$HR_PREFIX/data/openface/models
    mkdir -p $model_dir/dlib
    if [[ ! -f $model_dir/dlib/shape_predictor_68_face_landmarks.dat ]]; then
        wget_cache http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2
        cp ${HR_CACHE}/shape_predictor_68_face_landmarks.dat.bz2 $model_dir/dlib
        bunzip2 ${model_dir}/dlib/shape_predictor_68_face_landmarks.dat.bz2
        checkmd5 ${model_dir}/dlib/shape_predictor_68_face_landmarks.dat 73fde5e05226548677a050913eed4e04 || rm $model_dir/dlib/shape_predictor_68_face_landmarks.dat
    else
        info "shape_predictor_68_face_landmarks.dat already exists"
    fi

    mkdir -p $model_dir/openface
    if [[ ! -f $model_dir/openface/nn4.small2.v1.t7 ]]; then
        wget_cache http://openface-models.storage.cmusatyalab.org/nn4.small2.v1.t7
        cp ${HR_CACHE}/nn4.small2.v1.t7 $model_dir/openface
        checkmd5 ${model_dir}/openface/nn4.small2.v1.t7 c95bfd8cc1adf05210e979ff623013b6 || rm ${model_dir}/openface/nn4.small2.v1.t7
    else
        info "nn4.small2.v1.t7 already exists"
    fi
    if [[ ! -f $model_dir/openface/celeb-classifier.nn4.small2.v1.pkl ]]; then
        wget_cache http://openface-models.storage.cmusatyalab.org/celeb-classifier.nn4.small2.v1.pkl
        cp ${HR_CACHE}/celeb-classifier.nn4.small2.v1.pkl $model_dir/openface
        checkmd5 ${model_dir}/openface/celeb-classifier.nn4.small2.v1.pkl 199a2c0d32fd0f22f14ad2d248280475 || rm ${model_dir}/openface/celeb-classifier.nn4.small2.v1.pkl
    else
        info "celeb-classifier.nn4.small2.v1.pkl already exists"
    fi
}

install_openface_data
