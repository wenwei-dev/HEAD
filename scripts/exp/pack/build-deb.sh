#!/usr/bin/env bash

set -e

BASEDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
$BASEDIR/../../hrtool -r set_env
source $BASEDIR/../../env.sh

PROJECT=${PROJECT:-HEAD}

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

build_deb_package() {
    info "Building DEB package"
    # sudo apt-get -y install packaging-dev
    local archive="head-${HR_VERSION}.tar.gz"
    local build_dir=$HR_WORKSPACE/build-area
    local workspace=${build_dir}/head-${HR_VERSION}
    info "Build directory ${build_dir}"
    cd $HR_WORKSPACE/$PROJECT
    git archive --format=tar.gz --prefix=head-${HR_VERSION}/ HEAD > $archive
    if [[ -d $workspace ]]; then
        rm -r $workspace
    fi
    mkdir -p ${build_dir}
    tar zxf $archive -C ${build_dir}
    cd $workspace

    install_target=$workspace/install/lib/python2.7/dist-packages/
    deps_target=$workspace/depends
cat <<EOF > _build.sh
#!/usr/bin/env bash
set -e
source /opt/ros/indigo/setup.bash
catkin init
catkin build -c -j$(nproc) --make-args install
pip2 install -t $install_target $workspace/src/hardware/pololu-motors --upgrade --no-deps
pip3 install -t $install_target $workspace/src/blender_api_msgs --upgrade --no-deps

EOF

cat <<EOF > _build_deps.sh
mkdir -p $deps_target
pip2 install -t $deps_target/lib/python2.7/dist-packages Flask==0.11.1, pinyin==0.2.5, EasyProcess==0.1.9, psutil==1.2.1, pyparsing==2.1.5

if [[ ! -f /tmp/marytts-5.1.2.zip ]]; then
  wget https://github.com/marytts/marytts/releases/download/v5.1.2/marytts-5.1.2.zip -O /tmp/marytts-5.1.2.zip
fi
unzip -od $deps_target /tmp/marytts-5.1.2.zip
EOF

cat <<EOF > _clean.sh
#!/usr/bin/env bash
set -e
catkin init
catkin clean -y || true
rm -rf .catkin_tools
rm -f $workspace/scripts/env.sh
EOF

    dh_make --yes --single --createorig || true
    dpkg-buildpackage -b
}

build_deb_package
