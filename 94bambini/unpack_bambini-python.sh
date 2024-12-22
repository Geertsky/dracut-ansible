#!/bin/bash
# Free up the reserved space
rm -f /placeholder.img
# Unpack the conda environment
mkdir -p /local/conda/envs/bambini-python/
tar -xf /tmp/bambini-python.tar.gz -C /local/conda/envs/bambini-python/
# Add sysroot libraries ld.cache
echo /local/conda/envs/bambini-python/x86_64-conda-linux-gnu/sysroot/lib >/etc/ld.so.conf.d/sysroot-x86_64.conf
ldconfig
# Make coreutils binaries available for activate
export PATH=/local/conda/envs/bambini-python/sbin:/local/conda/envs/bambini-python/bin:$PATH
# Activate the environment for the conda-unpack
. /local/conda/envs/bambini-python/bin/activate
python3 /local/conda/envs/bambini-python/bin/conda-unpack
# clean up the archive
rm -f /tmp/bambini-python.tar.gz
