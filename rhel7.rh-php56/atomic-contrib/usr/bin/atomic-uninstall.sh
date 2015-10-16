#!/bin/sh

chroot "${HOST}" /usr/bin/systemctl disable "${NAME}.service"
chroot "${HOST}" /usr/bin/systemctl stop "${NAME}.service"
rm -f "${HOST}/etc/systemd/system/${NAME}.service"
