#!/bin/sh -e

PREFIX="$1"

make installopt \
  PROGRAMS=ocamlrun.exe \
  RUNTIMED=false \
  INSTRUMENTED_RUNTIME=false \
  INSTALL_SOURCE_ARTIFACTS=false \
  installed_tools=ocamlmklib \
  OTHERLIBRARIES="bigarray str win32unix systhreads" \
  programs= \
  ocamldebugger=

CAMLC=`which ocamlc`

# Dynlink only compiles after the above has been installed
make otherlibraries opt ocamlnat ocaml ocamldoc \
  OCAMLRUN=ocamlrun \
  NEW_OCAMLRUN=ocamlrun \
  CAMLC="${CAMLC}" \
  OPTCOMPILER="${PWD}/ocamlopt.exe" \
  OCAMLOPT="${PWD}/ocamlopt.exe" \
  OTHERLIBRARIES="bigarray dynlink str win32unix systhreads" \
  MKLIB="ocamlrun \"${PWD}/tools/ocamlmklib.exe\"" \
  OCAMLYACC=ocamlyacc

make install \
  PROGRAMS=ocamlrun.exe \
  RUNTIMED=false \
  INSTRUMENTED_RUNTIME=false \
  INSTALL_SOURCE_ARTIFACTS=false \
  installed_tools=ocamlmklib \
  OTHERLIBRARIES="bigarray dynlink str win32unix systhreads" \
  programs= \
  ocamldebugger=

# Copy META files from ocamlfind
for pkg in bigarray bytes compiler-libs dynlink findlib graphics stdlib str threads unix; do
  if [ -f "${PREFIX}/lib/${pkg}/META" ]; then
    mkdir -p "${PREFIX}/windows-sysroot/lib/${pkg}"
    cp -r "${PREFIX}/lib/${pkg}/META" "${PREFIX}/windows-sysroot/lib/${pkg}/META"
  fi
done

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp windows.conf "${PREFIX}/lib/findlib.conf.d"
