#!/bin/sh

TEST_PWD=$(cd `dirname $0` && pwd)
PACKAGE=$1

PKG_CONFIG_PATH="/usr/src/mxe/usr/x86_64-w64-mingw32.static/lib/pkgconfig/"

if [ -z "${OCAML_VERSION}" ]; then
  OCAML_VERSION="4.14.0"
fi

IMAGE="ocamlcross/windows-x64-pretest:${OCAML_VERSION}"

printf "Building ${PACKAGE} using ${IMAGE}.. "

DOCKER_CMD="docker build -f ${TEST_PWD}/Dockerfile.test --no-cache \
                --build-arg \"PKG_CONFIG_PATH=${PKG_CONFIG_PATH}\" \
                --build-arg \"IMAGE=${IMAGE}\" --build-arg \"OPAM_PKG=${PACKAGE}\" . "

PACKAGE_DIR=`echo ${PACKAGE} | cut -d'.' -f 1`

if [ -f "${TEST_PWD}/../packages/${PACKAGE_DIR}/${PACKAGE}/.tested" ]; then
  printf "\033[0;32m[ok]\033[0m✅\n"
else
  if [ -n "${VERBOSE}" ]; then
    echo ""
    /bin/sh -c "${DOCKER_CMD}"
  else
    /bin/sh -c "${DOCKER_CMD} >/dev/null 2>/dev/null"
  fi

  if [ "$?" -ne "0" ]; then
    printf "\033[0;31m[failed]\033[0m🚫\n"
    exit 128
  else
    printf "\033[0;32m[ok]\033[0m✅\n"
    touch "${TEST_PWD}/../packages/${PACKAGE_DIR}/${PACKAGE}/.tested"
  fi
fi

if [ -n "${REVDEPS}" ]; then
  printf "Building ${PACKAGE} reverse dependencies using ${IMAGE}.. "

  DOCKER_CMD="docker build -f ${TEST_PWD}/Dockerfile.revdeps --no-cache \
                  --build-arg \"IMAGE=${IMAGE}\" --build-arg \"OPAM_PKG=${PACKAGE}\" . "

  if [ -n "${VERBOSE}" ]; then
    echo ""
    /bin/sh -c "${DOCKER_CMD}"
  else
    /bin/sh -c "${DOCKER_CMD} >/dev/null 2>/dev/null"
  fi

  if [ "$?" -ne "0" ]; then
    printf "\033[0;31m[failed]\033[0mð"
    exit 128
  else
    printf "\033[0;32m[ok]\033[0mân"
  fi
fi
