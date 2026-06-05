# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rk915"
PKG_VERSION="a6b2c7d3e8f1"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/rockchip-linux/rkwifibt"
PKG_URL="https://github.com/rockchip-linux/rkwifibt/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Rockchip RK915 SDIO WiFi driver (out-of-tree)"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make ARCH=${TARGET_KERNEL_ARCH} \
              KSRC=$(kernel_path) \
              CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
              -C ${PKG_BUILD}/drivers/net/wireless/rockchip_wlan/rk915 \
              KDIR=$(kernel_path) \
              modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/rockchip_wlan/rk915
  cp ${PKG_BUILD}/drivers/net/wireless/rockchip_wlan/rk915/rk915.ko \
     ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/rockchip_wlan/rk915/
}
