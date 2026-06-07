# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="syncthing"
PKG_VERSION="2.0.13"
PKG_SHA256="f62c7e85c081ea43c6e0c8a8bf428fb2f9c1be7f7d504fb214ddd4e1f056c36b"
PKG_LICENSE="MPLv2"
PKG_SITE="https://syncthing.net/"
PKG_URL="https://github.com/syncthing/syncthing/releases/download/v${PKG_VERSION}/syncthing-linux-arm64-v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Syncthing: open source continuous file synchronization"
PKG_TOOLCHAIN="manual"
PKG_ARCH="aarch64"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/syncthing ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/sources/start_syncthing.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/*
}
