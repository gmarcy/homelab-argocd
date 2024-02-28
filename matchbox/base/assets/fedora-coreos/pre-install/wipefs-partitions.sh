#!/usr/bin/env bash

set -ex

lsblk --json

PV_VG=$(pvdisplay -C -o pv_name,vg_name --no-headings --separator ':' --config 'devices {}')
if [ "${PV_VG}" != "" ]; then
  PV=$(echo ${PV_VG} | cut -d ':' -f 1)
  VG=$(echo ${PV_VG} | cut -d ':' -f 2)
  vgremove -f ${VG} || true
  pvremove -f ${PV} || true
  lsblk --json
fi

if [ -b /dev/sda ]; then
  wipefs -a /dev/sda6 || true
  wipefs -a /dev/sda5 || true
  wipefs -a /dev/sda4 || true
  wipefs -a /dev/sda3 || true
  wipefs -a /dev/sda2 || true
  wipefs -a /dev/sda1 || true
  wipefs -a /dev/sda || true
fi

if [ -b /dev/nvme0n1 ]; then
  wipefs -a /dev/nvme0n1p6 || true
  wipefs -a /dev/nvme0n1p5 || true
  wipefs -a /dev/nvme0n1p4 || true
  wipefs -a /dev/nvme0n1p3 || true
  wipefs -a /dev/nvme0n1p2 || true
  wipefs -a /dev/nvme0n1p1 || true
  wipefs -a /dev/nvme0n1
fi

if [ -b /dev/nvme1n1 ]; then
  wipefs -a /dev/nvme1n1p6 || true
  wipefs -a /dev/nvme1n1p5 || true
  wipefs -a /dev/nvme1n1p4 || true
  wipefs -a /dev/nvme1n1p3 || true
  wipefs -a /dev/nvme1n1p2 || true
  wipefs -a /dev/nvme1n1p1 || true
  wipefs -a /dev/nvme1n1
fi

lsblk --json

if [ -b /dev/nvme0n1 -a -b /dev/nvme1n1 ]; then
  MINOR=$(lsblk -n -N -o 'MAJ:MIN' /dev/nvme0n1 | cut -d ':' -f 2)
  if [ ${MINOR} -ne 0 ]
  then
    echo '/dev/nvme0n1 was not assigned to the correct device...  rebooting'
    sleep 5
    systemctl reboot
  fi
fi
