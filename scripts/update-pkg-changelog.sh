#!/bin/bash

SCRIPT_DIR="$(dirname $(readlink -f $0))"
if [ "$PWD/scripts" != $SCRIPT_DIR ]; then
    echo "Please run $(basename $0) from the project root directory"
	exit 1
fi

if [ ! $(command -v dch) ]; then
    echo "dch is required and was not found in your system".
    exit 1
fi

if [ $# -ne 1 ]; then
	echo "Missing package name"
	echo "$0 PKG_NAME"
	exit 1
fi

PKG_NAME=$1

cd $PKG_NAME/ && dch -i -D xenial -U
