set -e
mkdir -p build/debug
cd build/debug
time ( \
../../thirdparty/installed/common/bin/cmake \
    -DCMAKE_BUILD_TYPE=debug \
    -GNinja \
    ../.. \
&& ninja )