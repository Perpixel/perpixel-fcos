#!/bin/bash

NVIDIA_VERSION="565.57.01"
FEDORA_VERSION=41
IMAGE=quay.io/fedora-ostree-desktops/silverblue:${FEDORA_VERSION}

while [[ $# -gt 0 ]]; do
  case $1 in
  --all)
    TEST_ALL=true
    shift
    ;;
  --nvidia)
    TEST_NVIDIA=true
    shift
    ;;
  --packages)
    TEST_PACKAGES=true
    shift
    ;;
  --pipewire)
    TEST_PIPEWIRE=true
    shift
    ;;
  esac
done

podman pull ${IMAGE}

if [ "${TEST_NVIDIA}" == true ] || [ "${TEST_ALL}" == true ]; then
  podman run -it --rm -e NVIDIA_VERSION="${NVIDIA_VERSION}" -e BUILDROOT="/build" -v ./build_files/:/build ${IMAGE} /build/scripts/build-nvidia-modules.sh
fi

if [ "${TEST_PACKAGES}" == true ] || [ "${TEST_ALL}" == true ]; then
  podman run -it --rm -e BUILDROOT="/build" -v ./build_files/:/build ${IMAGE} /build/scripts/packages.sh
fi

if [ "${TEST_PIPEWIRE}" == true ] || [ "${TEST_ALL}" == true ]; then
  podman run -it --rm -e BUILDROOT="/build" -v ./build_files/:/build ${IMAGE} /build/scripts/build-pipewire-aptx.sh
fi
