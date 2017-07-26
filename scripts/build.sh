#!/bin/bash

make source || exit 1
make kernel-source || exit 1
make kernel-patch || exit 1
make || exit 1
make kernel || exit 1
make collect || exit 1
