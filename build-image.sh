#!/bin/bash
# This script is for building sbot image.
#
# exit on errors
set -e

. ./build-view.sh

export ROOT_PATH=$PWD/sbot
export CHATBOT_PATH=${ROOT_PATH}/sbot-chatbot
export SBOT_BRANCH=master
export IMAGE_NAME=-sbot
export MM_IMAGE_NAME=sactive-mattermost
export LOCAL_ADDRESS=localhost:5000
export TAG=latest
export BUILD_TYPE=sbot
export DOCKER_REPO_ADDRESS=shipengqi
export PUSH_IMAGES=false
export BUILD_LOCAL_sbot=false

##############################
# set proxy env
##############################
set_proxy_env() {
  echo "Set proxy environment variables ..."
  export http_proxy=http://
  export https_proxy=$http_proxy
  export HTTP_PROXY=$http_proxy
  export HTTPS_PROXY=$http_proxy
  export no_proxy=127.0.0.1,localhost
  export NO_PROXY=$no_proxy
  echo "sbot path: ${ROOT_PATH}"
  echo "sbot chatbot path: ${CHATBOT_PATH}"
  echo "sbot config path: ${CONFIG_PATH}"
  echo "sbot login path: ${LOGIN_PATH}"
}

##############################
# clean sbot folder
##############################
clean_sbot() {
  echo "Clean Sbot folder ..."
  rm -rf ${ROOT_PATH}
}

##############################
# clone sbot
##############################
clone_sbot() {
  echo "Clone Sbot from Git ..."
  git clone  ${CHATBOT_PATH} -b ${sbot_BRANCH}
  cp $PWD/Dockerfile ${ROOT_PATH}
  cp $PWD/startsbot.sh ${ROOT_PATH}
  cp $PWD/.dockerignore ${ROOT_PATH}
  chmod 555 ${ROOT_PATH}/startsbot.sh
  cd ${ROOT_PATH}
}

##############################
# set image tags
##############################
set_sbot_tags() {
  echo "Set image tags ${TAG} ..."
  export IMAGE_TAG=${LOCAL_ADDRESS}/${IMAGE_NAME}:${TAG}
  export _DOCKER_IMAGE_TAG=${_DOCKER_ADDRESS}/${IMAGE_NAME}:${TAG}
  echo "Set image tag ${IMAGE_TAG} ..."
  echo "Set image tag ${_DOCKER_IMAGE_TAG} ..."
}

##############################
# set image tags
##############################
set_mm_tags() {
  echo "Set image tags ${TAG} ..."
  export MM_IMAGE_TAG=${LOCAL_ADDRESS}/${MM_IMAGE_NAME}:${TAG}
  export MM__DOCKER_IMAGE_TAG=${_DOCKER_ADDRESS}/${IMAGE_NAME}:${TAG}
  echo "Set image tags ${MM_IMAGE_TAG} ..."
  echo "Set image tags ${MM__DOCKER_IMAGE_TAG} ..."
}


##############################
# build sbot image
##############################
build_sbot_image() {
  echo "Build sbot image ..."
  docker build \
  --pull \
  --build-arg="HTTP_PROXY=$http_proxy" \
  --build-arg="http_proxy=$http_proxy" \
  --build-arg="HTTPS_PROXY=$https_proxy" \
  --build-arg="https_proxy=$https_proxy" \
  --build-arg="NO_PROXY=$no_proxy" \
  --build-arg="no_proxy=$no_proxy" \
  -t ${IMAGE_NAME} .
  docker tag ${IMAGE_NAME} ${IMAGE_TAG}
  echo "Successfully tagged ${IMAGE_TAG}"
  docker tag ${IMAGE_NAME} ${HARBOR_IMAGE_TAG}
  echo "Successfully tagged ${HARBOR_IMAGE_TAG}"
  docker tag ${IMAGE_NAME} ${PORTUS_IMAGE_TAG}
  echo "Successfully tagged ${PORTUS_IMAGE_TAG}"
  docker tag ${IMAGE_NAME} ${_DOCKER_IMAGE_TAG}
  echo "Successfully tagged ${_DOCKER_IMAGE_TAG}"
  #docker save -o ${IMAGE_NAME}.tar ${IMAGE_TAG}
  #echo "Successfully saved ${IMAGE_NAME}.tar"
}

