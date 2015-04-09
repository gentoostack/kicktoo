part sda 1 83 100M
part sda 2 82 2048M
part sda 3 83 +

format /dev/sda1 ext2
format /dev/sda2 swap
format /dev/sda3 ext4

mountfs /dev/sda1 ext2 /boot
mountfs /dev/sda2 swap
mountfs /dev/sda3 ext4 / noatime

# retrieve latest autobuild stage version for stage_uri
[ "${arch}" == "x86" ]   && stage_latest $(uname -m)
[ "${arch}" == "amd64" ] && stage_latest amd64
tree_type   snapshot    http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

# get kernel dotconfig from the official running kernel
cat /proc/config.gz | gzip -d > /dotconfig
grep -v CONFIG_EXTRA_FIRMWARE /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
grep -v LZO                   /dotconfig > /dotconfig2 ; mv /dotconfig2 /dotconfig
# enable ovs support
sed -i s/CONFIG_IPV6=m/CONFIG_IPV6=y/g /dotconfig
sed -i s/CONFIG_TUN=m/CONFIG_IPV6=y/g /dotconfig
cat >> /dotconfig << EOF
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_U32=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_SCH_INGRESS=y
CONFIG_BRIDGE=m
CONFIG_OPENVSWITCH=y
EOF
kernel_config_file       /dotconfig
kernel_sources	         gentoo-sources
initramfs_builder               
genkernel_kernel_opts    --loglevel=5
genkernel_initramfs_opts --loglevel=5

grub2_install /dev/sda

timezone                UTC
rootpw                  cl0udAdmin
bootloader              grub
keymap	                us # be-latin1 fr
hostname                gentoo
extra_packages          dhcpcd syslog-ng vim openssh iproute2 acpid net-misc/curl

rcadd                   sshd       default
rcadd                   syslog-ng  default
rcadd                   acpid      default


