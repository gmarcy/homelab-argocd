#!/usr/bin/env bash

set -x

efibootmgr

efibootmgr | grep -q 'Boot00FF  MARKER'
if [ $? = 1 ]
then

  set -ex

  for ssd in $(efibootmgr | sed -n -e 's/^Boot\(000[0-9A-F]\)\** *UEFI : Samsung SSD.*/\1/p')
  do
    echo deleting bootnum ${ssd}
    efibootmgr -B -b ${ssd}
  done

  for windows in $(efibootmgr | sed -n -e 's/^Boot\(000[0-9A-F]\)\** *Windows Boot Manager.*/\1/p')
  do
    echo deleting bootnum ${windows}
    efibootmgr -B -b ${windows}
  done

  for centos in $(efibootmgr | sed -n -e 's/^Boot\(000[0-9A-F]\)\** *CentOS.*/\1/p')
  do
    echo deleting bootnum ${centos}
    efibootmgr -B -b ${centos}
  done

  for fedora in $(efibootmgr | sed -n -e 's/^Boot\(000[0-9A-F]\)\** *Fedora.*/\1/p')
  do
    echo deleting bootnum ${fedora}
    efibootmgr -B -b ${fedora}
  done

  if [ -b /dev/nvme0n1 ]; then
    efibootmgr --create-only --bootnum 00FF --disk /dev/nvme0n1 --label MARKER
  else
    if [ -b /dev/sda ]; then
      efibootmgr --create-only --bootnum 00FF --disk /dev/sda --label MARKER
    fi
  fi
  efibootmgr --inactive --bootnum 00FF

  BOOT_CURRENT=$(efibootmgr | sed -n -e 's/^BootCurrent: \(.*\)/\1/p')
  if [ "${BOOT_CURRENT}" ]; then
    efibootmgr -n ${BOOT_CURRENT}
  else
    efibootmgr -n $(efibootmgr | sed -n -e 's/^BootOrder: \([^,]*\).*/\1/p')
  fi

  echo 'Rebooting to assign new boot device entry'
  sleep 10
  systemctl reboot

  exit 1

else

  efibootmgr --delete-bootnum --bootnum 00FF

  efibootmgr | grep -q 'BootNext'
  if [ $? = 0 ]; then
    efibootmgr -N
  fi

  efibootmgr | grep -q '^Boot000[0-9A-F]\** *UEFI : Samsung SSD.*'
  if [ $? = 0 ]; then
    BOOT_FIRST=$(efibootmgr | sed -n -e 's/^Boot\(000[0-9A-F]\)\** *UEFI : Samsung SSD.*/\1,/p')
  fi

  efibootmgr | grep -q '^Boot000[0-9A-F]\* Fedora.*'
  if [ $? = 0 ]; then
    BOOT_FIRST=$(efibootmgr | sed -n -e 's/^Boot\(000[0-9A-F]\)\* Fedora.*/\1,/p')
  fi

  set -ex

  if [ "${BOOT_FIRST}" ]; then
    BOOT_CURRENT=$(efibootmgr | sed -n -e 's/^BootCurrent: \(.*\)/\1,/p')
    BOOT_ORDER=$(efibootmgr | sed -n -e 's/^BootOrder: \(.*\)/\1/p')

    efibootmgr --bootorder ${BOOT_FIRST}${BOOT_CURRENT}${BOOT_ORDER} --remove-dups

    sleep 10

    exit 0
  else

    sleep 10

    exit 1
  fi

fi
