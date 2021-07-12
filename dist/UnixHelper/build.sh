#!/usr/bin/env bash

cFile="UnixHelper.c"
oFile="UnixHelper.o"
aFile="UnixHelper.a"

mkdir -p ./dist/lin32
mkdir -p ./dist/lin64

gcc -c -m32 -Wall -O2 -g -lm -lc -lgcc -lc -o "./dist/lin32/$oFile" $cFile
ar rcs "./dist/lin32/$aFile" "./dist/lin32/$oFile"

gcc -c -m64 -Wall -O2 -g -lm -lc -lgcc -lc -o "./dist/lin64/$oFile" $cFile
ar rcs "./dist/lin64/$aFile" "./dist/lin64/$oFile"
