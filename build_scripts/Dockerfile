# syntax=docker/dockerfile:1.3-labs
# ---- Dev ----
FROM ubuntu:18.04 as dev

# Cache busting technique:
# https://stackoverflow.com/questions/56945125/force-docker-to-rebuild-a-layer-based-on-latest-commit-of-a-git-repo
ADD https://api.github.com/repos/apache/kudu/git/refs/heads/master version.json

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y git
ENV DEBIAN_FRONTEND=

ARG BUILD_DIR="/apache/dev/git/kudu"
RUN mkdir -p ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

RUN git clone https://github.com/apache/kudu.git .

RUN ./docker/bootstrap-dev-env.sh \
  && ./docker/bootstrap-java-env.sh \
  && ./docker/bootstrap-python-env.sh

ENV PATH /usr/lib/ccache:/usr/lib64/ccache/:$PATH

CMD ["/bin/bash"]

# ---- Thirdparty ----

# this image builds the thirdparty package, it is not stripped down
FROM dev AS kudu-thirdparty

ARG BUILD_DIR="/apache/dev/git/kudu"
WORKDIR ${BUILD_DIR}
RUN thirdparty/build-if-necessary.sh

CMD ["/bin/bash"]


# ---- Thirdparty all ----
FROM kudu-thirdparty AS kudu-thirdparty-all

ARG BUILD_DIR="/apache/dev/git/kudu"
WORKDIR ${BUILD_DIR}
RUN --security=insecure thirdparty/build-if-necessary.sh all

# Entry point to bash.
CMD ["/bin/bash"]


# ---- Debug ----
FROM kudu-thirdparty AS kudu-debug

ARG BUILD_DIR="/apache/dev/git/kudu"
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
  && ninja && rm -rf ./*
#delete the build artefacts

# run cmake for convenience
RUN ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -GNinja \
  ../..

# Entry point to bash.
CMD ["/bin/bash"]

# ---- Release ----
FROM kudu-thirdparty AS kudu-release

ARG BUILD_DIR="/apache/dev/git/kudu"
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
  && ninja && rm -rf ./*
#delete the build artefacts

# run cmake for convenience
RUN ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -GNinja \
  ../..

# Entry point to bash.
CMD ["/bin/bash"]


# ---- Asan ----
FROM kudu-thirdparty-all AS kudu-asan

ARG BUILD_DIR="/apache/dev/git/kudu"
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
  && ninja && rm -rf ./*
#delete the build artefacts

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
FROM kudu-thirdparty-all AS kudu-tsan

ARG BUILD_DIR="/apache/dev/git/kudu"
ARG BUILD_TYPE=fastdebug
ARG LINK_TYPE=dynamic

# Use the bash shell for all RUN commands.
# SHELL ["/bin/bash", "-c"]
WORKDIR ${BUILD_DIR}
COPY linking.patch ./
RUN git apply linking.patch

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
RUN --security=insecure CC=${CLANG} CXX=${CLANG}++ ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
  -DKUDU_LINK=$LINK_TYPE \
  -DKUDU_USE_TSAN=1 \
  -LE no_tsan \
  -GNinja \
  ../.. \
  && ninja && rm -rf ./*
#delete the build artefacts

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

