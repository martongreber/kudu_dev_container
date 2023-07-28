set -e
mkdir -p build/asan
cd build/asan
# For sanitizer builds clang needs to be used
export CLANG=$KUDU_HOME/build-support/ccache-clang/clang
time ( \
CC=${CLANG} CXX=${CLANG}++ ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=fastdebug\
  -DKUDU_LINK=dynamic\
  -DKUDU_USE_ASAN=1 \
  -DKUDU_USE_UBSAN=1 \
  -GNinja \
  ../.. \
&& ninja )