# ---- Dev ----
FROM ubuntu:18.04 as dev

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y git 
ENV DEBIAN_FRONTEND=

RUN git clone https://github.com/apache/kudu.git 

ARG BUILD_DIR="/kudu"
WORKDIR ${BUILD_DIR}

RUN ./docker/bootstrap-dev-env.sh \
  && ./docker/bootstrap-java-env.sh \
  && ./docker/bootstrap-python-env.sh 

ENV PATH /usr/lib/ccache:/usr/lib64/ccache/:$PATH

CMD ["/bin/bash"]

# ---- Thirdparty ----
FROM dev AS thirdparty

ARG BUILD_DIR="/kudu"
WORKDIR ${BUILD_DIR}
RUN thirdparty/build-if-necessary.sh \
  # Remove the files left behind that we don't need.
  # Remove all the source files except the hadoop, hive, postgresql, ranger, and sentry sources
  # which are pre-built and symlinked into the installed/common/opt directory.
  && find thirdparty/src/* -maxdepth 0 -type d  \
    \( ! -name 'hadoop-*' ! -name 'hive-*' ! -name 'postgresql-*' ! -name 'ranger-*' ! -name 'sentry-*' \) \
    -prune -exec rm -rf {} \; \
  # Remove all the build files except the llvm build which is symlinked into
  # the clang-toolchain directory.
  && find thirdparty/build/* -maxdepth 0 -type d ! -name 'llvm-*' -prune -exec rm -rf {} \;

CMD ["/bin/bash"]


# ---- Thirdparty all ----
FROM thirdparty AS thirdparty_all

ARG BUILD_DIR="/kudu"
WORKDIR ${BUILD_DIR}
RUN git pull
RUN thirdparty/build-if-necessary.sh all \
  # Remove the files left behind that we don't need.
  # Remove all the source files except the hadoop, hive, postgresql, ranger, and sentry sources
  # which are pre-built and symlinked into the installed/common/opt directory.
  && find thirdparty/src/* -maxdepth 0 -type d  \
    \( ! -name 'hadoop-*' ! -name 'hive-*' ! -name 'postgresql-*' ! -name 'ranger-*' ! -name 'sentry-*' \) \
    -prune -exec rm -rf {} \; \
  # Remove all the build files except the llvm build which is symlinked into
  # the clang-toolchain directory.
  && find thirdparty/build/* -maxdepth 0 -type d ! -name 'llvm-*' -prune -exec rm -rf {} \;


# Entry point to bash.
CMD ["/bin/bash"]


# ---- Debug ----
FROM thirdparty AS debug

ARG BUILD_DIR="/kudu"
ARG BUILD_TYPE=debug
ARG LINK_TYPE=dynamic

# Use the bash shell for all RUN commands.
# SHELL ["/bin/bash", "-c"]
WORKDIR ${BUILD_DIR}

RUN ccache -C
RUN ccache -M 10G

# Build the c++ code.
WORKDIR ${BUILD_DIR}/build/$BUILD_TYPE
# Enable the Gradle build cache in the C++ build.
ENV GRADLE_FLAGS="--build-cache"
# Ensure we don't rebuild thirdparty. Instead let docker handle caching.
ENV NO_REBUILD_THIRDPARTY=1
#build kudu -> basically populate ccache
RUN ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -GNinja \
  ../.. \
  && ninja 

#delete the build artefacts
RUN rm -rf ./*

# run cmake for convenience
RUN ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -GNinja \
  ../.. 

# Entry point to bash.
CMD ["/bin/bash"]

# ---- Release ----
FROM thirdparty AS release

ARG BUILD_DIR="/kudu"
ARG BUILD_TYPE=release
ARG LINK_TYPE=dynamic

# Use the bash shell for all RUN commands.
# SHELL ["/bin/bash", "-c"]
WORKDIR ${BUILD_DIR}

RUN ccache -C
RUN ccache -M 10G

# Build the c++ code.
WORKDIR ${BUILD_DIR}/build/$BUILD_TYPE
# Enable the Gradle build cache in the C++ build.
ENV GRADLE_FLAGS="--build-cache"
# Ensure we don't rebuild thirdparty. Instead let docker handle caching.
ENV NO_REBUILD_THIRDPARTY=1
#build kudu -> basically populate ccache
RUN ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -GNinja \
  ../.. \
  && ninja 

#delete the build artefacts
RUN rm -rf ./*

# run cmake for convenience
RUN ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -GNinja \
  ../.. 

# Entry point to bash.
CMD ["/bin/bash"]


# ---- Asan ----
FROM thirdparty_all AS asan

ARG BUILD_DIR="/kudu"
ARG BUILD_TYPE=fastdebug
ARG LINK_TYPE=dynamic

# Use the bash shell for all RUN commands.
# SHELL ["/bin/bash", "-c"]
WORKDIR ${BUILD_DIR}

RUN ccache -C
RUN ccache -M 10G

# Build the c++ code.
WORKDIR ${BUILD_DIR}/build/asan
# Enable the Gradle build cache in the C++ build.
ENV GRADLE_FLAGS="--build-cache"
# Ensure we don't rebuild thirdparty. Instead let docker handle caching.
ENV NO_REBUILD_THIRDPARTY=1
# For sanitizer builds clang needs to be used
ENV CLANG=${BUILD_DIR}/build-support/ccache-clang/clang

#build kudu -> basically populate ccache
RUN CC=${CLANG} CXX=${CLANG}++ ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -DKUDU_USE_ASAN=1 \
  -DKUDU_USE_UBSAN=1 \
  -GNinja \
  ../.. \
  && ninja 

#delete the build artefacts
RUN rm -rf ./*

# run cmake for convenience
RUN CC=${CLANG} CXX=${CLANG}++ ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -DKUDU_USE_ASAN=1 \
  -DKUDU_USE_UBSAN=1 \
  -GNinja \
  ../.. 

# Entry point to bash.
CMD ["/bin/bash"]


# ---- Tsan ----
FROM thirdparty_all AS tsan

ARG BUILD_DIR="/kudu"
ARG BUILD_TYPE=fastdebug
ARG LINK_TYPE=dynamic

# Use the bash shell for all RUN commands.
# SHELL ["/bin/bash", "-c"]
WORKDIR ${BUILD_DIR}

RUN ccache -C
RUN ccache -M 10G

# Build the c++ code.
WORKDIR ${BUILD_DIR}/build/tsan
# Enable the Gradle build cache in the C++ build.
ENV GRADLE_FLAGS="--build-cache"
# Ensure we don't rebuild thirdparty. Instead let docker handle caching.
ENV NO_REBUILD_THIRDPARTY=1
# For sanitizer builds clang needs to be used
ENV CLANG=${BUILD_DIR}/build-support/ccache-clang/clang

#build kudu -> basically populate ccache
RUN CC=${CLANG} CXX=${CLANG}++ ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -DKUDU_USE_TSAN=1 \
  -LE no_tsan \
  -GNinja \
  ../.. \
  && ninja 

#delete the build artefacts
RUN rm -rf ./*

# run cmake for convenience
RUN CC=${CLANG} CXX=${CLANG}++ ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -DKUDU_USE_TSAN=1 \
  -LE no_tsan \
  -GNinja \
  ../.. 

# Entry point to bash.
CMD ["/bin/bash"]