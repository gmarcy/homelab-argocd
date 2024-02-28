#!/usr/bin/env sh

set -x

DIR="$1"

cd ${DIR}

rm -f fedora-coreos-*.sig
rm -f ../fedora-coreos-live-initramfs.x86_64.img

VERSION=$(echo fedora-coreos-*-live-kernel-x86_64 | sed -e 's/fedora-coreos-\(.*\)-live-kernel-x86_64/\1/')

if [ "${VERSION}" != "*" ]
then
  for OLD_PATH in fedora-coreos-${VERSION}-live-*
  do
    NEW_PATH=$(echo ${OLD_PATH} | sed -e "s/-${VERSION}-/-/")
    mv ${OLD_PATH} ${NEW_PATH}
  done
  mv fedora-coreos-live-kernel-x86_64 fedora-coreos-live-rootfs.x86_64.img ..
fi
