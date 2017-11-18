#!/bin/bash

CHANGES=$(git diff --cached --name-only --diff-filter=ACM | cut -f 1 -d / | grep -v "scripts\|AUTHORS\|Makefile")
echo $CHANGES
[ -z $CHANGES ] || exit 0
for pkg in $CHANGES; do
	./scripts/update-pkg-changelog.sh $pkg
done
