#!/bin/bash

NAME=kimchi
VERSION=1.0

SUPPORT_IMAGE=debian-kimchi

if [[ "$(docker images -q $SUPPORT_IMAGE 2> /dev/null)" == "" ]]; then
  echo "#### Building intermediate image..."
  docker build -t $SUPPORT_IMAGE -f ./kimchi.docker ./
  echo "#### OK"
fi

echo "#### Remove old containers and images..."
docker rm --force "$NAME"
docker rmi "$NAME:$VERSION"
echo "#### OK"
echo "#### Building new image and run a container..."
docker build -t "$NAME:$VERSION" -f ./kimchi2.docker ./

docker run -it -p 8001:8001 -d --privileged \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /home/user/Docker/data/kimchi/iso:/var/lib/kimchi/isos \
        -v /home/user/Docker/data/kimchi/vms:/var/lib/libvirt/images \
        -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
        -v /var/lib/libvirt:/var/lib/libvirt \
        -v /etc/libvirt:/etc/libvirt \
        -v /lib/modules:/lib/modules:ro \
        --name kimchi "$NAME:$VERSION"
