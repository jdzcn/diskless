debian 10 diskless system
https://gmelikov.com/2018/02/25/debian-stretch-diskless-pxe-boot/

1.Configure server

    apt-get install isc-dhcp-server tftpd-hpa syslinux pxelinux nfs-kernel-server
    mkdir -p /srv/tftp /srv/nfs1
    
    cp -vax /usr/lib/PXELINUX/pxelinux.0 /srv/tftp/
    cp -vax /usr/lib/syslinux/modules/bios/ldlinux.c32 /srv/tftp/
    mkdir /srv/tftp/pxelinux.cfg

2.Create /srv/tftp/pxelinux.cfg/default file :

    default Debian
    prompt 1
    timeout 3
    label Debian
    kernel vmlinuz.pxe
    append rw initrd=initrd.pxe root=/dev/nfs ip=dhcp nfsroot=192.168.1.2:/srv/nfs1

3.Edit /etc/exports :

    /srv/nfs1 *(rw,async,no_subtree_check,no_root_squash)

4.systemctl restart isc-dhcp-server tftpd-hpa nfs-kernel-server

5.Create system on NFS share

	apt install debootstrap
	debootstrap buster /srv/nfs1 http://mirrors.tuna.tsinghua.edu.cn/debian

6.edit /srv/nfs1/etc/fstab :

    #192.168.1.2:/srv/nfs1 / nfs rw,noatime,nolock 1 1
    /dev/nfs / nfs tcp,nolock 0 0
    proc /proc    proc  defaults 0 0
    none /tmp     tmpfs defaults 0 0
    none /var/tmp tmpfs defaults 0 0
    none /media   tmpfs defaults 0 0
    none /var/log tmpfs defaults 0 0

7.edit /srv/nfs1/etc/network/interfaces:

	iface eth0 inet dhcp

8.Start chroot:

    mount --rbind /dev  /srv/nfs1/dev
    mount --rbind /proc /srv/nfs1/proc/
    mount --rbind /sys /srv/nfs1/sys/
    chroot /srv/nfs1/  /bin/bash --login

9.Configure client:

	apt install initramfs-tools linux-image-amd64

	echo "r8169" >> /etc/initramfs-tools/modules

	echo "BOOT=nfs" >> /etc/initramfs-tools/initramfs.conf 

    mkinitramfs -d /etc/initramfs-tools -o /boot/initrd.pxe
    update-initramfs -u
    cp -vax /boot/initrd.img[TAB] /boot/initrd.pxe
    cp -vax boot/vmlinuz[TAB] boot/vmlinuz.pxe

10.On server:
	
	cp -vax /srv/nfs1/boot/*.pxe /srv/tftp/

















