#!/bin/sh

set -e

HOST=$1
OPAM_PREFIX="$2"

OPTS=""

if [ `opam var conf-flambda-windows:installed` = "true" ]; then
  OPTS="--enable-flambda"
fi

./configure --host=$1 --prefix="${OPAM_PREFIX}/windows-sysroot" --enable-systhreads ${OPTS}

make -C runtime sak.exe SAK_CC=cc SAK_CFLAGS= SAK_LINK='cc -o $(1) $(2)'

make ocamlopt ocamlc OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun CAMLC="`which ocamlc`"
make boot/ocamlruns.exe
make  -C runtime all
make -C stdlib OCAMLRUN=ocamlrun COMPILER="${PWD}/boot/ocamlc"
make -C yacc OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun
make -C lex OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun OCAMLYACC=ocamlyacc CAMLC="`which ocamlc`"
make coldstart OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun
make -C tools ocamlmklib OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun
make -C runtime all libasmrun.a

make library otherlibs opt ocamlnat ocaml ocamldoc ocamldebugger \
  OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun \
  OPTCOMPILER="${PWD}/ocamlopt.exe" \
  MKLIB="ocamlrun \"${PWD}/tools/ocamlmklib.exe\"" \
  OCAMLYACC=ocamlyacc
