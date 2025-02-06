#!/bin/sh

set -e

PREFIX="$1"

# Copy META files from ocamlfind
for pkg in bigarray bytes compiler-libs dynlink findlib graphics stdlib str threads unix; do
  if [ -f "${PREFIX}/lib/${pkg}/META" ]; then
    mkdir -p "${PREFIX}/windows-sysroot/lib/${pkg}"
    cp -r "${PREFIX}/lib/${pkg}/META" "${PREFIX}/windows-sysroot/lib/${pkg}/META"
  fi
done
