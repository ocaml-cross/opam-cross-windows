opam-cross-windows
==================

This repository contains an up-to-date Windows toolchain featuring OCaml `4.07.0`, `4.08.0`, `4.12.0`, `4.14.0` and `5.1.1`, as well as some commonly used packages.

The supported build systems are 32-bit and 64-bit x86 Linux and `arm64` macos (Apple Silicon). The supported target systems are 32-bit and 64-bit x86 Windows.

Only 64-bit build and target are supported for OCaml `5.1.1`.

If you need support for other platforms or versions, please [open an issue](https://github.com/ocaml-cross/opam-cross-windows/issues).

Prerequisites
-------------

A C cross-compiler targeting the appropriate Windows platform must be installed. On Debian derivatives they are provided in the `gcc-mingw-w64-i686` (for 32-bit x86 Windows targets) or `gcc-mingw-w64-x86-64` (for 64-bit x86 Windows targets) packages. Alternatively, the [MXE environment](http://mxe.cc) can be used.

Installation
------------

Add this repository to OPAM:

    opam repository add windows https://github.com/ocaml-cross/opam-cross-windows.git

The version of the regular compiler installed in your current `opam` switch must match the version of the cross-compiler:

    opam switch 4.14.1
    eval `opam config env`

If desired, request the compiler to be built with [flambda][] optimizers:

    opam install conf-flambda-windows

[flambda]: https://caml.inria.fr/pub/docs/manual-ocaml/flambda.html

If you are compiling for 32bit windows on a 64bit `x86_64` architecture, you will also need to install `ocaml-option-32bit` to make sure 
that your ocaml compiler is configured to output 32bit binary objects. This does not seem to be required on `arm64` macos (Apple Silicon).

Install the compiler:

    opam install ocaml-windows

The compiler version is selected automatically based on the current OPAM switch;
either ocaml-windows32 or ocaml-windows64 can be installed in any single one.

Alternatively, specify the path to the C toolchain explicitly:

    TOOLPREF32=~/mxe/usr/bin/i686-w64-mingw32.static- opam install ocaml-windows
    TOOLPREF64=~/mxe/usr/bin/x86_64-w64-mingw32.static- opam install ocaml-windows

The options have the following meaning:

  * `TOOLPREF32` and `TOOLPREF64` specify the compiler path prefix. The tools named `${TOOLPREF*}gcc`, `${TOOLPREF*}as`, `${TOOLPREF*}ar`, `${TOOLPREF*}ranlib` and `${TOOLPREF*}ld` must be possible to locate via `PATH`.

    The values above are suitable for use with the [MXE environment](http://mxe.cc) located in `~/mxe` after running `make gcc`.

The `TOOLPREF*` options are recorded inside the `conf-gcc-windows*` packages, so make sure to reinstall those if you wish to switch to a different toolchain. Otherwise, it is not necessary to supply them while upgrading the `ocaml-windows*` packages.

Build some code:

    echo 'let () = print_endline "Hello, world!"' >helloworld.ml
    ocamlfind -toolchain windows ocamlc helloworld.ml -o helloworld.byte
    ocamlfind -toolchain windows ocamlopt helloworld.ml -o helloworld.native

Run it:

    wine cmd /c "set PATH=Z:/$(ocamlfind -toolchain windows printconf path)/../bin;%PATH%
                 && ./helloworld.byte"
    wine ./helloworld.native

Install some packages:

    opam install re-windows

Write some code using them:

    let () =
      let regexp = Re_pcre.regexp {|\b([a-z]+)\b|} in
      let result = Re.exec regexp "Hello, world!" in
      Format.printf "match: %s\n" (Re.get result 1)

Build it:

    ocamlfind -toolchain windows ocamlopt -package re.pcre -linkpkg test_pcre.ml -o test_pcre

Make an object file out of it and link it with your native project (you'll need to call `caml_startup(argv)` to run OCaml code; see [this article](http://www.mega-nerd.com/erikd/Blog/CodeHacking/Ocaml/calling_ocaml.html)):

    ocamlfind -toolchain windows ocamlopt -package re.pcre -linkpkg -output-complete-obj test_pcre.ml -o test_pcre.o

Make a DLL out of it:

    ocamlfind -toolchain windows ocamlopt -package re.pcre -linkpkg -output-obj -cclib -shared test_pcre.ml -o test_pcre.dll

With opam-windows-cross, cross-compilation is easy!

External dependencies
---------------------

opam-windows-cross is designed to use native dependencies from the [MXE environment](http://mxe.cc). It is possible to automatically install all required dependencies for an OPAM package, e.g. `camlbz2-windows`, using one short command within an MXE checkout:

    make `opam list --short --recursive --external --vars os-distribution=mxe --required-by=camlbz2-windows`

Porting packages
----------------

OCaml packages often have components that execute at compile-time (camlp4 or ppx syntax extensions, cstubs, OASIS, ...). Thus, it is not possible to just blanketly cross-compile every package in the OPAM repository; sometimes you would even need a cross-compiled and a non-cross-compiled package at once. The package definitions also often need package-specific modification in order to work.

As a result, if you want a package to be cross-compiled, you have to copy the definition from [opam-repository](https://github.com/ocaml/opam-repository), rename the package to add `-windows` suffix while updating any dependencies it could have, and update the build script. Don't forget to add `ocaml-windows` as a dependency!

Findlib 1.5.4 adds a feature that makes porting packages much simpler; namely, an `OCAMLFIND_TOOLCHAIN` environment variable that is equivalent to the `-toolchain` command-line flag. Now it is not necessary to patch the build systems of the packages to select the Windows toolchain; it is often enough to add `["env" "OCAMLFIND_TOOLCHAIN=windows" make ...]` to the build command in the `opam` file.

For projects using OASIS, the following steps will work:

    build: [
      ["env" "OCAMLFIND_TOOLCHAIN=windows"
       "ocaml" "setup.ml" "-configure" "--prefix" "%{prefix}%/windows-sysroot"
                                       "--override" "ext_dll" ".dll"]
      ["env" "OCAMLFIND_TOOLCHAIN=windows"
       "ocaml" "setup.ml" "-build"]
    ]
    install: [
      ["env" "OCAMLFIND_TOOLCHAIN=windows"
       "ocaml" "setup.ml" "-install"]
    ]
    remove: [["ocamlfind" "-toolchain" "windows" "remove" "pkg"]]
    depends: ["ocaml-windows" ...]

The output of the `configure` script will be entirely wrong, referring to the host configuration rather than target configuration. Thankfully, it is not actually used in the build process itself, so it doesn't matter.

For projects installing the files via OPAM's `.install` files (e.g. [topkg](https://github.com/dbuenzli/topkg)), the following steps will work:

    build: [["ocaml" "pkg/pkg.ml" "build" "--toolchain" "windows" ]]
    install: [["opam-installer" "--prefix=%{prefix}%/windows-sysroot" "pkg.install"]]
    remove: [["ocamlfind" "-toolchain" "windows" "remove" "pkg"]]
    depends: ["ocaml-windows" ...]

License
-------

All files contained in this repository are licensed under the [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) license.

References
----------

See also [opam-cross-android](https://github.com/ocaml-cross/opam-cross-android) and [opam-cross-ios](https://github.com/ocaml-cross/opam-cross-ios).
