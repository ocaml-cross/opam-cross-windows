#!/bin/bash

set -e

. $(dirname $0)/config.sh

${DRY_RUN} git reset --hard HEAD
${DRY_RUN} opam update ${SUFFIX}

for pkg in packages/*; do
  pkgcur=${pkg/-${SUFFIX}/}
  pkgname=${pkgcur/.*/}
  if ! [ -e "${UPSTREAM}/${pkgname}" ]; then
    continue
  fi
  opam install -y ${pkg/packages\//}
done
