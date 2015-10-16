#!/bin/sh

# Assemble the STI application.
# Mount the application into /tmp/src, run assemble and create
# the new image with the changes done by assemble
ID=$(chroot "${HOST}" /usr/bin/docker run -v "${OPT1}:/tmp/src:Z" -d "${IMAGE}" /usr/local/sti/assemble)
chroot "${HOST}" /usr/bin/docker wait $ID
chroot "${HOST}" /usr/bin/docker logs $ID
chroot "${HOST}" /usr/bin/docker commit $ID "${NAME}"
chroot "${HOST}" /usr/bin/docker stop $ID
chroot "${HOST}" /usr/bin/docker rm $ID

# 'docker commit' changes the CMD to /usr/local/sti/assemble,
# so rebuild the image with proper CMD to set it back.
chroot "${HOST}" /usr/bin/docker build -t "${NAME}" - <<EOF >/dev/null 2>&1
FROM ${NAME}
CMD ["/usr/local/sti/run"]
EOF

# Create the docker container so we can later start using systemd
chroot "${HOST}" /usr/bin/docker create --name "${NAME}" ${OPT2} "${NAME}" ${OPT3} 

# Create and enable systemd unit file for the service
sed -e "s/TEMPLATE/${NAME}/g" /usr/share/atomic/template.service > "${HOST}/etc/systemd/system/${NAME}.service"
chroot "${HOST}" /usr/bin/systemctl enable "${NAME}.service"
