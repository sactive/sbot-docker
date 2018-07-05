#!/bin/bash
# This script is for building sbot admin view.
#
# exit on errors
set -e

VIEW_PATH=$PWD/view
VIEW_DIST_PATH=$VIEW_PATH/dist
REGISTRY="@****:registry http://****/"

function clone_view() {
  echo "Clone sbot admin view to ${VIEW_PATH} from Git ..."
  git clone  ${VIEW_PATH} -b ${sbot_BRANCH}
}

function build_view_dist() {
  echo "Build config view for production ..."
  npm config set ${REGISTRY}
  npm install webpack@3.10.0 -g
  npm install
  npm run build
}

function clean_view() {
  echo "Clean config view folder ..."
  rm -rf ${VIEW_PATH}
}

function build_view() {
  clean_view
  clone_view
  cd ${VIEW_PATH}
  build_view_dist
  cd ../
}

function copy_view() {
  echo "Copy dist into sbot config ..."
  cp -R $VIEW_DIST_PATH $CONFIG_PATH/src/public/
  mv $CONFIG_PATH/src/public/dist/index_prod.html $CONFIG_PATH/src/views/
}
