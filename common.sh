#!/usr/bin/bash

found() {
    if [ -z "$(command -v $1)" ]; then
        echo "install $1!"
        return 1
    fi
}

require() {
    if ! found $1; then
        exit 1
    fi
}

