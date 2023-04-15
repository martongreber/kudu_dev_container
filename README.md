# Kudu dev image publish

## Published images
All the published images can be found at: https://hub.docker.com/u/murculus

* murculus/dev
    * ubuntu18.04 base image, prerequisite packages are installed through apt
    * this is provided by all the bootstrap-*.sh scripts from https://github.com/apache/kudu/tree/master/docker
* murculus/kudu-thirdparty
    * contains all the built, uninstrumented thirdparty packages
    * provided by this script: https://github.com/apache/kudu/blob/master/thirdparty/build-if-necessary.sh
* murculus/kudu-debug *(default recommended image)*
    * Kudu debug build type
* murculus/kudu-release
    * Kudu release build type
* murculus/kudu-thirdparty-all
    * contains all the built, uninstrumented and instrumented thirdparty packages
    * provided by this script: https://github.com/apache/kudu/blob/master/thirdparty/build-if-necessary.sh with the 'all' switch
* murculus/kudu-asan
    * Kudu address sanitizer build type
* murculus/kudu-tsan
    * Kudu thread sanitizer build type
