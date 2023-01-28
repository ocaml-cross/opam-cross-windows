#!/bin/sh -e

HOST=$1
OPAM_PREFIX=$2
FLEXDLL=$3

OPTS=""

if [ `opam var conf-flambda-windows:installed` = "true" ]; then
  OPTS="--enable-flambda"
fi

./configure --host=$1 --with-flexdll="${FLEXDLL}" --prefix="${OPAM_PREFIX}/windows-sysroot" ${OPTS}

export PATH="${FLEXDLL}:$PATH" 
PWD=`pwd`
CAMLC=`which ocamlc`

make -C runtime sak.exe SAK_CC=cc SAK_CFLAGS= SAK_LINK='cc -o $(1) $(2)'
make ocamlc ocamlopt OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun CAMLC="${CAMLC}"
make -C tools ocamlmklib CAMLC="${CAMLC}"
make -C runtime all libasmrun.a CAMLC="${CAMLC}"

make -C stdlib \
     OCAMLRUN=ocamlrun \
     NEW_OCAMLRUN=ocamlrun \
     CAMLC=ocamlc \
     CAMLC="${CAMLC}" \
     COMPILER=ocamlc \
     OPTCOMPILER="${PWD}/ocamlopt.exe" \
     OCAMLOPT="${PWD}/ocamlopt.exe" \
     OTHERLIBRARIES="bigarray str win32unix systhreads" \
     MKLIB="ocamlrun \"${PWD}/tools/ocamlmklib.exe\"" \
     FLEXLINK_CMD=flexlink \
     OCAMLYACC=ocamlyacc

make -C yacc \
     OCAMLRUN=ocamlrun \
     NEW_OCAMLRUN=ocamlrun \
     CAMLC=ocamlc \
     CAMLC="${CAMLC}" \
     COMPILER=ocamlc \
     OPTCOMPILER="${PWD}/ocamlopt.exe" \
     OCAMLOPT="${PWD}/ocamlopt.exe" \
     OTHERLIBRARIES="bigarray str win32unix systhreads" \
     MKLIB="ocamlrun \"${PWD}/tools/ocamlmklib.exe\"" \
     FLEXLINK_CMD=flexlink \
     OCAMLYACC=ocamlyacc \
     installed_tools=

make library \
     otherlibraries \
     opt \
     compilerlibs/ocamlcommon.cmxa \
     compilerlibs/ocamlbytecomp.cmxa \
     compilerlibs/ocamloptcomp.cmxa \
     driver/main.cmx \
     driver/optmain.cmx \
     OCAMLRUN=ocamlrun \
     NEW_OCAMLRUN=ocamlrun \
     CAMLC=ocamlc \
     CAMLC="${CAMLC}" \
     COMPILER=ocamlc \
     OPTCOMPILER="${PWD}/ocamlopt.exe" \
     OCAMLOPT="${PWD}/ocamlopt.exe" \
     OTHERLIBRARIES="bigarray str win32unix systhreads" \
     MKLIB="ocamlrun \"${PWD}/tools/ocamlmklib.exe\"" \
     FLEXLINK_CMD=flexlink \
     OCAMLYACC=ocamlyacc \
     installed_tools=
