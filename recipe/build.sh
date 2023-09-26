#!/bin/bash

rm aclocal.m4

aclocal
autoconf

./bootstrap.sh

if [[ `uname` == 'Darwin' ]]; then
    # make check below fails on osx unless $PREFIX/lib is added to rpath
    LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib"
    if [[ "$CC" != "clang" ]]; then
        # llvm-clang case
        CFLAGS="$CFLAGS -I${PREFIX}/lib/clang/4.0.1/include"
    fi
fi

./configure --prefix=$PREFIX \
            --build=$BUILD \
            --host=$HOST \
            --enable-applications \
            --enable-all \
            --enable-openmp \
            --with-fftw3-libdir=$PREFIX/lib \
            --with-fftw3-includedir=$PREFIX/include \
            --with-window=kaiserbessel

make
if [[ "$target_platform" != "osx-arm64" ]]; then
    make check
fi
make install

make clean
./configure --prefix=$PREFIX \
            --build=$BUILD \
            --host=$HOST \
            --enable-applications \
            --enable-all \
            --enable-openmp \
            --enable-single \
            --with-fftw3-libdir=$PREFIX/lib \
            --with-fftw3-includedir=$PREFIX/include \
            --with-window=kaiserbessel

make
if [[ "$target_platform" != "osx-arm64" ]]; then
    make check
fi
make install

# fftw does not build libs for long double on osx-arm64
if [[ "$target_platform" != "osx-arm64" ]]; then
    make clean
    ./configure --prefix=$PREFIX \
                --build=$BUILD \
                --host=$HOST \
                --enable-applications \
                --enable-all \
                --enable-openmp \
                --enable-long-double \
                --with-fftw3-libdir=$PREFIX/lib \
                --with-fftw3-includedir=$PREFIX/include \
                --with-window=kaiserbessel
    
    make
    make check
    make install
fi
