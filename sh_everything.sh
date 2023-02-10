#!/bin/bash

DIR_ROOT=$PWD

#
#
#
#
#

echo ""
echo "#################################################"
echo "#                                               #"
echo "# IF THIS SCRIPT FAIL -> TRY THOSE TWO COMMANDS #"
echo "# -> 'chmod u+x ./sh_everything.sh'              #"
echo "# -> './sh_everything.sh'                       #"
echo "#                                               #"
echo "#################################################"
echo ""

#
#
#
#
#

if [ -z "${EMSDK}" ]; then
  echo "the env var 'EMSDK' is missing, the web-wasm builds will be skipped"
  echo " => check the readme if you want to install emscripten"
  echo " => it emscripten is laready installed, you may just need to run '. ./emsdk_env.sh' in this terminal"
  WEB_WASM_AVAILABLE=no
else
  echo "the env var 'EMSDK' was found, the web-wasm builds will be included"
  WEB_WASM_AVAILABLE=yes
fi

#
#
#
#
#

echo "ensuring the thirdparties are installed"

chmod u+x ./sh_install_thirdparties.sh
./sh_install_thirdparties.sh not-interactive

#
#
#
#
#

echo "building thirdparties libraries"
echo "  native version"
cd ./thirdparties

make build_mode="release" build_platform="native" all -j4

case $WEB_WASM_AVAILABLE in
yes)
  echo "  web-wasm version"
  make build_mode="release" build_platform="web-wasm" all -j4
  ;;
esac

cd $DIR_ROOT

#
#
#
#
#

echo "building projects application"
echo "  native version"
make build_mode="release" build_platform="native" all -j4

case $WEB_WASM_AVAILABLE in
yes)
  echo "  web-wasm version"
  make build_mode="release" build_platform="web-wasm" all -j4
  ;;
esac

#
#
#
#
#

case $WEB_WASM_AVAILABLE in
yes)
  echo "building web-wasm-loader"
  cd ./web-wasm-loader
  npm install
  npm run build
  cd $DIR_ROOT
  ;;
esac

