#!/bin/sh -e

PREFIX="$1"
HOST="$2"

for bin in ocamlc ocamlopt ocamlmklib; do
  ln -s "${PREFIX}/windows-sysroot/bin/${bin}" "${PREFIX}/bin/${HOST}-${bin}"
done

for bin in ocamlmktop ocamldoc ocamldep; do
  ln -s "${PREFIX}/bin/${bin}" "${PREFIX}/bin/${HOST}-${bin}"
done
