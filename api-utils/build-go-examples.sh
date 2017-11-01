#!/bin/bash
set -e

BUILD_TARGETS="darwin/amd64 linux/386 linux/amd64 windows/386 windows/amd64"

FOLDERS_TO_BUILD=(
  JumpCloud_API_Go_Examples/*
)

function go_build () {
  OUTPUT_PREFIX=${PWD##*/}
  GOOS="$1"
  GOARCH="$2"
  
  if [ "$GOOS" == "windows" ]; then
    SUFFIX=".exe"
  else 
    SUFFIX=""
  fi

  GOOS=$GOOS GOARCH=$GOARCH go build -o "${BUILD_PATH}/${GOOS}_${GOARCH}/${OUTPUT_PREFIX}_${GOOS}_${GOARCH}${SUFFIX}"
}

function build_directory () {
  MY_DIR=$1
  GOOS=$2
  GOARCH=$3
  pushd $MY_DIR
  go_build $GOOS $GOARCH
  popd
}

function create_build_directory () {
  GOOS=$1
  GOARCH=$2
  mkdir -p "${BUILD_PATH}/${GOOS}_${GOARCH}"
}

function package_directory () {
  GOOS=$1
  GOARCH=$2

  pushd "${BUILD_PATH}/${GOOS}_${GOARCH}"
  zip -r "../JumpCloudAPI_Examples_${GOOS}_${GOARCH}.zip" .
  popd
}

BUILD_PATH="`pwd`/build"
rm -rf $BUILD_PATH
mkdir -p $BUILD_PATH

for target in ${BUILD_TARGETS}; do
	split=(${target//\// })
	GOOS=${split[0]}
	GOARCH=${split[1]}
	create_build_directory $GOOS $GOARCH

  for path in "${FOLDERS_TO_BUILD[@]}"; do
    build_directory $path $GOOS $GOARCH
  done

  package_directory $GOOS $GOARCH
done

