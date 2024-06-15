#!/bin/sh
set -eu

src_dir=$(dirname "${0}")/..

minimal_init=${src_dir}/tests/minimal.lua

nvim \
    --headless \
    --noplugin \
    -u "${minimal_init}" \
    -c "PlenaryBustedDirectory tests/ { minimal_init = '${minimal_init}' }"
