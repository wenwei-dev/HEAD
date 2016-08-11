#!/usr/bin/env bash

source $(dirname $(readlink -f ${BASH_SOURCE[0]}))/common.sh
wget_cache https://github.com/hansonrobotics/manyears-C/archive/v1.0.1.tar.gz manyears.v1.0.1.tar.gz

info "Installing manyears"
manyears_dir=/tmp/manyears-C-1.0.1
rm -rf ${manyears_dir}
tar zxf $HR_CACHE/manyears.v1.0.1.tar.gz -C /tmp
cd ${manyears_dir} && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=${MANYEARSLIB_PREFIX} .. && make && make install
rm -rf ${manyears_dir}
