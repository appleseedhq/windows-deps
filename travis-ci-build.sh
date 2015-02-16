#!/bin/sh

THISDIR=`pwd`
cd src/llvm
chmod +x configure
./configure --enable-targets=x86_64 --prefix=$THISDIR/build
export REQUIRES_RTTI=1
make
make install
