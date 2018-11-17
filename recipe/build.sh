#!/bin/bash

rm aclocal.m4

aclocal
autoconf

./bootstrap.sh

if [[ `uname` == 'Darwin' ]]; then
    # make check below fails on osx unless $PREFIX/lib is added to rpath
    LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib"
    CFLAGS="$CFLAGS -I${PREFIX}/lib/clang/4.0.1/include -fopenmp"
fi

./configure --prefix=$PREFIX \
            --enable-applications \
            --enable-all \
            --enable-openmp \
            --with-fftw3-libdir=$PREFIX/lib \
            --with-fftw3-includedir=$PREFIX/include \
            --with-window=kaiserbessel

make
make check
make install
