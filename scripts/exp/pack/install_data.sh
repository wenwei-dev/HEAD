#!/usr/bin/env bash

source $(dirname $(readlink -f ${BASH_SOURCE[0]}))/common.sh
set -e

install_openface_data() {
    local data_dir=$HR_PREFIX/data/openface/models

    mkdir -p $data_dir/dlib
    wget_cache http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2
    cp ${HR_CACHE}/shape_predictor_68_face_landmarks.dat.bz2 $data_dir/dlib
    bunzip2 -f ${data_dir}/dlib/shape_predictor_68_face_landmarks.dat.bz2
    checkmd5 ${data_dir}/dlib/shape_predictor_68_face_landmarks.dat 73fde5e05226548677a050913eed4e04

    mkdir -p $data_dir/openface
    wget_cache http://openface-models.storage.cmusatyalab.org/nn4.small2.v1.t7
    cp ${HR_CACHE}/nn4.small2.v1.t7 $data_dir/openface
    checkmd5 ${data_dir}/openface/nn4.small2.v1.t7 c95bfd8cc1adf05210e979ff623013b6

    wget_cache http://openface-models.storage.cmusatyalab.org/celeb-classifier.nn4.small2.v1.pkl
    cp ${HR_CACHE}/celeb-classifier.nn4.small2.v1.pkl $data_dir/openface
    checkmd5 ${data_dir}/openface/celeb-classifier.nn4.small2.v1.pkl 199a2c0d32fd0f22f14ad2d248280475
}

install_opencog_data() {
    local data_dir=$HR_PREFIX/data/opencog
    mkdir -p $data_dir
    wget_cache https://github.com/opencog/test-datasets/releases/download/current/aiml-current.tar.gz
    cp ${HR_CACHE}/aiml-current.tar.gz $data_dir
    checkmd5 ${data_dir}/aiml-current.tar.gz 5beae2c6848b93d5d29a1474590cb0fa

    wget_cache https://github.com/opencog/test-datasets/releases/download/current/markov_modeling.tar.gz
    cp ${HR_CACHE}/markov_modeling.tar.gz $data_dir
    checkmd5 ${data_dir}/markov_modeling.tar.gz 77d0a3e130f0339c501f929de54ba36a
}

install_openface_data
install_opencog_data
