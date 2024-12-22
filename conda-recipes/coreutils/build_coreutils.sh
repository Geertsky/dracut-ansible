#!/bin/env bash

# Set environment variables for sysroot
export CPPFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -I$CONDA_BUILD_SYSROOT/include"
#export LDFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -L$CONDA_BUILD_SYSROOT/lib -Wl,-rpath=$CONDA_BUILD_SYSROOT/lib"
#export LDFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -L$CONDA_BUILD_SYSROOT/lib64 -static-libgcc -static-libstdc++"
export LDFLAGS="--sysroot=$CONDA_BUILD_SYSROOT -L$CONDA_BUILD_SYSROOT/lib64"

# Configure and build
./configure --prefix=$PREFIX --host=$HOST CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS"

make -j $CPU_COUNT
make install
make installcheck
