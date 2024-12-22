#!/bin/bash

export CFLAGS=$CFLAGS" -I$BUILD_PREFIX/include"
export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig:${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/lib/pkgconfig
export CPPFLAGS="$CPPFLAGS"' -I '$BUILD_PREFIX'/include'
./configure --prefix=$PREFIX
make
make install
# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
