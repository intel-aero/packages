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

PKG_NAME=$1
SCRIPT_DIR="$(dirname $(readlink -f $0))"
GLOBAL_CONF_PATH=$SCRIPT_DIR
declare -A VIRTUAL_PACK=([aero-system]=1 [aero-sample-apps]=1)
if [ "$PWD/scripts" != $SCRIPT_DIR ]; then
    echo "Please run $(basename $0) from the project root directory"
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "Missing package name"
	echo "$0 PKG_NAME"
	exit 1
fi

if [ ! -d "$PKG_NAME" ]; then
	echo "Package dir $PKG_NAME not found"
	exit 1
fi
if [[ ! ${VIRTUAL_PACK[$PKG_NAME]} ]]; then

	if [ ! -e $PKG_NAME/conf ]; then
		echo "$PKG_NAME/url file not found"
		exit 1
	fi

	PKG_PATH=$PWD/$PKG_NAME

	source $GLOBAL_CONF_PATH/conf
	source $PKG_NAME/conf

	if [ -z "$SRCPATH" ] || [ -z "$SRCURL" ]; then
		echo "Missing info in conf file: $PKG_NAME/conf"
		[ -z "$SRCPATH" ] || echo "SRCPATH"
		[ -z "$SRCURL" ] || echo "SRCURL"
		exit 1
	fi
fi
CONF_SRC_PATH=$SRCPATH
CONF_SRC_URL=$SRCURL

# get package version from its changelog
PKG_VERSION=$(head -n 1 ./$PKG_NAME/debian/changelog | sed 's/.*(\(.*\)\-.*).*/\1/')
echo "Building $PKG_NAME $PKG_VERSION"

# Avoid issue due to different directory names and names in changelog.
PKG_DEBIAN_NAME=$(head -n 1 ./$PKG_NAME/debian/changelog | cut -f 1 -d ' ')

# Prepare the build area and copy the debian dir -> build/aero-init-0.1/debian
BUILD_DIR=$PWD/build
PKG_OUTPUT_DIR=$BUILD_DIR/$PKG_DEBIAN_NAME-$PKG_VERSION/
mkdir -p $PKG_OUTPUT_DIR
cp -r $PKG_NAME/debian $PKG_OUTPUT_DIR || exit 1

# Fetch sources listed in conf file
mkdir -p src && cd src
for REPO in $CONF_SRC_URL; do
	URL=$(echo $REPO | cut -f 1 -d '|')
	REV=$(echo $REPO | cut -f 2 -d '|')
	CLONENAME=${URL##*/}
	if [ ! -d $CLONENAME ]; then
		git clone $URL || exit 1
	else
		cd $CLONENAME && git fetch && cd ..
	fi
	# Because both git clone --recursive and git clone --recurse-submodules fails on CI :(
	cd $CLONENAME && git checkout $REV && git submodule update --init --recursive && git rev-parse HEAD > $BUILD_DIR/$CLONENAME-rev && cd .. || exit 1
done
cd ..

# Copy to the build area the files listed in package conf file
for SRC in $CONF_SRC_PATH; do
       echo $SRC
       if [ ${SRC:0:2} != "./" ]; then
               echo "Required a relative path within the repo"
               exit 1
       fi
       rsync -a --exclude=".*" $SRC $PKG_OUTPUT_DIR || exit 1
done

#XBCS tag
for REV in $BUILD_DIR/*-rev; do
	sed -i 's/{'$(basename $REV)'}/'$(cat $REV)'/' $PKG_OUTPUT_DIR/debian/control
done

cd $PKG_OUTPUT_DIR
# Create the source tar ball
tar caf ../"$PKG_DEBIAN_NAME"_"$PKG_VERSION".orig.tar.xz . --exclude debian || exit 1

# Generate package
debuild -uc -us -S -sa || exit 1
