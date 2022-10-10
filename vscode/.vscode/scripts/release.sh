set -e
cd build/release
time ( \
../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=release\
  -DKUDU_LINK=dynamic\
  -GNinja \
  ../.. \
&& ninja )