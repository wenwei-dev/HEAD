#!/usr/bin/env bash

source $(dirname $(readlink -f ${BASH_SOURCE[0]}))/common.sh
wget_cache https://github.com/marytts/marytts/releases/download/v5.1.2/marytts-5.1.2.zip
info "Unzipping marytts"
unzip -od $HR_PREFIX $HR_CACHE/marytts-5.1.2.zip
mv $HR_PREFIX/marytts-5.1.2 $HR_PREFIX/marytts
