#!/bin/bash

# This file is part of the Intel Aero packaging
#
# Copyright (C) 2017 Intel Corporation. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPT_DIR="$(dirname $(readlink -f $0))"

if [ "$PWD/scripts" != $SCRIPT_DIR ]; then
    echo "Please run $(basename $0) from the project root directory"
	exit 1
fi

ROOTDIR=$PWD
SRC=$PWD/src

cd $SRC
if [ ! -e linux_4.4.0.orig.tar.gz ]; then
	wget http://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux_4.4.0.orig.tar.gz || exit 1
fi
if [ ! -e linux_4.4.0-92.115.diff ]; then
	wget https://launchpadlibrarian.net/332711443/linux_4.4.0-92.115.diff.gz && gunzip linux_4.4.0-92.115.diff.gz || exit 1
fi
cd $ROOTDIR
rm -rf build/linux-4.4
cd build && tar -xf $SRC/linux_4.4.0.orig.tar.gz
cd linux-4.4 && patch -s -p1 < $SRC/linux_4.4.0-92.115.diff
for p in $ROOTDIR/aero-kernel/patches-4.4/*.patch ; do
	patch -s -p1 < $p
done

touch .scmversion
cp $ROOTDIR/aero-kernel/patches-4.4/defconfig .config
yes '' | make oldconfig
make deb-pkg -j5
