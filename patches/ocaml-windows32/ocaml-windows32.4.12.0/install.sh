#!/bin/sh -e

PREFIX="$1"

make install

cp compilerlibs/ocamlcommon.cmxa compilerlibs/ocamlcommon.a \
   compilerlibs/ocamlbytecomp.cmxa compilerlibs/ocamlbytecomp.a \
   compilerlibs/ocamloptcomp.cmxa compilerlibs/ocamloptcomp.a \
   driver/main.cmx driver/main.o \
   driver/optmain.cmx driver/optmain.o \
   "${PREFIX}/windows-sysroot/lib/ocaml/compiler-libs"

for bin in ocamlc ocamlopt ocamlcp ocamlmklib ocamlmktop ocamldoc ocamldep; do
  cat >"${PREFIX}/windows-sysroot/bin/${bin}" <<END
#!/bin/sh
${PREFIX}/bin/ocamlrun "${PREFIX}/windows-sysroot/bin/${bin}.exe" "\$@"
END
  chmod +x "${PREFIX}/windows-sysroot/bin/${bin}"
done

for pkg in bigarray bytes compiler-libs dynlink findlib graphics stdlib str threads unix; do
  if [ -d "${PREFIX}/lib/${pkg}" ]; then
    cp -r "${PREFIX}/lib/${pkg}" "${PREFIX}/windows-sysroot/lib/"
  fi
done

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp windows.conf "${PREFIX}/lib/findlib.conf.d"
