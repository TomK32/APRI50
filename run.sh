#!/bin/bash

# https://github.com/TomK32/kollum/blob/master/build.sh
# based on https://github.com/josefnpat/LD24/blob/master/build.sh
# Configure this, and also ensure you have the build/osx.patch ready.
NAME="APRI50"

# Version is {last tag}-{commits since last tag}.
# e.g: 0.1.2-3
GAME_VERSION=`git tag|tail -1`
REVISION=`git log ${GAME_VERSION}..HEAD --oneline | wc -l | sed -e 's/ //g'`
GAME_VERSION=${GAME_VERSION}.${REVISION}

moonc . &&
echo "return '${GAME_VERSION}'" > "version.lua" &&
/Applications/gamedev/love-0.9-nightly.app/Contents/MacOS/love .

