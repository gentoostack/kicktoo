part vda 1 83 +

format /dev/vda1 ext4

mountfs /dev/vda1 ext4 / noatime

# retrieve latest autobuild stage version for stage_uri
[ "${arch}" == "x86" ]   && stage_latest $(uname -m)
[ "${arch}" == "amd64" ] && stage_latest amd64
tree_type   snapshot    http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

# get kernel dotconfig from the official running kernel
cat /proc/config.gz | gzip -d > /dotconfig
grep -v CONFIG_EXTRA_FIRMWARE /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
grep -v LZO                   /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
# Enable VirtIO options
sed -i s/CONFIG_VIRTIO_PCI=m/CONFIG_VIRTIO_PCI=y/g /dotconfig
sed -i s/CONFIG_VIRTIO_BALLOON=m/CONFIG_VIRTIO_BALLOON=y/g /dotconfig
sed -i s/CONFIG_VIRTIO_BLK=m/CONFIG_VIRTIO_BLK=y/g /dotconfig
sed -i s/CONFIG_VIRTIO_NET=m/CONFIG_VIRTIO_NET=y/g /dotconfig
sed -i s/CONFIG_VIRTIO=m/CONFIG_VIRTIO=y/g /dotconfig
sed -i s/CONFIG_VIRTIO_RING=m/CONFIG_VIRTIO_RING=y/g /dotconfig
kernel_config_file       /dotconfig
kernel_sources	         gentoo-sources
initramfs_builder               
genkernel_kernel_opts    --loglevel=5
genkernel_initramfs_opts --loglevel=5

grub2_install /dev/vda

timezone                UTC
rootpw                  cl0udAdmin
bootloader              grub
keymap	                us # be-latin1 fr
hostname                gentoo-cloud
extra_packages          dhcpcd syslog-ng vim openssh iproute2 acpid curl

rcadd                   sshd       default
rcadd                   syslog-ng  default
rcadd                   acpid      default
