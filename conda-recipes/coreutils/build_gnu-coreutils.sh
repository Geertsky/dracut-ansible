#!/bin/bash

# Ensure sysroot paths are used
export CPPFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -I$CONDA_BUILD_SYSROOT/include -Wall"
#export LDFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -L$CONDA_BUILD_SYSROOT/lib -Wl,-rpath=$CONDA_BUILD_SYSROOT/lib"
#export LDFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -L$CONDA_BUILD_SYSROOT/lib64 -static-libgcc -static-libstdc++"
export LDFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -L$CONDA_BUILD_SYSROOT/lib64"
#export PKG_CONFIG_PATH=$CONDA_BUILD_SYSROOT/lib/pkgconfig:$CONDA_BUILD_SYSROOT/usr/lib/pkgconfig

# Use pkg-config to resolve dependencies
./configure --program-prefix=g --prefix=$PREFIX --host=$HOST CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS"
make -j${CPU_COUNT}
make install
make installcheck
