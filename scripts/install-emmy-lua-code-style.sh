#!/bin/sh
set -eu

bin_dir=${HOME}/.local/bin

mkdir -p "${bin_dir}"

curl \
    --silent \
    --location \
    https://github.com/CppCXY/EmmyLuaCodeStyle/releases/download/1.4.3/linux-x64.tar.gz | \
    tar -xvz -C "${bin_dir}" linux-x64/bin/CodeFormat --strip-components 2
