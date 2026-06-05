# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rk915"
PKG_VERSION="e2fd61651c272aab7bd7e76ba05e5682d7c1d211"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/AveyondFly/rk915"
PKG_URL="https://github.com/AveyondFly/rk915/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Rockchip RK915 SDIO WiFi driver (out-of-tree)"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD} CONFIG_RK915=m modules
}

makeinstall_target() {
  local moddir="${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/rockchip_wlan/rk915"
  mkdir -p "${moddir}"
  cp ${PKG_BUILD}/rk915.ko "${moddir}/"

  local fwdir="${INSTALL}/$(get_full_firmware_dir)"
  mkdir -p "${fwdir}"
  cp ${PKG_BUILD}/firmware/rk915_fw.bin "${fwdir}/"
  cp ${PKG_BUILD}/firmware/rk915_patch.bin "${fwdir}/"
}