##############################
# build mattermost image
##############################
build_mm_image() {
  echo "Build mattermost image ..."
  docker build \
  --build-arg="HTTP_PROXY=$http_proxy" \
  --build-arg="http_proxy=$http_proxy" \
  --build-arg="HTTPS_PROXY=$https_proxy" \
  --build-arg="https_proxy=$https_proxy" \
  --build-arg="NO_PROXY=$no_proxy" \
  --build-arg="no_proxy=$no_proxy" \
  -t ${MM_IMAGE_NAME} .
  docker tag ${MM_IMAGE_NAME} ${MM_IMAGE_TAG}
  echo "Successfully tagged ${MM_IMAGE_TAG}"
  docker tag ${MM_IMAGE_NAME} ${MM_HARBOR_IMAGE_TAG}
  echo "Successfully tagged ${MM_HARBOR_IMAGE_TAG}"
  docker tag ${MM_IMAGE_NAME} ${MM_PORTUS_IMAGE_TAG}
  echo "Successfully tagged ${MM_PORTUS_IMAGE_TAG}"
  docker tag ${IMAGE_NAME} ${MM__DOCKER_IMAGE_TAG}
  echo "Successfully tagged ${MM__DOCKER_IMAGE_TAG}"
  #docker save -o ${MM_IMAGE_NAME}.tar ${MM_IMAGE_TAG}
  #echo "Successfully saved ${MM_IMAGE_NAME}.tar"
}

##############################
# push sbot or mattermost images
##############################
push_image() {
  echo "Push sbot images to repositories ..."
  docker login ${_DOCKER_DOMAIN} -u ${_DOCKER_USERNAME} -p ${_DOCKER_PWD}
  docker push ${3}
}

##############################
# build sbot
##############################
build_sbot() {
  echo "Start build sbot images ..."
  set_sbot_tags
  set_proxy_env
  build_view
  if [ "$BUILD_LOCAL_sbot" = "true" ]; then
    echo "Build sbot images from local directory: ${ROOT_PATH}."
    if [ "$PUSH_IMAGES" = "true" ]; then
      echo "Cannot auto push images when build images from local directory."
      export PUSH_IMAGES=false
    fi
    if [ ! -d "$ROOT_PATH" ]; then
      echo "Cannot find directory: $ROOT_PATH."
    fi
  else
    clean_sbot
    clone_sbot
  fi
  copy_view
  build_sbot_image
  clean_sbot
  if [ "$PUSH_IMAGES" = "true" ]; then
    push_image ${HARBOR_IMAGE_TAG} ${PORTUS_IMAGE_TAG} ${_DOCKER_IMAGE_TAG}
  fi
}


##############################
# build mattermost
##############################
build_mm() {
  echo "Start build mattermost images ..."
  set_mm_tags
  build_mm_image
  if [ "$PUSH_IMAGES" = "true" ]; then
    push_image ${MM_HARBOR_IMAGE_TAG} ${MM_PORTUS_IMAGE_TAG} ${MM__DOCKER_IMAGE_TAG}
  fi
}

##############################
# clean up images
##############################
clean_up() {
  dangleds=$(docker images --filter "dangling=true" -q --no-trunc)
  if [ -n "$dangleds" ]; then
    echo "Clean up dangled images ..."
    docker rmi -f $(docker images --filter "dangling=true" -q --no-trunc)
  else
    echo "Cannot find any dangled images."
  fi
}


echo ""
echo "-----------------------------------------------------------"
echo "            sbot docker image build                     "
echo "-----------------------------------------------------------"

while getopts ":t:v:b:pl" arg
do
  case $arg in
     t)
        export BUILD_TYPE=$OPTARG
     ;;
     v)
        export TAG=$OPTARG
     ;;
     b)
        export sbot_BRANCH=$OPTARG
     ;;
     p)
        export PUSH_IMAGES=true
     ;;
     l)
        export BUILD_LOCAL_sbot=true
     ;;
     :)
        echo "-$OPTARG need a parameter"
        exit 1
     ;;
     ?)
        echo "Invalid option -$OPTARG"
        exit 1
     ;;
  esac
done

docker login ${PORTUS_DOMAIN} -u ${PORTUS_USERNAME} -p ${PORTUS_PWD}
case $BUILD_TYPE in
  sbot|bot)
     build_sbot
  ;;
  mattermost|mm)
     build_mm
  ;;
  *)
     echo "Invalid type $BUILD_TYPE"
     exit 1
  ;;
esac

clean_up
