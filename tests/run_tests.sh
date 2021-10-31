#!/bin/sh

TEST_PWD=$(cd `dirname $0` && pwd)
BASE_PWD=$(cd ${TEST_PWD}/.. && pwd)

if [ -z "${SYSTEM_TYPE}" ]; then
  SYSTEM_TYPE="x64"
fi

if [ -z "${OCAML_VERSION}" ]; then
  OCAML_VERSION=4.12.0
fi

 COMPILER="${OCAML_VERSION}"

if [ "${SYSTEM_TYPE}" = "x64" ]; then
  IMAGE="dockcross/windows-static-x64"
else
  IMAGE="dockcross/windows-static-x86"
fi

BASE_IMAGE="ocamlcross/windows-${SYSTEM_TYPE}-base:${OCAML_VERSION}"

if [ -n "${BUILD_BASE}" ]; then
  printf "Building ${BASE_IMAGE}.. "

  DOCKER_CMD="docker build -f ${TEST_PWD}/Dockerfile.base \
                           --build-arg COMPILER=\"${COMPILER}\" \
                           --build-arg IMAGE=\"${IMAGE}\" \
                           --build-arg SYSTEM=\"${SYSTEM_TYPE}\" \
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

PRETEST_IMAGE="ocamlcross/windows-${SYSTEM_TYPE}-pretest:${OCAML_VERSION}"

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

build_package() {
  PACKAGE=$1

  echo "${SKIPPED}" | grep "${PACKAGE}" >/dev/null 2>&1

  if [ "$?" -eq "0" ]; then
    printf "Building ${PACKAGE}.. \033[1;33m[skipped]\033[0m⚠️\n"
  else
    SYSTEM_TYPE="${SYSTEM_TYPE}" OCAML_VERSION="${OCAML_VERSION}" ${TEST_PWD}/run_test.sh "${PACKAGE}"

    if [ "$?" -ne "0" ]; then
      exit 128
    fi
  fi
}

PACKAGES=$(cd ${BASE_PWD}/packages && find . -maxdepth 2 -mindepth 2 -type d | cut -d '/' -f 3 | sort -u)

echo ""
git remote set-branches origin '*'
git fetch origin master
echo ""

echo "${PACKAGES}" | while read PACKAGE; do
  if [ -n "${WORLD}" ]; then
    build_package "${PACKAGE}"
  else
    PACKAGE_DIR=`echo ${PACKAGE} | cut -d'.' -f 1`
    RET=$(cd "${BASE_PWD}/packages/${PACKAGE_DIR}/${PACKAGE}" && git diff --name-only HEAD origin/master .)

    if [ -n "${RET}" ]; then
      build_package "${PACKAGE}"
    fi
  fi
done

