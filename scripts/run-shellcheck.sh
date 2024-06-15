#!/bin/sh
set -eu

src_dir=$(dirname "${0}")/..

shellcheck "${src_dir}/scripts/"*.sh
