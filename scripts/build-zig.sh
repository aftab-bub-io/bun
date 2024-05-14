#!/usr/bin/env bash
set -euxo pipefail
source $(dirname -- "${BASH_SOURCE[0]}")/env.sh

CANARY="${CANARY:-0}"
GIT_SHA="${GIT_SHA:-$(git rev-parse HEAD)}"

BUILD_MACHINE_ARCH="${BUILD_MACHINE_ARCH:-$(uname -m)}"
DOCKER_MACHINE_ARCH=""
if [[ "$BUILD_MACHINE_ARCH" == "x86_64" || "$BUILD_MACHINE_ARCH" == "amd64" ]]; then
  BUILD_MACHINE_ARCH="x86_64"
  DOCKER_MACHINE_ARCH="amd64"
elif [[ "$BUILD_MACHINE_ARCH" == "aarch64" || "$BUILD_MACHINE_ARCH" == "arm64" ]]; then
  BUILD_MACHINE_ARCH="aarch64"
  DOCKER_MACHINE_ARCH="arm64"
fi

TARGET_OS="${1:-linux}"
TARGET_ARCH="${2:-x64}"
TARGET_CPU="${3:-native}"

BUILDARCH=""
if [[ "$TARGET_ARCH" == "x64" || "$TARGET_ARCH" == "x86_64" || "$TARGET_ARCH" == "amd64" ]]; then
  TARGET_ARCH="x86_64"
  BUILDARCH="amd64"
elif [[ "$TARGET_ARCH" == "aarch64" || "$TARGET_ARCH" == "arm64" ]]; then
  TARGET_ARCH="aarch64"
  BUILDARCH="arm64"
fi

TRIPLET=""
if [[ "$TARGET_OS" == "linux" ]]; then
  TRIPLET="$TARGET_ARCH-linux-gnu"
elif [[ "$TARGET_OS" == "darwin" ]]; then
  TRIPLET="$TARGET_ARCH-macos-none"
elif [[ "$TARGET_OS" == "windows" ]]; then
  TRIPLET="$TARGET_ARCH-windows-msvc"
fi

OUT_DIR="$(mktemp -d)"

docker buildx build . \
  --platform="linux/$DOCKER_MACHINE_ARCH" \
  --build-arg="BUILD_MACHINE_ARCH=$BUILD_MACHINE_ARCH" \
  --target="build_release_obj" \
  --build-arg="GIT_SHA=$GIT_SHA" \
  --build-arg="TRIPLET=$TRIPLET" \
  --build-arg="ARCH=$TARGET_ARCH" \
  --build-arg="BUILDARCH=$BUILDARCH" \
  --build-arg="CPU_TARGET=$TARGET_CPU" \
  --build-arg="CANARY=$CANARY" \
  --build-arg="ASSERTIONS=OFF" \
  --build-arg="ZIG_OPTIMIZE=ReleaseFast" \
  --output="type=local,dest=$OUT_DIR" \
  --progress="plain"

cp $OUT_DIR/bun-zig.o bun-zig.o
