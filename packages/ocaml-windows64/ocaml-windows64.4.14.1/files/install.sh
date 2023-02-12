#!/bin/sh -e

PREFIX="$1"

make install RUNTIMED=false INSTRUMENTED_RUNTIME=false

# Copy META files from ocamlfind
for pkg in bigarray bytes compiler-libs dynlink findlib graphics stdlib str threads unix; do
  if [ -f "${PREFIX}/lib/${pkg}/META" ]; then
    mkdir -p "${PREFIX}/windows-sysroot/lib/${pkg}"
    cp -r "${PREFIX}/lib/${pkg}/META" "${PREFIX}/windows-sysroot/lib/${pkg}/META"
  fi
done

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp windows.conf "${PREFIX}/lib/findlib.conf.d"
