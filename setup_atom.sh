#!/usr/bin/bash

# path to this script's parent directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/common.sh
require atom
require conda

# atom extensions needed for basic use
apm install file-icons vim-mode-plus linter
apm install minimap minimap-find-and-replace minimap-git-diff minimap-selection

# atom extensions needed for python dev
conda install --name base -y flake8
apm install autocomplete-python linter-flake8 python-indent

# basic configuration
# not softlinked because some configs will vary by platform
cp $DIR/atom_config.cson ~/.atom/config.cson

echo "configured atom"
echo "if this is a Mac, correct the paths in ~/.atom/config.cson"

