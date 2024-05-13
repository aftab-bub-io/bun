#!/usr/bin/env bash
set -euxo pipefail
source $(dirname -- "${BASH_SOURCE[0]}")/env.sh

cd $BUN_DEPS_DIR/base64

rm -rf build
mkdir -p build
cd build

cmake "${CMAKE_FLAGS[@]}" .. -GNinja -B .
ninja

echo "BUN_DEPS_DIR: $BUN_DEPS_DIR"
echo "BUN_DEPS_OUT_DIR: $BUN_DEPS_OUT_DIR"

cp libbase64.a $BUN_DEPS_OUT_DIR/libbase64.a
