#!/bin/sh

set -e

HOST=$1
OPAM_PREFIX="$2"
FLEXDLL_DIR="$3"

OPTS=""

if [ `opam var conf-flambda-windows:installed` = "true" ]; then
  OPTS="--enable-flambda"
fi

export PATH=${FLEXDLL_DIR}:$PATH

./configure --host="${HOST}" --prefix="${OPAM_PREFIX}/windows-sysroot" --without-zstd --enable-systhreads ${OPTS}

make runtime/sak.exe DEP_CC="${HOST}-gcc -MM" SAK_CC=cc SAK_CFLAGS= SAK_LINK='cc -o $(1) $(2)'

make ocamlopt ocamlc OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun CAMLC="`which ocamlc`"
make ocamlmklib OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun CAMLC="`which ocamlc`"
make boot/ocamlruns.exe
make runtime-all
make -C stdlib OCAMLRUN=ocamlrun COMPILER="${PWD}/boot/ocamlc"
make ocamlyacc OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun
make ocamllex OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun OCAMLYACC=ocamlyacc CAMLC="`which ocamlc`"
make coldstart OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun
make runtime/libasmrun.a

make library otherlibs opt ocamlnat ocaml ocamldoc ocamldebugger \
  OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun \
  OPTCOMPILER="${PWD}/ocamlopt.exe" \
  MKLIB="ocamlrun \"${PWD}/tools/ocamlmklib.exe\"" \
  OCAMLYACC=ocamlyacc
