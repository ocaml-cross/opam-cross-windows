#!/bin/sh

set -e

if grep "WITH_SPACETIME=true" config/Makefile >/dev/null 2>/dev/null; then
  echo "#define WITH_SPACETIME" >> byterun/caml/m.h
  echo "#define WITH_PROFINFO" >> byterun/caml/m.h
fi

make -f Makefile.nt world opt \
  compilerlibs/ocamlcommon.cmxa compilerlibs/ocamlbytecomp.cmxa \
  compilerlibs/ocamloptcomp.cmxa driver/main.cmx driver/optmain.cmx
