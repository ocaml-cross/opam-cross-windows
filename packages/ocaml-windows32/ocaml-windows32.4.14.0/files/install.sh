#!/bin/sh -e

PREFIX="$1"

cp -f yacc/ocamlyacc.exe yacc/ocamlyacc

make install PROGRAMS=ocamlrun

cp compilerlibs/ocamlcommon.cmxa compilerlibs/ocamlcommon.a \
   compilerlibs/ocamlbytecomp.cmxa compilerlibs/ocamlbytecomp.a \
   compilerlibs/ocamloptcomp.cmxa compilerlibs/ocamloptcomp.a \
   driver/main.cmx driver/main.o \
   driver/optmain.cmx driver/optmain.o \
   "${PREFIX}/windows-sysroot/lib/ocaml/compiler-libs"

for pkg in bigarray bytes compiler-libs dynlink findlib graphics stdlib str threads unix; do
  if [ -d "${PREFIX}/lib/${pkg}" ]; then
    cp -r "${PREFIX}/lib/${pkg}" "${PREFIX}/windows-sysroot/lib/"
  fi
done

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp windows.conf "${PREFIX}/lib/findlib.conf.d"
