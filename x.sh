#! /bin/bash

echo Building for: "$NAME"

if [[ "$ARCH" == "" ]] || [[ "$DIST" == "" ]] || [[ "$NAME" == "" ]]; then
    echo "Usage: env ARCH=... DIST=... NAME=... bash $0"
    exit 1
fi

set -e

error() {
    export TERM=xterm-256color
    tput setaf 1
    tput bold
    echo "Error:" "$@"
    tput sgr0
}

if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install llvm@16

    bash y.sh
else
    # needed to keep user ID in and outside Docker in sync to be able to write to workspace directory
    uid="$(id -u)"
    image="$DIST":"$ARCH"-uid"$uid"
    dockerfile=containers/"$DIST"/Dockerfile."$ARCH"

    echo $dockerfile
    echo $uid
    if [ ! -d "containers/$DIST" ]; then
        error "Unknown dist: $DIST"
        exit 2
    fi

    if [ "$DIST" == "common" ]; then
        error "\"common\" is not a distro"
        exit 2
    fi

    if [ ! -f "$dockerfile" ]; then
        error "Dockerfile $dockerfile could not be found"
        exit 3
    fi

    # build image to cache dependencies
    docker build -t "$image" -f "$dockerfile" --build-arg UID="$uid" containers/"$DIST"

    # run build inside this image
    EXTRA_ARGS=()
    [ -t 1 ] && EXTRA_ARGS+=("-t")
    docker run --rm -i "${EXTRA_ARGS[@]}" -e DOCKER=1 -v "$(readlink -f .)":/ws "$image" bash -xc "cd /ws && bash y.sh"
fi
