#!/bin/sh -e

HOST=$1

./configure --host=$1
cp -f Makefile.cross Makefile.config
cp -f config/s-nt.h runtime/caml/s.h
cp -f config/m-nt.h runtime/caml/m.h

if grep "WITH_SPACETIME=true" Makefile.config >/dev/null 2>/dev/null; then
  echo "#define WITH_SPACETIME" >> runtime/caml/m.h
  echo "#define WITH_PROFINFO" >> runtime/caml/m.h
fi

make world opt \
  compilerlibs/ocamlcommon.cmxa compilerlibs/ocamlbytecomp.cmxa \
  compilerlibs/ocamloptcomp.cmxa driver/main.cmx driver/optmain.cmx
