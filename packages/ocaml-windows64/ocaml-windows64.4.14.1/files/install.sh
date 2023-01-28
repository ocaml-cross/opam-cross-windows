#!/bin/sh -e

PREFIX="$1"
PWD=`pwd`

touch \
  tools/profiling.cmo \
  tools/profiling.cmi \
  tools/ocamlcmt.exe \
  debugger/ocamldebug.exe \
  yacc/ocamlyacc.exe \
  ocamldoc/ocamldoc.exe \
  ocamldoc/odoc_info.cma \
  ocamldoc/odoc_info.cmi \
  ocaml.exe \
  expunge.exe \
  eventlog_metadata \
  toplevel/topdirs.cmi \
  toplevel/topstart.cmo \
  toplevel/byte/topeval.cmi

make install \
  PROGRAMS=ocamlrun.exe \
  RUNTIMED=false \
  INSTRUMENTED_RUNTIME=false \
  INSTALL_SOURCE_ARTIFACTS=false \
  installed_tools= \
  OTHERLIBRARIES="bigarray str win32unix systhreads" \
  programs= \
  ocamldebugger= \
  BOOTSTRAPPING_FLEXDLL=false

# Dynlink only compiles after the above has been installed
make otherlibraries opt \
  OCAMLRUN=ocamlrun \
  NEW_OCAMLRUN=ocamlrun \
  CAMLC=ocamlc \
  CAMLC="${CAMLC}" \
  COMPILER=ocamlc \
  OPTCOMPILER="${PWD}/ocamlopt.exe" \
  OCAMLOPT="${PWD}/ocamlopt.exe" \
  OTHERLIBRARIES="bigarray dynlink str win32unix systhreads" \
  MKLIB="ocamlrun \"${PWD}/tools/ocamlmklib.exe\"" \
  FLEXLINK_CMD=flexlink \
  OCAMLYACC=ocamlyacc \
  installed_tools=

make install \
  PROGRAMS=ocamlrun.exe \
  RUNTIMED=false \
  INSTRUMENTED_RUNTIME=false \
  INSTALL_SOURCE_ARTIFACTS=false \
  installed_tools= \
  OTHERLIBRARIES="bigarray dynlink str win32unix systhreads" \
  programs= \
  ocamldebugger= \
  BOOTSTRAPPING_FLEXDLL=false

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

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp windows.conf "${PREFIX}/lib/findlib.conf.d"
