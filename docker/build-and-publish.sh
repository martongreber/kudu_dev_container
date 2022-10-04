#!/bin/bash
# ATTENTION: this scripts prunes all your local docker images!

# exit when any command fails, to avoid long hanging job
set -e

build_types=("dev" "thirdparty" "thirdparty_all" "debug" "release" "asan" "tsan")

# Define a timestamp function
timestamp() {
  date +"%T" # current time
}

build-and-publish() {
  echo "$(timestamp) LOG: pwd: $(pwd)"
  # prune all images to have a clean build sequence
  echo "$(timestamp) LOG: running docker prune"
  docker image prune --all --force
  for build_type in "${build_types[@]}"
  do
      echo "$(timestamp) LOG: starting image build: $build_type"
      time docker build --target $build_type -t murculus/$build_type . 
      echo "$(timestamp) LOG: finished image build: $build_type"
      if [ "$build_type" == "dev" ]; then
        echo "$(timestamp) LOG: not publishing $build_type to dockerhub: $build_type"
      else
        echo "$(timestamp) LOG: starting image push to dockerhub: $build_type"
        time docker push murculus/$build_type
        echo "$(timestamp) LOG: finished image push to dockerhub: $build_type"
      fi
  done
  echo "$(timestamp) LOG: finished"
}

SOURCE_ROOT=$(cd $(dirname "$BASH_SOURCE"); pwd)
cd $SOURCE_ROOT

DATE=`date +%d-%m-%y` 
build-and-publish > /tmp/build-and-publish-$DATE.log 2>&1 

