#!/bin/sh -e

PREFIX="$1"
HOST="$2"

for bin in ocamlc ocamlopt ocamlcp ocamlmklib ocamlmktop ocamldoc ocamldep; do
  ln -s "${PREFIX}/windows-sysroot/bin/${bin}" "${PREFIX}/bin/${HOST}-${bin}"
done
