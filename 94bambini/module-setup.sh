#!/bin/bash

# 2023, Geert Geurts <geert@verweggistan.eu>
# SPDX-License-Identifier: BSD

# called by dracut
check() {
  require_binaries /usr/sbin/ldconfig /usr/bin/env /usr/bin/tar /usr/bin/gzip /usr/bin/ssh-keygen /usr/libexec/openssh/sshd-keygen|| return 1

  # 0 enables by default, 255 only on request
  return 255
}

# called by dracut
depends() {
  echo "sshd"
}

# called by dracut
install() {
  #Install binaries and additional includes
  cd "${moddir}"

  inst /usr/bin/env
  inst /usr/sbin/ldconfig
  # add tar.gz support
  inst /usr/bin/tar
  inst /usr/bin/gzip
  # add permanent ssh-keygen
  inst /usr/bin/ssh-keygen
  inst /usr/libexec/openssh/sshd-keygen
  mkdir -p "${initdir}${systemdsystemconfdir}/sshd.service.d/"
  inst "${moddir}/wants.conf" "${systemdsystemconfdir}/sshd.service.d/wants.conf"
  inst "${moddir}/after.conf" "${systemdsystemconfdir}/sshd.service.d/after.conf"
  inst "${moddir}/sshd-keygen@.service" "${systemdsystemunitdir}/sshd-keygen@.service"
  inst "${moddir}/sshd-keygen.target" "${systemdsystemunitdir}/sshd-keygen.target"
  mkdir -p "${initdir}${systemdsystemconfdir}/sshd-keygen@.service.d/"
  inst "${moddir}/execstartpre.conf" "${systemdsystemconfdir}/sshd-keygen@.service.d/execstartpre.conf"
  inst "${moddir}/conditionfilenotempty.conf" "${systemdsystemconfdir}/sshd-keygen@.service.d/conditionfilenotempty.conf"
  for F in "${systemdsystemconfdir}/sshd.service.d/wants.conf" "${systemdsystemconfdir}/sshd.service.d/after.conf" "${systemdsystemunitdir}/sshd-keygen@.service" "${systemdsystemunitdir}/sshd-keygen.target" "${systemdsystemconfdir}/sshd-keygen@.service.d/execstartpre.conf" "${systemdsystemconfdir}/sshd-keygen@.service.d/conditionfilenotempty.conf"; do
    chown root:root "${initdir}/${F}"
  done
  for key in ecdsa ed25519 rsa; do
    $SYSTEMCTL -q --root "${initdir}" enable sshd-keygen@${key}.service
  done

  # unpack bambini-python systemd service
  inst "${moddir}/unpack_bambini-python.sh" "/usr/libexec/unpack_bambini-python.sh"
  chown root:root "${initdir}/usr/libexec/unpack_bambini-python.sh"
  inst "${moddir}/unpack_bambini-python.service" "${systemdsystemunitdir}/unpack_bambini-python.service"
  chown root:root "${initdir}/${systemdsystemunitdir}/unpack_bambini-python.service"
  $SYSTEMCTL -q --root "${initdir}" enable unpack_bambini-python.service

  # wait_for_ansible systemd service
  inst "${moddir}/wait_for_ansible_finished.sh" "/usr/libexec/wait_for_ansible_finished.sh"
  chown root:root "${initdir}/usr/libexec/wait_for_ansible_finished.sh"
  inst "${moddir}/wait_for_ansible_finished.service" "${systemdsystemunitdir}/wait_for_ansible_finished.service"
  chown root:root "${initdir}/${systemdsystemunitdir}/wait_for_ansible_finished.service"
  $SYSTEMCTL -q --root "${initdir}" enable wait_for_ansible_finished.service

  # check if internal-sftp is enabled otherwise enable it here
  if ! grep -q internal-sftp "${initdir}"/etc/ssh/sshd_config; then
    mv "${initdir}/etc/ssh/sshd_config" "${initdir}/etc/ssh/sshd_config.bak"
    awk '!found && /^AcceptEnv/ { print "Subsystem sftp                  internal-sftp"; found=1 } 1' "${initdir}/etc/ssh/sshd_config.bak" >"${initdir}/etc/ssh/sshd_config"
  fi

  # install packed conda environment and python binary for glibc dep. resolution.
  inst "${moddir}/bambini-python.tar.gz" "/tmp/bambini-python.tar.gz"
  dd if="/dev/urandom" of="${initdir}/placeholder.img" bs=1M count=500 >/dev/null 2>&1
  PTMP="$(mktemp -d)"
  tar -xf "${moddir}/bambini-python.tar.gz" -C "$PTMP" "bin/python3*"
  PYTHON=$(find ${PTMP} -type f -exec file {} \;|tr -d ":"|awk '{if ($2=="ELF") print $1}')
  inst "${PYTHON}" "/bin/python"
  rm -Rf "${PTMP}"

  inst_hook cmdline 40 "${moddir}/create-lvm-links.sh"
}
