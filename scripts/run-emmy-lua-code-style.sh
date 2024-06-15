#!/bin/sh
set -eu

src_dir=$(dirname "${0}")/..

CodeFormat check --workspace "${src_dir}" --config "${src_dir}/.editorconfig"
