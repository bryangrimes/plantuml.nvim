#!/bin/sh
set -eu

git clone \
    --depth 1 \
    --branch v0.1.4 \
    https://github.com/nvim-lua/plenary.nvim \
    "${HOME}/.local/share/nvim/site/pack/vendor/start/plenary.nvim"
