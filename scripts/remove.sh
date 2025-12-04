#!/bin/bash

set -e

. $(dirname $0)/config.sh

for pkg in packages/*; do
  pkgcur=${pkg/-${SUFFIX}/}
  pkgname=${pkgcur/.*/}
  if ! [ -e "${UPSTREAM}/${pkgname}" ]; then
    continue
  fi
  opam remove -y ${pkg/packages\//}
done
