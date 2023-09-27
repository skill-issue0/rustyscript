#!/bin/bash

if [[ "$ARCH" == "" ]] || [[ "$DIST" == "" ]] || [[ "$NAME" == "" ]]; then
    echo "Usage: env ARCH=... DIST=... NAME=... bash $0"
    exit 2
fi

set -x
set -e

label_stdlib=stdlib-"$NAME"-"$ARCH"
label_lang=rustyscript-"$NAME"-"$ARCH"

if [[ "$NAME" == "ce-specific" ]]; then
    export BUILD_FOR_CE=1
fi

bash z.sh
