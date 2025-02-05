#!/bin/sh

# Set OUTPUT_ONLY env variable to only output packages to rebuild.

TEST_PWD=$(cd `dirname $0` && pwd)
BASE_PWD=$(cd ${TEST_PWD}/.. && pwd)

if [ -z "${OCAML_VERSION}" ]; then
  OCAML_VERSION=4.14.1
fi

 COMPILER="${OCAML_VERSION}"

 IMAGE="dockcross/windows-static-x64"

BASE_IMAGE="ghcr.io/ocaml-cross/windows-x64-base:${OCAML_VERSION}"

if [ -n "${BUILD_BASE}" ]; then
  printf "Building ${BASE_IMAGE}.. "

  DOCKER_CMD="docker build -f ${TEST_PWD}/Dockerfile.base \
                           --build-arg COMPILER=\"${COMPILER}\" \
                           --build-arg IMAGE=\"${IMAGE}\" \
                           -t \"${BASE_IMAGE}\" ${BASE_PWD}"

  if [ -n "${VERBOSE}" ]; then
    echo ""
    /bin/sh -c "${DOCKER_CMD}"
  else
    /bin/sh -c "${DOCKER_CMD} >/dev/null"
  fi

  if [ "$?" -ne "0" ]; then
    printf "\033[0;31m[failed]\033[0m🚫 \n"
  else
    printf "\033[0;32m[ok]\033[0m✅ \n"
  fi
fi

# compiler packages are already present in the base image and should never be rebuilt
SKIPPED="ocaml-windows32.${OCAML_VERSION} ocaml-windows64.${OCAML_VERSION} ocaml-windows.${OCAML_VERSION} conf-gcc-windows64.1 conf-gcc-windows32.1"
# these packages just fail
SKIPPED="${SKIPPED} lwt-zmq-windows.2.1.0 zmq-windows.4.0-7"

PRETEST_IMAGE="ocamlcross/windows-x64-pretest:${OCAML_VERSION}"

if [ -z "${OUTPUT_ONLY}" ]; then
  printf "Building ${PRETEST_IMAGE}.."
  DOCKER_CMD="docker build --no-cache -f ${TEST_PWD}/Dockerfile.pretest \
                 --build-arg \"IMAGE=${BASE_IMAGE}\" -t \"${PRETEST_IMAGE}\" ${BASE_PWD}"

  if [ -n "${VERBOSE}" ]; then
    echo ""
    /bin/sh -c "${DOCKER_CMD}"
  else
    /bin/sh -c "${DOCKER_CMD} >/dev/null"
  fi

  if [ "$?" -ne "0" ]; then
    printf "\033[0;31m[failed]\033[0m🚫🚫 \n"
  else
    printf "\033[0;32m[ok]\033[0m✅  \n"
  fi
fi

build_package() {
  PACKAGE=$1

  echo "${SKIPPED}" | grep "${PACKAGE}" >/dev/null 2>&1

  if [ "$?" -eq "0" ]; then
    if [ -n "${OUTPUT_ONLY}" ]; then
      exit 0
    else
      printf "Building ${PACKAGE}.. \033[1;33m[skipped]\033[0m⚠️\n"
    fi
  else
    if [ -n "${OUTPUT_ONLY}" ]; then
      echo "${PACKAGE}"
    else
      OCAML_VERSION="${OCAML_VERSION}" ${TEST_PWD}/run_test.sh "${PACKAGE}"

      if [ "$?" -ne "0" ]; then
        exit 128
      fi
    fi
  fi
}

git remote set-branches origin '*' >/dev/null 2>&1
git fetch origin main >/dev/null 2>&1

cd "${BASE_PWD}"
find packages -maxdepth 2 -mindepth 2 -type d | cut -d '/' -f 3 | sort -u | while read PACKAGE; do
  if [ -n "${WORLD}" ]; then
    build_package "${PACKAGE}"
  else
    PACKAGE_DIR=`echo ${PACKAGE} | cut -d'.' -f 1`
    RET=$(cd "packages/${PACKAGE_DIR}/${PACKAGE}" && git diff --name-only HEAD origin/main .)

    if [ -n "${RET}" ]; then
      build_package "${PACKAGE}"
    fi
  fi
done

