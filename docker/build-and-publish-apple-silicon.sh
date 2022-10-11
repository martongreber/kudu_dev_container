#!/bin/bash
# ATTENTION: this scripts prunes all your local docker images!

# exit when any command fails, to avoid long hanging job
set -e

# build_types=("dev" "thirdparty" "thirdparty_all" "debug" "release" "asan" "tsan")
build_types=("dev" "thirdparty" "debug" "release")
suffix="_apple_silicon"

# Define a timestamp function
timestamp() {
  date +"%T" # current time
}

build-and-publish() {
  echo "$(timestamp) LOG: pwd: $(pwd)"
  # prune all images to have a clean build sequence
  echo "$(timestamp) LOG: running docker prune"
  # /usr/local/bin/docker image prune --all --force
  set +e
  /usr/local/bin/docker rm -vf $(/usr/local/bin/docker ps -aq)
  /usr/local/bin/docker rmi -f $(/usr/local/bin/docker images -aq)
  set -e

  # for thirdparty_all -> privileged container build is needed.
  # /usr/local/bin/docker buildx rm -f mybuilder
  # /usr/local/bin/docker buildx create --use --name mybuilder --buildkitd-flags '--allow-insecure-entitlement'
  for build_type in "${build_types[@]}"
  do
      full_build_type=$build_type$suffix
      echo "$(timestamp) LOG: starting image build: $full_build_type"
      time /usr/local/bin/docker build --target $full_build_type -t murculus/$full_build_type -f $SOURCE_ROOT/Dockerfile_apple_silicon . 
      echo "$(timestamp) LOG: finished image build: $full_build_type"
      if [ "$full_build_type" == "dev_apple_silicon" ]; then
        echo "$(timestamp) LOG: not publishing $full_build_type to dockerhub: $full_build_type"
      else
        echo "$(timestamp) LOG: starting image push to dockerhub: $full_build_type"
        $SOURCE_ROOT/.secret
        time /usr/local/bin/docker push murculus/$full_build_type
        echo "$(timestamp) LOG: finished image push to dockerhub: $full_build_type"
      fi
  done
  echo "$(timestamp) LOG: finished"
}

SOURCE_ROOT=$(cd $(dirname "$BASH_SOURCE"); pwd)
cd $SOURCE_ROOT

DATE=`date +%d-%m-%y` 
build-and-publish > /tmp/build-and-publish-$DATE.log 2>&1 

