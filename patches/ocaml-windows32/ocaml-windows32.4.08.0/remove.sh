#!/bin/sh -e

PREFIX="$1"

for bin in ocaml ocamlc ocamlcp ocamldebug ocamldep ocamldoc ocamllex ocamlmklib ocamlmktop ocamlobjinfo ocamlopt ocamloptp ocamlprof ocamlrun ocamlyacc; do
  rm -f "${PREFIX}/windows-sysroot/bin/${bin}"
done

rm -rf "${PREFIX}/windows-sysroot/lib/ocaml"
rm -rf "${PREFIX}/lib/findlib.conf.d/windows.conf"
