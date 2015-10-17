#!/bin/bash
# This script is used to build, test and squash the chosen Docker image.
#
# Name of resulting image will be: 'NAMESPACE/BASE_IMAGE_NAME-VERSION-OS'.
#
# BASE_IMAGE_NAME - Usually name of the main component within container.
# OS - Specifies distribution - "rhel7" or "centos7", if not specified,
# taken from image directory path
# VERSION - Specifies the image version - , if not specified, taken from
# image directory path
# TEST_MODE - If set, build a candidate image and test it
# TAG_ON_SUCCESS - If set, tested image will be re-tagged as a non-candidate
#       image, if the tests pass. Defaults to false.
# NAMESPACE - What namespace to use in the registry.

set -ex

TAG_ON_SUCCESS=false

# Perform docker build but append the LABEL with GIT commit id at the end
docker_build_with_version() {
  local dockerfile="$1"
  # Use perl here to make this compatible with OSX
  DOCKERFILE_PATH=$(perl -MCwd -e 'print Cwd::abs_path shift' $dockerfile)
  cp ${DOCKERFILE_PATH} "${DOCKERFILE_PATH}.version"
  git_version=$(git rev-parse --short HEAD)
  echo "LABEL io.openshift.builder-version=\"${git_version}\"" >> "${dockerfile}.version"
  docker build -t ${IMAGE_NAME} -f "${dockerfile}.version" .

  # Cleanup the temporary Dockerfile created by docker build with version
  trap "rm -f ${DOCKERFILE_PATH}.version" SIGINT SIGQUIT EXIT

  if [[ "${SKIP_SQUASH}" != "1" ]]; then
    squash "${dockerfile}.version"
  fi
  rm -f "${DOCKERFILE_PATH}.version"
}

# Install the docker squashing tool[1] and squash the result image
# [1] https://github.com/goldmann/docker-scripts
squash() {
  # FIXME: We have to use the exact versions here to avoid Docker client
  #        compatibility issues
  easy_install -q --user docker_py==1.2.3 docker-scripts==0.4.2
  base=$(awk '/^FROM/{print $2}' $1)
  ${HOME}/.local/bin/docker-scripts squash -f $base ${IMAGE_NAME}
}

build_and_tag() {
  IMAGE_NAME="${NAMESPACE}${BASE_IMAGE_NAME}-${VERSION}-${OS}"

  if [[ -v TEST_MODE ]]; then
    IMAGE_NAME+="-candidate"
  fi

  echo "-> Building ${IMAGE_NAME} ..."

  pushd ${IMAGE_PATH} > /dev/null
  docker_build_with_version Dockerfile

  if [[ -v TEST_MODE ]]; then
    IMAGE_NAME=${IMAGE_NAME} test/run

    if [[ $? -eq 0 ]] && [[ -v TAG_ON_SUCCESS ]]; then
      echo "-> Re-tagging ${IMAGE_NAME} image to ${IMAGE_NAME%"-candidate"}"
      docker tag -f $IMAGE_NAME ${IMAGE_NAME%"-candidate"}
    fi
  fi

  popd > /dev/null
}

if [ $# -lt 1 ] ; then
  echo "Usage `basename $0` <path-to-image> [ <imgname> <version> <os> <namespace> ]"
  exit 1
fi

# Arguments on cmd-line are more imporntant, but try to guess them first from given dirname
DOCKERFILE_PATH=""
IMAGE_PATH="$1"
parsed=$(echo "$IMAGE_PATH" |  sed -e 's/\([a-zA-Z0-9]*\)*\.\(rh-\)\?\([a-zA-Z-]*\)\([0-9]*\).*/\1 \3 \4/g')
BASE_IMAGE_NAME=$(echo $parsed | awk '{print $2}')
VERSION=$(echo $parsed | awk '{print $3}')
OS=$(echo $parsed | awk '{print $1}')
[ -n "$2" ] && BASE_IMAGE_NAME="$2"
[ -n "$3" ] && VERSION="$3"
[ -n "$4" ] && OS="$4"
[[ "$OS" =~ centos* ]] && NAMESPACE='centos/' || NAMESPACE='rhscl/'
[ -n "$5" ] && NAMESPACE="$5/"

echo "You are gonna to build image from ${IMAGE_PATH} as ${NAMESPACE}${BASE_IMAGE_NAME}-${VERSION}-${OS}."
while true; do
    read -p "Do you want to proceed with building? (yes/no): " yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) exit ;;
        * ) echo "Please answer yes or no.";;
    esac
done

build_and_tag

