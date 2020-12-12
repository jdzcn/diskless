#!/bin/bash

systemctl restart isc-dhcp-server
systemctl restart tftpd-hpa
systemctl restart nfs-kernel-server