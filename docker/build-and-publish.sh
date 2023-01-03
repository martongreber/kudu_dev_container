#!/bin/bash

# exit when any command fails, to avoid long hanging job
set -e
build_arch=$(uname -m)
build_types=("dev" "kudu-thirdparty" "kudu-thirdparty-all" "kudu-debug" "kudu-release" "kudu-asan" "kudu-tsan")

# Define a timestamp function
timestamp() {
  date +"%T" # current time
}

build-and-publish() {

  docker buildx create --driver-opt image=moby/buildkit:master  \
                      --use --name insecure-builder \
                      --buildkitd-flags '--allow-insecure-entitlement security.insecure' \
                      --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

  docker buildx use insecure-builder

  echo "$(timestamp) LOG: pwd: $(pwd)"

  for build_type in "${build_types[@]}"
  do
      echo "$(timestamp) LOG: starting image build: $build_type:$build_arch"
      time docker buildx build --allow security.insecure --target $build_type -t murculus/$build_type:$build_arch . 
      echo "$(timestamp) LOG: finished image build: $build_type:$build_arch"

      if [ "$build_type" == "dev" ]; then
        echo "$(timestamp) LOG: not publishing $build_type to dockerhub: $build_type"
      else
        echo "$(timestamp) LOG: starting image push to dockerhub: $build_type"
        time docker push murculus/$build_type:$build_arch
        echo "$(timestamp) LOG: finished image push to dockerhub: $build_type"
      fi
  done

  docker buildx rm insecure-builder

  echo "$(timestamp) LOG: finished"
}

SOURCE_ROOT=$(cd $(dirname "$BASH_SOURCE"); pwd)
cd $SOURCE_ROOT

DATE=`date +%d-%m-%y` 
build-and-publish > /tmp/build-and-publish-$DATE.log 2>&1 

