Dracut module for use with Ansible
==================================

This module is used for the ansible-OSinstall_initramfs ansible role and contains currently only a list of binaries to include in the initramfs.

Building the initramfs
----------------------

The functioning initramfs was built using:

```
F=$(cat binaries)
sudo dracut -NM -I "$F" -i /usr/lib/python3.11/ /usr/lib/python3.11/ -i /home/geert/git/geertsky/dracut-bambini/etc/ssh/sshd_config /etc/ssh/sshd_config -a "sshd network lvm systemd-resolved" /home/geert/work/ansible-initrd/initramfs-try-$(uname -r).img $(uname -r) --force
```
