# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mpv"
PKG_VERSION="02254b92dd237f03aa0a151c2a68778c4ea848f9" # 0.38.0
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/mpv-player/mpv"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ffmpeg SDL2 luajit libass libplacebo"
PKG_LONGDESC="Video player based on MPlayer/mplayer2 https://mpv.io"

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_MESON_OPTS_TARGET+=" -Dgl=disabled -Degl=enabled"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_MESON_OPTS_TARGET+=" -Dgl=enabled -Degl=disabled"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_MESON_OPTS_TARGET+=" -Dwayland=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dwayland=disabled"
fi

PKG_MESON_OPTS_TARGET+=" -Dsdl2=enabled"

configure_target() {
  [ "${ARCH}" = "arm" ] && return 0
  create_meson_conf_target ${TARGET} ${MESON_CONF}
  CC="${HOST_CC}" CXX="${HOST_CXX}" meson setup ${TARGET_MESON_OPTS} --cross-file=${MESON_CONF} ${PKG_MESON_OPTS_TARGET} ${PKG_MESON_SCRIPT%/*}
}

make_target() {
  [ "${ARCH}" = "arm" ] && return 0
  ninja ${NINJA_OPTS} ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  [ "${ARCH}" = "arm" ] && return 0
  flag_enabled "sysroot" "yes" && DESTDIR=${SYSROOT_PREFIX} ninja install ${PKG_MAKEINSTALL_OPTS_TARGET}
  DESTDIR=${INSTALL} ninja install ${PKG_MAKEINSTALL_OPTS_TARGET}
}

post_makeinstall_target() {
  [ "${ARCH}" = "arm" ] && return 0
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/* 2>/dev/null ||:
  mkdir -p ${INSTALL}/usr/config/mpv
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/mpv/
}
