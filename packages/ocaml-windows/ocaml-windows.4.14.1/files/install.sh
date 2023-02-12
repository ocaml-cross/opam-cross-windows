#!/bin/sh -e

PREFIX="$1"
HOST="$2"

for bin in ocamlc ocamlopt ocamlmklib; do
  ln -s "${PREFIX}/windows-sysroot/bin/${bin}.exe" "${PREFIX}/bin/${HOST}-${bin}"
  ln -s "${PREFIX}/windows-sysroot/bin/${bin}.exe" "${PREFIX}/windows-sysroot/bin/${bin}"
done

for bin in ocamlcp ocamlmktop ocamldoc ocamldep; do
  ln -s "${PREFIX}/bin/${bin}" "${PREFIX}/bin/${HOST}-${bin}"
done
