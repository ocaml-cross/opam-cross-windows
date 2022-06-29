#!/bin/sh

TEST_PWD=$(cd `dirname $0` && pwd)
PACKAGE=$1

if [ -z "${SYSTEM_TYPE}" ]; then
  SYSTEM_TYPE="x64"
fi

if [ "${SYSTEM_TYPE}" = "x64" ]; then
  PKG_CONFIG_PATH="/usr/src/mxe/usr/x86_64-w64-mingw32.static/lib/pkgconfig/"
else
  PKG_CONFIG_PATH="/usr/src/mxe/usr/i686-w64-mingw32.static/lib/pkgconfig/"
fi

if [ -z "${OCAML_VERSION}" ]; then
  OCAML_VERSION="4.14.0"
fi

IMAGE="ocamlcross/windows-${SYSTEM_TYPE}-pretest:${OCAML_VERSION}"

printf "Building ${PACKAGE} using ${IMAGE}.. "

DOCKER_CMD="docker build -f ${TEST_PWD}/Dockerfile.test --no-cache \
                --build-arg \"PKG_CONFIG_PATH=${PKG_CONFIG_PATH}\" \
                --build-arg \"IMAGE=${IMAGE}\" --build-arg \"OPAM_PKG=${PACKAGE}\" . 2>/dev/null"

PACKAGE_DIR=`echo ${PACKAGE} | cut -d'.' -f 1`

if [ -f "${TEST_PWD}/../packages/${PACKAGE_DIR}/${PACKAGE}/.tested" ]; then
  printf "\033[0;32m[ok]\033[0m✅\n"
else
  if [ -n "${VERBOSE}" ]; then
    echo ""
    /bin/sh -c "${DOCKER_CMD}"
  else
    /bin/sh -c "${DOCKER_CMD} >/dev/null"
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
                  --build-arg \"IMAGE=${IMAGE}\" --build-arg \"OPAM_PKG=${PACKAGE}\" . 2>/dev/null"

  if [ -n "${VERBOSE}" ]; then
    echo ""
    /bin/sh -c "${DOCKER_CMD}"
  else
    /bin/sh -c "${DOCKER_CMD} >/dev/null"
  fi

  if [ "$?" -ne "0" ]; then
    printf "\033[0;31m[failed]\033[0mð"
    exit 128
  else
    printf "\033[0;32m[ok]\033[0mân"
  fi
fi
