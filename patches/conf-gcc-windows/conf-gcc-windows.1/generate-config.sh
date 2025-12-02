#!/bin/sh

PREFIX=$1
LIBKERNEL32=$(${PREFIX}gcc -print-file-name=libkernel32.a)
RELDIR=$(dirname ${LIBKERNEL32})
INCLUDE=$(cd ${RELDIR}/../include && pwd)
LIB=$(cd ${RELDIR} && pwd)
HOST=$(${PREFIX}gcc -dumpmachine)

echo "prefix: \"${PREFIX}\"" > conf-gcc-windows.config
echo "c-include: \"${INCLUDE}\"" >> conf-gcc-windows.config
echo "c-lib: \"${LIB}\"" >> conf-gcc-windows.config
echo "host: \"${HOST}\"" >> conf-gcc-windows.config
