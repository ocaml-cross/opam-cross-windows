#!/bin/sh -e

PREFIX="$1"
HOST="$2"

for bin in ocamlc ocamlopt ocamlcp ocamlmklib ocamlmktop ocamldoc ocamldep; do
  rm -f "${PREFIX}/bin/${HOST}-${bin}"
done
