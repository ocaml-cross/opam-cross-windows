#!/bin/sh

set -e

PREFIX="$1"
FLEXDLL_PATH="$2"

cd tools && ln -s stripdebug.exe stripdebug && cd ..
make install installopt RUNTIMED=false INSTRUMENTED_RUNTIME=false OCAMLRUN=ocamlrun NEW_OCAMLRUN=ocamlrun

cp -rf compilerlibs/*.cmxa compilerlibs/*.a "${PREFIX}/windows-sysroot/lib/ocaml/compiler-libs"

for bin in ocaml ocamlc ocamlopt ocamlcp ocamlmklib ocamlmktop ocamldoc ocamldep; do
  cat >"${PREFIX}/windows-sysroot/bin/${bin}" <<END
#!/bin/sh
export PATH=${FLEXDLL_PATH}:\$PATH
${PREFIX}/bin/ocamlrun "${PREFIX}/windows-sysroot/bin/${bin}.exe" "\$@"
END
  chmod +x "${PREFIX}/windows-sysroot/bin/${bin}"
done

# Copy META files from ocamlfind
for pkg in bigarray bytes compiler-libs dynlink findlib graphics stdlib str threads unix; do
  if [ -f "${PREFIX}/lib/${pkg}/META" ]; then
    mkdir -p "${PREFIX}/windows-sysroot/lib/${pkg}"
    cp -r "${PREFIX}/lib/${pkg}/META" "${PREFIX}/windows-sysroot/lib/${pkg}/META"
  fi
done

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp windows.conf "${PREFIX}/lib/findlib.conf.d"
