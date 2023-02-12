#!/bin/sh

set -e

PREFIX="$1"

make install installopt RUNTIMED=false INSTRUMENTED_RUNTIME=false

cp -rf compilerlibs/*.cmxa compilerlibs/*.a "${PREFIX}/windows-sysroot/lib/ocaml/compiler-libs"

# Copy META files from ocamlfind
for pkg in bigarray bytes compiler-libs dynlink findlib graphics stdlib str threads unix; do
  if [ -f "${PREFIX}/lib/${pkg}/META" ]; then
    mkdir -p "${PREFIX}/windows-sysroot/lib/${pkg}"
    cp -r "${PREFIX}/lib/${pkg}/META" "${PREFIX}/windows-sysroot/lib/${pkg}/META"
  fi
done

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp windows.conf "${PREFIX}/lib/findlib.conf.d"
